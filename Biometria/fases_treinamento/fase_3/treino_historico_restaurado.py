import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# 1. Caminhos e Configurações - FASE 4 V3: DEEP REFINEMENT
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 100 

DATASET_PATH = 'GeoPonto/Biometria/dataset_celeba_otimizado/'
MODEL_BASE = 'modelo_fase4_refinado_v2.keras' # Ponto de partida
NEW_MODEL_PATH = 'modelo_fase4_refinado_v3.keras'

# 2. Pipeline de Dados
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH,
    validation_split=0.1,
    subset="training",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH,
    validation_split=0.1,
    subset="validation",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

# 3. Augmentation Aplicado (Foco em Generalização Extrema)
augmentation_layer = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
    layers.RandomContrast(0.2),
    layers.RandomBrightness(0.2),
    layers.GaussianNoise(0.1)
])

train_ds = train_ds.map(
    lambda x, y: (augmentation_layer(x, training=True), y),
    num_parallel_calls=tf.data.AUTOTUNE
)

train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

# 4. Carregamento e Ajuste de Learning Rate
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Iniciando Fase V3 a partir de: {MODEL_BASE}")
    model = tf.keras.models.load_model(MODEL_BASE)
    
    # Reiniciando a LR para um valor ligeiramente mais alto (0.00005)
    # Isso permite que o modelo saia de platôs da fase anterior.
    model.optimizer.learning_rate.assign(0.00005) 
    print(f"Taxa de aprendizado REINICIADA para: {model.optimizer.learning_rate.numpy()}")
else:
    print(f"\n[ERRO] Modelo '{MODEL_BASE}' não encontrado na raiz.")
    exit()

# 5. Callbacks de Monitoramento
checkpoint = callbacks.ModelCheckpoint(
    NEW_MODEL_PATH, 
    monitor='val_accuracy',
    save_best_only=True,
    verbose=1
)

reduce_lr = callbacks.ReduceLROnPlateau(
    monitor='val_loss', 
    factor=0.5, 
    patience=7, # Mais paciência que na V2
    min_lr=1e-8,
    verbose=1
)

early_stop = callbacks.EarlyStopping(
    monitor='val_loss', 
    patience=25, # Longa paciência para refinamento profundo
    restore_best_weights=True
)

# 6. Execução do Refinamento V3
print(f"\nIniciando DEEP REFINEMENT (Fase 4 -> V3)...")
print(f"O modelo final será salvo como '{NEW_MODEL_PATH}'")

history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=[checkpoint, early_stop, reduce_lr]
)

# 7. Exportação dos Resultados Finais do Refinamento
model.save('modelo_fase4_v3_completo.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_v3.keras')

print("\n" + "="*60)
print("DEEP REFINEMENT V3 FINALIZADO!")
print(f"Pesos salvos em: {NEW_MODEL_PATH}")
print("="*60)
