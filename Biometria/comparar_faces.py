import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
import sys

# 1. Carregar o Modelo Extrator
try:
    model = tf.keras.models.load_model('geoponto_extractor.keras', safe_mode=False)
except:
    print("ERRO: O modelo 'geoponto_extractor.keras' ainda não foi criado. Rode o 'treinar_modelo.py' primeiro.")
    sys.exit()

def get_embedding(img_path):
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    # Importante: MobileNetV3 espera imagens entre 0 e 255 ou pré-processadas
    # Se você usou weights='imagenet', o preprocess_input é recomendado
    img_array = tf.keras.applications.mobilenet_v3.preprocess_input(img_array)
    
    embedding = model.predict(img_array)
    return embedding / np.linalg.norm(embedding) # Normaliza o vetor

def comparar(path1, path2):
    v1 = get_embedding(path1)
    v2 = get_embedding(path2)
    
    # Calcula a Distância Euclidiana (Quanto menor, mais parecido)
    distancia = np.linalg.norm(v1 - v2)
    
    print(f"\nDistância entre as fotos: {distancia:.4f}")
    
    # Limiar Sugerido (Threshold): Ajustado para 1.1 para equilibrar reconhecimento de terceiros
    LIMIAR = 1.1
    
    if distancia < LIMIAR:
        print("RESULTADO: MESMA PESSOA (Acesso Permitido) ✅")
    else:
        print("RESULTADO: PESSOAS DIFERENTES (Acesso Negado) ❌")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python comparar_faces.py foto1.jpg foto2.jpg")
    else:
        comparar(sys.argv[1], sys.argv[2])
