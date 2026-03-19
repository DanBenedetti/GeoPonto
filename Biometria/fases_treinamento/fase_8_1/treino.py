import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# 1. Configurações - FASE 8.1: REFINAMENTO ESPECIALISTA (250 Classes)
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 100 

DATASET_PATH = 'GeoPonto/Biometria/dataset_especialista_250/'
MODEL_BASE = 'modelo_fase8_completo.keras' # Ponto de partida
NEW_MODEL_PATH = 'modelo_fase8_refinado_v8_1.keras'

# 2. Pipeline de Dados
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH,
    validation_split=0.15,
    subset="training",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH,
    validation_split=0.15,
    subset="validation",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

# Augmentation Reforçado (Foco em Robustez)
augmentation_layer = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.25), # Aumentado levemente
    layers.RandomZoom(0.25),     # Aumentado levemente
    layers.RandomContrast(0.2),
    layers.RandomBrightness(0.3), # Mais variação de luz
    layers.GaussianNoise(0.15)    # Mais ruído para simular câmeras mobile ruins
])

train_ds = train_ds.map(lambda x, y: (augmentation_layer(x, training=True), y), num_parallel_calls=tf.data.AUTOTUNE)
train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

# 3. Carregamento e Ajuste de Learning Rate
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Iniciando Refinamento Especialista a partir de: {MODEL_BASE}")
    model = tf.keras.models.load_model(MODEL_BASE)
    
    # Reiniciando a LR para 0.00005 para buscar novos mínimos
    model.optimizer.learning_rate.assign(0.00005) 
    print(f"Taxa de aprendizado REINICIADA para: {model.optimizer.learning_rate.numpy()}")
else:
    print(f"\n[ERRO] Modelo '{MODEL_BASE}' não encontrado na raiz.")
    exit()

# 4. Callbacks
checkpoint = callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1)
reduce_lr = callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=8, min_lr=1e-8, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=25, restore_best_weights=True)

# 5. Execução do Refinamento V8.1
print(f"\nIniciando DEEP SPECIALIST REFINEMENT (V8 -> V8.1)...")
history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=[checkpoint, early_stop, reduce_lr])

# 6. Exportação Final
model.save('modelo_fase8_v8_1_completo.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_v8_1.keras')

print("\n--- REFINAMENTO ESPECIALISTA V8.1 FINALIZADO ---")
