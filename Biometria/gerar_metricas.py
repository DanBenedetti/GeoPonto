import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix
import os

# 1. Configurações
IMG_SIZE = (224, 224)
BATCH_SIZE = 32

print("Carregando modelo e dados de validação...")
model = tf.keras.models.load_model('modelo_classificacao.keras', safe_mode=False)

# Carregar apenas o conjunto de validação
val_ds = tf.keras.utils.image_dataset_from_directory(
    'dataset_treino/',
    validation_split=0.2,
    subset="validation",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical',
    shuffle=False # IMPORTANTE: shuffle=False para a matriz de confusão bater com os nomes
)

# Pegar os nomes das classes (nomes das pessoas)
class_names = val_ds.class_names

# 2. Realizar Predições
print("Avaliando o modelo (isso pode levar um momento)...")
y_true = []
y_pred = []

for images, labels in val_ds:
    preds = model.predict(images, verbose=0)
    y_true.extend(np.argmax(labels, axis=1))
    y_pred.extend(np.argmax(preds, axis=1))

y_true = np.array(y_true)
y_pred = np.array(y_pred)

# 3. Gerar Relatório de Classificação (Precision, Recall, F1)
# Usamos labels=range(len(class_names)) para garantir que o sklearn aceite todos os nomes
report = classification_report(y_true, y_pred, labels=range(len(class_names)), target_names=class_names, output_dict=True)
# Vamos imprimir apenas a média geral para não poluir o terminal
print("\n--- RESUMO DA PERFORMANCE ---")
print(f"Acurácia Geral: {report['accuracy']:.4f}")
print(f"Precisão Média (Macro): {report['macro avg']['precision']:.4f}")
print(f"Recall Médio (Macro): {report['macro avg']['recall']:.4f}")
print(f"F1-Score Médio (Macro): {report['macro avg']['f1-score']:.4f}")

# 4. Matriz de Confusão
# Como são 158 classes, vamos apenas gerar a matriz e salvar como imagem, 
# pois no terminal é impossível de ler.
cm = confusion_matrix(y_true, y_pred)
plt.figure(figsize=(20, 20))
sns.heatmap(cm, annot=False, cmap='Blues')
plt.title('Matriz de Confusão (158 Classes)')
plt.xlabel('Predito')
plt.ylabel('Real')
plt.savefig('matriz_confusao.png')
print("\nGráfico 'matriz_confusao.png' salvo com sucesso!")

# 5. Salvar Relatório Completo em TXT para o seu TCC
with open('relatorio_academico.txt', 'w') as f:
    f.write("RELATÓRIO DE DESEMPENHO - MODELO GEOPONTO\n")
    f.write("="*40 + "\n")
    # Adicionado labels=range(len(class_names)) aqui também
    f.write(classification_report(y_true, y_pred, labels=range(len(class_names)), target_names=class_names))

print("Relatório detalhado salvo em 'relatorio_academico.txt'.")
