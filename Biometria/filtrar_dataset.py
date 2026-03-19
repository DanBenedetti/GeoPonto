import os
import shutil
from tqdm import tqdm

# Configurações
BASE_DIR = 'GeoPonto/Biometria/archive/'
IMG_DIR = os.path.join(BASE_DIR, 'img_align_celeba/img_align_celeba/')
IDENTITY_FILE = os.path.join(BASE_DIR, 'identity_CelebA.txt')
OUTPUT_DIR = 'GeoPonto/Biometria/dataset_celeba_otimizado/'

def filtrar_dataset():
    print("--- INICIANDO FILTRAGEM E OTIMIZAÇÃO DO DATASET ---")
    
    if not os.path.exists(IDENTITY_FILE):
        print(f"Erro: Arquivo {IDENTITY_FILE} não encontrado.")
        return

    # 1. Ler o mapeamento e contar fotos por ID
    id_map = {}
    with open(IDENTITY_FILE, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) == 2:
                img_name, person_id = parts
                if person_id not in id_map:
                    id_map[person_id] = []
                id_map[person_id].append(img_name)

    # 2. Filtrar IDs com pelo menos 25 fotos
    candidatos = {pid: imgs for pid, imgs in id_map.items() if len(imgs) >= 25}
    print(f"Total de identidades com >= 25 fotos: {len(candidatos)}")

    # 3. Pegar os top 1000 IDs (ou todos se houver menos de 1000)
    top_ids = sorted(candidatos.items(), key=lambda x: len(x[1]), reverse=True)[:1000]
    print(f"Selecionando as {len(top_ids)} identidades com maior densidade de dados.")

    # 4. Limpar pasta de destino se já existir para evitar lixo
    if os.path.exists(OUTPUT_DIR):
        print(f"Limpando pasta anterior: {OUTPUT_DIR}")
        shutil.rmtree(OUTPUT_DIR)
    os.makedirs(OUTPUT_DIR)

    # 5. Copiar as imagens
    total_imagens = sum(len(imgs) for pid, imgs in top_ids)
    pbar = tqdm(total=total_imagens, desc="Copiando imagens otimizadas")
    
    for pid, imgs in top_ids:
        person_folder = os.path.join(OUTPUT_DIR, f"p_{pid}")
        os.makedirs(person_folder, exist_ok=True)
        
        for img_name in imgs:
            src = os.path.join(IMG_DIR, img_name)
            dst = os.path.join(person_folder, img_name)
            if os.path.exists(src):
                shutil.copy(src, dst)
            pbar.update(1)
    
    pbar.close()
    print(f"\n--- SUCESSO! ---")
    print(f"Dataset otimizado criado em: {OUTPUT_DIR}")
    print(f"Total de Identidades: {len(top_ids)}")
    print(f"Total de Imagens: {total_imagens}")

if __name__ == "__main__":
    filtrar_dataset()
