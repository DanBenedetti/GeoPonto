import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# 1. Caminhos e Configurações
# O script assume ser executado da raiz do projeto: python GeoPonto/Biometria/treinar_modelo_refinado_v2.py
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EMBEDDING_SIZE = 128
EPOCHS = 100 

DATASET_PATH = 'GeoPonto/Biometria/dataset_celeba_otimizado/'
MODEL_PATH = 'modelo_fase4_final.keras' # Localizado na raiz
NEW_MODEL_PATH = 'modelo_fase4_refinado_v2.keras'

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

# 3. Augmentation Aplicado no Dataset (Garante que Brilho e Ruído entrem no treino)
augmentation_layer = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
    layers.RandomContrast(0.2),
    layers.RandomBrightness(0.2),
    layers.GaussianNoise(0.1)
])

# Aplicando augmentation apenas no treino
train_ds = train_ds.map(
    lambda x, y: (augmentation_layer(x, training=True), y),
    num_parallel_calls=tf.data.AUTOTUNE
)

train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

# 4. Carregamento do Modelo
if os.path.exists(MODEL_PATH):
    print(f"\n[RESUME] Carregando pesos da Fase 4 de: {MODEL_PATH}")
    model = tf.keras.models.load_model(MODEL_PATH)
    
    # Ajuste fino da LR
    model.optimizer.learning_rate.assign(0.00005) 
    print(f"LR de refinamento: {model.optimizer.learning_rate.numpy()}")
else:
    print(f"\n[ERRO] Arquivo '{MODEL_PATH}' não encontrado na raiz.")
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
    patience=5, 
    min_lr=1e-7,
    verbose=1
)

early_stop = callbacks.EarlyStopping(
    monitor='val_loss', 
    patience=15, 
    restore_best_weights=True
)

# 6. Execução do Refinamento
print(f"\nIniciando Refinamento do Modelo (Fase 4 -> V2)...")
print(f"O modelo melhorado será salvo como '{NEW_MODEL_PATH}'")

history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=[checkpoint, early_stop, reduce_lr]
)

# 7. Exportação Final
model.save('modelo_fase4_v2_completo.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_v2.keras')

print("\n--- REFINAMENTO V2 FINALIZADO COM SUCESSO ---")
