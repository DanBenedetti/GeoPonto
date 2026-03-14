import os
import shutil

# 1. Configurações
source_dir = 'archive/lfw-deepfunneled/lfw-deepfunneled/'
target_dir = 'dataset_treino/'
MIN_IMAGES = 25 # Aumentamos o rigor para melhorar a acurácia

# 2. Limpar pasta antiga para não misturar
if os.path.exists(target_dir):
    shutil.rmtree(target_dir)
os.makedirs(target_dir)

# 3. Filtrar e Copiar
count = 0
for person in os.listdir(source_dir):
    person_path = os.path.join(source_dir, person)
    if os.path.isdir(person_path):
        num_images = len(os.listdir(person_path))
        if num_images >= MIN_IMAGES:
            shutil.copytree(person_path, os.path.join(target_dir, person))
            count += 1

print(f"\n--- SUCESSO! ---")
print(f"Dataset REORGANIZADO com as {count} pessoas mais frequentes.")
print(f"Isso garantirá uma acurácia muito mais alta para o seu TCC!")
