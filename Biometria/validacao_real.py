import tensorflow as tf
import numpy as np
import os
import matplotlib.pyplot as plt
from scipy.spatial.distance import euclidean
from itertools import combinations

# 1. Configurações
IMG_SIZE = (224, 224)
EXTRACTOR_PATH = 'geoponto_extractor_v8_3_1.keras'
TEST_DIR = 'GeoPonto/Biometria/testeouro/'
METRICS_DIR = 'GeoPonto/Biometria/metricas_fases/validacao_vida_real/'

if not os.path.exists(METRICS_DIR):
    os.makedirs(METRICS_DIR)

print(f"Carregando extrator para Validação Real: {EXTRACTOR_PATH}...")
extractor = tf.keras.models.load_model(EXTRACTOR_PATH, compile=False)

def preprocess_image(path):
    img = tf.io.read_file(path)
    img = tf.image.decode_jpeg(img, channels=3)
    img = tf.image.resize(img, IMG_SIZE)
    img = tf.expand_dims(img, axis=0)
    return img

# 2. Agrupar fotos por pessoa baseada no nome do arquivo
# Espera nomes como "Danilo1.jpg", "David_Beckham_0001.jpg", "Gabriel 1.jpg"
files = [f for f in os.listdir(TEST_DIR) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
people = {}

for f in files:
    # Lógica simples: pegar a parte alfabética do início do nome
    # Para David_Beckham, pegamos o prefixo antes dos números
    name = "".join([c for c in f.split('.')[0] if not c.isdigit()]).strip()
    # Limpar espaços e underscores extras do final (ex: "David_Beckham_" -> "David_Beckham")
    name = name.rstrip('_').rstrip()
    
    if name not in people:
        people[name] = []
    people[name].append(os.path.join(TEST_DIR, f))

print(f"\nPessoas detectadas no teste: {list(people.keys())}")
for name, photos in people.items():
    print(f" - {name}: {len(photos)} fotos")

# 3. Extrair Embeddings
print("\nExtraindo embeddings...")
embeddings = {}
for name, photos in people.items():
    embeddings[name] = [extractor.predict(preprocess_image(p), verbose=0)[0] for p in photos]

# 4. Calcular Distâncias
pos_distances = []
neg_distances = []

# Pares Positivos (Mesma pessoa)
for name, embs in embeddings.items():
    if len(embs) < 2: continue
    for e1, e2 in combinations(embs, 2):
        pos_distances.append(euclidean(e1, e2))

# Pares Negativos (Pessoas diferentes)
names = list(embeddings.keys())
for n1, n2 in combinations(names, 2):
    for e1 in embeddings[n1]:
        for e2 in embeddings[n2]:
            neg_distances.append(euclidean(e1, e2))

# 5. Resultados
pos_mean = np.mean(pos_distances)
neg_mean = np.mean(neg_distances)
pos_std = np.std(pos_distances)
neg_std = np.std(neg_distances)

# Threshold Otimizado (Balanced Accuracy - Melhor para datasets desbalanceados)
best_bal_acc = 0
best_thresh = 0
all_dists = pos_distances + neg_distances
for thresh in np.linspace(min(all_dists), max(all_dists), 200):
    tpr = sum(d < thresh for d in pos_distances) / len(pos_distances) if len(pos_distances) > 0 else 0
    tnr = sum(d >= thresh for d in neg_distances) / len(neg_distances) if len(neg_distances) > 0 else 0
    bal_acc = (tpr + tnr) / 2
    if bal_acc > best_bal_acc:
        best_bal_acc = bal_acc
        best_thresh = thresh

print("\n" + "="*50)
print("RELATÓRIO DE VALIDAÇÃO EM AMBIENTE REAL")
print("="*50)
print(f"Acurácia Balanceada: {best_bal_acc*100:.2f}%")
print(f"Threshold Sugerido: {best_thresh:.4f}")
print("-"*50)
print(f"Distância Média Positiva: {pos_mean:.4f} (Desvio: {pos_std:.4f})")
print(f"Distância Média Negativa: {neg_mean:.4f} (Desvio: {neg_std:.4f})")
print("="*50)

# Salvar Histograma
plt.figure(figsize=(10, 6))
plt.hist(pos_distances, bins=20, alpha=0.5, label='Mesma Pessoa', color='green', density=True)
plt.hist(neg_distances, bins=20, alpha=0.5, label='Pessoas Diferentes', color='red', density=True)
plt.axvline(best_thresh, color='blue', linestyle='--', label=f'Threshold ({best_thresh:.2f})')
plt.title(f'Validação Vida Real - Acurácia: {best_acc*100:.1f}%')
plt.xlabel('Distância Euclidiana')
plt.ylabel('Densidade')
plt.legend()
plt.savefig(os.path.join(METRICS_DIR, 'histograma_real.png'))
print(f"\nGráfico salvo em: {os.path.join(METRICS_DIR, 'histograma_real.png')}")
