import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# ==============================================================================
# FASE 5: ROBUSTEZ À VIDA REAL (DEEP REFINEMENT)
# Estratégia: Injeção de Ruído e Variação de Luz para simular câmeras de celular.
# ==============================================================================

# 1. Configurações
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
DATASET_PATH = 'GeoPonto/Biometria/dataset_celeba_otimizado/' 
MODEL_BASE = 'modelo_fase4_refinado.keras' 
NEW_MODEL_PATH = 'modelo_fase5_robusto.keras'

# 2. Pipeline de Dados com DATA AUGMENTATION DE ROBUSTEZ (Detalhado no README)
augmentation_layer = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
    layers.RandomContrast(0.2),
    # README: Camadas essenciais para 'Vida Real'
    layers.RandomBrightness(0.2), # Simula fotos no sol ou escuro
    layers.GaussianNoise(0.1)     # Simula ruído de sensor de celular
])

train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.1, subset="training", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
)

# Aplicando Augmentation no Treino
train_ds = train_ds.map(lambda x, y: (augmentation_layer(x, training=True), y), num_parallel_calls=tf.data.AUTOTUNE)
train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.1, subset="validation", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

# 3. Carregamento do Modelo
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Carregando Modelo Refinado para Injeção de Robustez...")
    model = tf.keras.models.load_model(MODEL_BASE)
    # LR muito baixa para não destruir o aprendizado anterior, apenas adaptar ao ruído
    model.optimizer.learning_rate.assign(0.00005) 
else:
    print(f"\n[ERRO] Modelo base '{MODEL_BASE}' não encontrado.")
    exit()

# 4. Callbacks
checkpoint = callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=20, restore_best_weights=True)

# 5. Execução
print(f"\nIniciando Treinamento Fase 5 (Injeção de Ruído e Brilho)...")
model.fit(train_ds, validation_data=val_ds, epochs=100, callbacks=[checkpoint, early_stop])

# 6. Salvar Resultados
model.save('modelo_completo_fase5.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_fase5.keras')
