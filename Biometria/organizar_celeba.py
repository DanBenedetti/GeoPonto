import os
import shutil
from tqdm import tqdm

# Caminhos
BASE_DIR = 'GeoPonto/Biometria/archive/'
IMG_DIR = os.path.join(BASE_DIR, 'img_align_celeba/img_align_celeba/')
IDENTITY_FILE = os.path.join(BASE_DIR, 'identity_CelebA.txt')
OUTPUT_DIR = 'GeoPonto/Biometria/dataset_celeba_organizado/'

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

def organize_celeba():
    print("Lendo mapeamento de identidades...")
    with open(IDENTITY_FILE, 'r') as f:
        lines = f.readlines()

    print(f"Organizando {len(lines)} imagens em pastas por ID...")
    
    # Usamos um dicionário para agrupar fotos por ID antes de mover
    id_map = {}
    for line in lines:
        parts = line.strip().split()
        if len(parts) == 2:
            img_name, person_id = parts
            if person_id not in id_map:
                id_map[person_id] = []
            id_map[person_id].append(img_name)

    # Cria as pastas e move as fotos
    for person_id, images in tqdm(id_map.items(), desc="Criando pastas"):
        person_folder = os.path.join(OUTPUT_DIR, f"p_{person_id}")
        if not os.path.exists(person_folder):
            os.makedirs(person_folder)
        
        for img_name in images:
            src = os.path.join(IMG_DIR, img_name)
            dst = os.path.join(person_folder, img_name)
            
            # Verificamos se a imagem existe antes de tentar mover
            if os.path.exists(src):
                # Usamos cópia para segurança, ou move para economizar espaço
                # Como o usuário tem 2TB, vamos de cópia (shutil.copy) para evitar deletar o original por erro
                shutil.copy(src, dst)

    print(f"\nConcluído! Dataset organizado em: {OUTPUT_DIR}")

if __name__ == "__main__":
    try:
        organize_celeba()
    except Exception as e:
        print(f"Erro na organização: {e}")
