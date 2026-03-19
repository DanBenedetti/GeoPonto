import os
import subprocess

# Lista das fotos representantes
fotos = {
    "Danilo": "GeoPonto/Biometria/testeouro/Danilo1.jpg",
    "Gabriel": "GeoPonto/Biometria/testeouro/Gabriel1.jpg",
    "Rangel": "GeoPonto/Biometria/testeouro/Rangel1.jpg",
    "Beckham": "GeoPonto/Biometria/testeouro/David_Beckham_0004.jpg",
    "Chavez": "GeoPonto/Biometria/testeouro/Hugo_Chavez_0019.jpg"
}

# Threshold configurado no comparar_faces.py
THRESHOLD = 1.80

print(f"{'PAR DE TESTE':<30} | {'DISTÂNCIA':<10} | {'RESULTADO':<20} | {'STATUS'}")
print("-" * 85)

# Matriz de comparação (pares solicitados)
pares = [
    ("Danilo", "Danilo"), ("Danilo", "Rangel"), ("Danilo", "Gabriel"), ("Danilo", "Beckham"), ("Danilo", "Chavez"),
    ("Rangel", "Rangel"), ("Rangel", "Gabriel"), ("Rangel", "Beckham"), ("Rangel", "Chavez"),
    ("Gabriel", "Gabriel"), ("Gabriel", "Beckham"), ("Gabriel", "Chavez"),
    ("Beckham", "Beckham"), ("Beckham", "Chavez"),
    ("Chavez", "Chavez")
]

for p1, p2 in pares:
    # Executa o comparar_faces.py e captura a saída
    cmd = f"GeoPonto/Biometria/venv/bin/python GeoPonto/Biometria/comparar_faces.py '{fotos[p1]}' '{fotos[p2]}'"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    
    # Extrai a distância da saída (ex: "Distância entre as fotos: 1.7478")
    dist = 0.0
    for line in result.stdout.split('\n'):
        if "Distância entre as fotos:" in line:
            dist = float(line.split(":")[1].strip())
            break
            
    acesso = "PERMITIDO ✅" if dist < THRESHOLD else "NEGADO ❌"
    
    # Valida se o acesso está correto
    status = "CORRETO" if (p1 == p2 and dist < THRESHOLD) or (p1 != p2 and dist >= THRESHOLD) else "INCORRETO"
    
    # Formatação visual
    print(f"{p1 + ' vs ' + p2:<30} | {dist:<10.4f} | {acesso:<20} | {status}")

print("-" * 85)
