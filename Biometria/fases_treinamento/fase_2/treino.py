import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
import os

# ==============================================================================
# FASE 2: OTIMIZAÇÃO E LIMPEZA DE DATASET (1.000 Identidades Densas)
# Estratégia: Focar em classes com muitos exemplos para aprender traços invariantes.
# ==============================================================================

# 1. Configurações
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
NUM_CLASSES = 1000 

DATASET_PATH = 'GeoPonto/Biometria/dataset_celeba_otimizado/' # Filtrado >30 fotos
MODEL_BASE = 'modelo_fase1_inicial.keras' 
NEW_MODEL_PATH = 'modelo_fase2_otimizado.keras'

# 2. Pipeline de Dados com PREFETCH (Otimização detalhada no README)
print("\n[SETUP] Configurando pipeline de dados com PREFETCH...")
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.1, subset="training", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE) # Otimização de leitura de disco

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.1, subset="validation", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

# 3. Carregamento e Adaptação do Modelo (Evolutivo)
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Carregando progresso da Fase 1...")
    model_prev = tf.keras.models.load_model(MODEL_BASE)
    
    # Substituindo a camada final de classificação (10k -> 1k)
    embedding_layer = model_prev.get_layer("embedding_output").output
    x = layers.UnitNormalization(axis=1)(embedding_layer)
    outputs = layers.Dense(NUM_CLASSES, activation='softmax')(x)
    model = models.Model(inputs=model_prev.input, outputs=outputs)
else:
    print(f"\n[ERRO] Modelo base '{MODEL_BASE}' não encontrado.")
    exit()

model.compile(optimizer=optimizers.Adam(learning_rate=0.001), loss='categorical_crossentropy', metrics=['accuracy'])

# 4. Callbacks
checkpoint = callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True)

# 5. Execução
print(f"\nIniciando Treinamento Fase 2 (Filtragem para 1.000 Classes Densas)...")
model.fit(train_ds, validation_data=val_ds, epochs=100, callbacks=[checkpoint, early_stop])

# 6. Salvar Resultados
model.save('modelo_completo_fase2.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_fase2.keras')
