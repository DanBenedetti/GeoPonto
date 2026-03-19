import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
import sys

# 1. Carregar o Modelo Extrator V8.3.1 (Ajuste Cirúrgico Final)
MODEL_PATH = 'geoponto_extractor_v8_3_1.keras'
THRESHOLD = 1.80 # Calibrado para fotos da vida real (Danilo/Gabriel/Rangel)

try:
    model = tf.keras.models.load_model(MODEL_PATH)
    print(f"Sucesso: Extrator {MODEL_PATH} carregado com sucesso.")
except Exception as e:
    print(f"ERRO: O modelo '{MODEL_PATH}' não foi encontrado na raiz.")
    sys.exit()

def preprocess_image(path):
    # Usa a mesma lógica do treinamento para consistência de resultados
    img = tf.io.read_file(path)
    img = tf.image.decode_jpeg(img, channels=3)
    img = tf.image.resize(img, (224, 224))
    img = tf.expand_dims(img, axis=0)
    return img

def comparar(path1, path2):
    # Gera os embeddings usando as imagens pré-processadas
    v1 = model.predict(preprocess_image(path1), verbose=0)[0]
    v2 = model.predict(preprocess_image(path2), verbose=0)[0]
    
    # Calcula a Distância Euclidiana (Quanto menor, mais parecido)
    from scipy.spatial.distance import euclidean
    distancia = euclidean(v1, v2)
    
    print(f"\nDistância entre as fotos: {distancia:.4f}")
    
    if distancia < THRESHOLD:
        print("RESULTADO: MESMA PESSOA (Acesso Permitido) ✅")
    else:
        print("RESULTADO: PESSOAS DIFERENTES (Acesso Negado) ❌")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python comparar_faces.py foto1.jpg foto2.jpg")
    else:
        comparar(sys.argv[1], sys.argv[2])
