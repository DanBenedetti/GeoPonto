import tensorflow as tf
import numpy as np
import os
import random
import matplotlib.pyplot as plt
from scipy.spatial.distance import euclidean

# 1. Configurações
IMG_SIZE = (224, 224)
EXTRACTOR_PATH = 'geoponto_extractor_v8_3_1.keras'
DATASET_PATH = 'GeoPonto/Biometria/dataset_especialista_250/'
METRICS_DIR = 'GeoPonto/Biometria/metricas_fases/fase8_3_1_ajuste_cirurgico/'
NUM_SAMPLES = 100  # Número de identidades para testar (ou menos se dataset for menor)

if not os.path.exists(EXTRACTOR_PATH):
    print(f"Erro: Extrator {EXTRACTOR_PATH} não encontrado.")
    exit()

if not os.path.exists(METRICS_DIR):
    os.makedirs(METRICS_DIR)

print(f"Carregando extrator: {EXTRACTOR_PATH}...")
try:
    extractor = tf.keras.models.load_model(EXTRACTOR_PATH)
except:
    print("Tentando carregar com custom_objects (caso o modelo inclua ArcFaceLayer)...")
    # Tenta carregar mesmo que não precise, só pra garantir
    extractor = tf.keras.models.load_model(EXTRACTOR_PATH, compile=False)

def preprocess_image(path):
    img = tf.io.read_file(path)
    img = tf.image.decode_jpeg(img, channels=3)
    img = tf.image.resize(img, IMG_SIZE)
    # img = img / 255.0  # Se o modelo foi treinado com normalização, descomentar. MobileNetV3 tem preprocessamento embutido geralmente.
    # O script de treino usou image_dataset_from_directory que por padrão não reescala (0-255 float32).
    # MobileNetV3 (se instanciada com include_top=False) espera input específico? 
    # Geralmente sim, tf.keras.applications.mobilenet_v3.preprocess_input espera [0, 255].
    # Vamos assumir que o modelo lida com isso ou o treino lidou.
    img = tf.expand_dims(img, axis=0)
    return img

# 2. Coleta de Amostras
identities = [d for d in os.listdir(DATASET_PATH) if os.path.isdir(os.path.join(DATASET_PATH, d))]
# Filtra identidades com menos de 2 fotos
valid_identities = []
for id_name in identities:
    id_path = os.path.join(DATASET_PATH, id_name)
    photos = [f for f in os.listdir(id_path) if f.endswith(('.jpg', '.jpeg', '.png'))]
    if len(photos) >= 2:
        valid_identities.append(id_name)

if len(valid_identities) < NUM_SAMPLES:
    print(f"Aviso: Apenas {len(valid_identities)} identidades válidas encontradas. Testando todas.")
    selected_identities = valid_identities
else:
    selected_identities = random.sample(valid_identities, NUM_SAMPLES)

pos_distances = []
neg_distances = []
verification_results = [] # [(img1, img2, label, distance), ...]

print(f"Processando {len(selected_identities)} identidades para teste de verificação...")

for i, id_name in enumerate(selected_identities):
    id_path = os.path.join(DATASET_PATH, id_name)
    photos = [os.path.join(id_path, f) for f in os.listdir(id_path) if f.endswith(('.jpg', '.jpeg', '.png'))]
    
    # --- Par Positivo (Mesma Pessoa) ---
    img1_path, img2_path = random.sample(photos, 2)
    try:
        emb1 = extractor.predict(preprocess_image(img1_path), verbose=0)[0]
        emb2 = extractor.predict(preprocess_image(img2_path), verbose=0)[0]
        dist_pos = euclidean(emb1, emb2)
        pos_distances.append(dist_pos)
        verification_results.append((id_name, id_name, 1, dist_pos))
        
        # --- Par Negativo (Pessoa Diferente) ---
        # Pegamos a foto 1 desta pessoa e comparamos com uma foto de outra pessoa aleatória
        other_id = random.choice([id for id in valid_identities if id != id_name])
        other_path = os.path.join(DATASET_PATH, other_id)
        other_photos = [f for f in os.listdir(other_path) if f.endswith(('.jpg', '.jpeg', '.png'))]
        if not other_photos: continue
        
        other_photo = os.path.join(other_path, random.choice(other_photos))
        
        emb_other = extractor.predict(preprocess_image(other_photo), verbose=0)[0]
        dist_neg = euclidean(emb1, emb_other)
        neg_distances.append(dist_neg)
        verification_results.append((id_name, other_id, 0, dist_neg))

    except Exception as e:
        print(f"Erro processando {id_name}: {e}")

    if (i+1) % 10 == 0:
        print(f"Progresso: {i+1}/{len(selected_identities)}...")

# 3. Análise de Resultados
if not pos_distances or not neg_distances:
    print("Erro: Nenhuma distância calculada.")
    exit()

pos_mean = np.mean(pos_distances)
neg_mean = np.mean(neg_distances)
pos_std = np.std(pos_distances)
neg_std = np.std(neg_distances)

# Threshold ideal (que maximiza acurácia neste set)
best_acc = 0
best_thresh = 0
min_d = min(min(pos_distances), min(neg_distances))
max_d = max(max(pos_distances), max(neg_distances))

for thresh in np.linspace(min_d, max_d, 100):
    tp = sum(d < thresh for d in pos_distances)
    tn = sum(d >= thresh for d in neg_distances)
    acc = (tp + tn) / (len(pos_distances) + len(neg_distances))
    if acc > best_acc:
        best_acc = acc
        best_thresh = thresh

print("\n" + "="*40)
print(f"RESULTADOS DO TESTE DE OURO (Fase 9.2)")
print("="*40)
print(f"Modelo: {EXTRACTOR_PATH}")
print(f"Distância Média (Mesma Pessoa): {pos_mean:.4f} (std: {pos_std:.4f})")
print(f"Distância Média (Pessoas Diferentes): {neg_mean:.4f} (std: {neg_std:.4f})")
print(f"Threshold Otimizado: {best_thresh:.4f}")
print(f"Acurácia Máxima (Neste Teste): {best_acc*100:.2f}%")
print("="*40)

# Salvar métricas em texto
with open(os.path.join(METRICS_DIR, 'resultados.txt'), 'w') as f:
    f.write(f"Modelo: {EXTRACTOR_PATH}\n")
    f.write(f"Distância Positiva: {pos_mean:.4f} +/- {pos_std:.4f}\n")
    f.write(f"Distância Negativa: {neg_mean:.4f} +/- {neg_std:.4f}\n")
    f.write(f"Threshold Otimizado: {best_thresh:.4f}\n")
    f.write(f"Acurácia: {best_acc*100:.2f}%\n")

# 4. Plotagem do Histograma
plt.figure(figsize=(12, 6))
plt.hist(pos_distances, bins=30, alpha=0.6, label='Mesma Pessoa (Pos)', color='green', density=True)
plt.hist(neg_distances, bins=30, alpha=0.6, label='Pessoas Diferentes (Neg)', color='red', density=True)
plt.axvline(best_thresh, color='blue', linestyle='--', label=f'Threshold ({best_thresh:.2f})')
plt.title(f'Distribuição de Distâncias - Fase 9.2 (Acc: {best_acc*100:.1f}%)')
plt.xlabel('Distância Euclidiana')
plt.ylabel('Densidade')
plt.legend()
plt.savefig(os.path.join(METRICS_DIR, 'histograma_verificacao.png'))
print(f"\nGráfico salvo em: {os.path.join(METRICS_DIR, 'histograma_verificacao.png')}")
