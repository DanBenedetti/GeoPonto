import tensorflow as tf
import os

# --- Configurações ---
MODEL_PATH = 'modelo_final_homologado.keras'
TFLITE_PATH = 'geoponto_extractor.tflite'

if not os.path.exists(MODEL_PATH):
    # Tenta subir um nível se estiver rodando de dentro da pasta Biometria
    if os.path.exists('GeoPonto/Biometria/' + MODEL_PATH):
        MODEL_PATH = 'GeoPonto/Biometria/' + MODEL_PATH
    else:
        print(f"ERRO: Modelo {MODEL_PATH} não encontrado!")
        exit(1)

print(f"Carregando modelo Keras: {MODEL_PATH}...")
try:
    model = tf.keras.models.load_model(MODEL_PATH)
except Exception as e:
    print(f"Erro ao carregar modelo: {e}")
    exit(1)

print("Iniciando conversão para TFLite (Otimizado)...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# Otimizações para mobile (mantendo precisão Float32 para não perder acurácia)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float32]

tflite_model = converter.convert()

print(f"Salvando modelo TFLite em: {TFLITE_PATH}...")
with open(TFLITE_PATH, 'wb') as f:
    f.write(tflite_model)

print("\n--- CONVERSÃO FINALIZADA COM SUCESSO ---")
print(f"Tamanho do modelo original (.keras): {os.path.getsize(MODEL_PATH) / (1024*1024):.2f} MB")
print(f"Tamanho do modelo otimizado (.tflite): {os.path.getsize(TFLITE_PATH) / (1024*1024):.2f} MB")
