import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# 1. Configurações - FASE 8: ESPECIALISTA ULTRA-DENSO (250 Classes)
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 100 

DATASET_PATH = 'GeoPonto/Biometria/dataset_especialista_250/'
MODEL_BASE = 'modelo_fase4_refinado_v3.keras' # Ponto de partida
NEW_MODEL_PATH = 'modelo_fase8_especialista.keras'

# 2. Pipeline de Dados (Foco em Qualidade)
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

# Augmentation Robusto
augmentation_layer = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
    layers.RandomContrast(0.2),
    layers.RandomBrightness(0.2),
    layers.GaussianNoise(0.1)
])

train_ds = train_ds.map(lambda x, y: (augmentation_layer(x, training=True), y), num_parallel_calls=tf.data.AUTOTUNE)
train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

# 3. Carregamento e Adaptação do Modelo
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Carregando Modelo Base V3 para Adaptação Especialista...")
    base_full_model = tf.keras.models.load_model(MODEL_BASE)
    
    # Pegamos o extrator (até a camada de embedding)
    # Procuramos a camada 'embedding_output'
    try:
        embedding_layer = base_full_model.get_layer("embedding_output").output
        # Criamos o novo modelo preservando as camadas anteriores
        x = layers.UnitNormalization(axis=1)(embedding_layer)
        outputs = layers.Dense(250, activation='softmax', name="new_classifier")(x)
        model = models.Model(inputs=base_full_model.input, outputs=outputs)
        print("Nova camada de saída (250 classes) injetada com sucesso.")
    except Exception as e:
        print(f"Erro ao adaptar o modelo: {e}")
        exit()
    
    # Congelamos as camadas iniciais para focar no novo classificador primeiro
    # Vamos congelar os primeiros 100 layers (MobileNetV3 tem cerca de 150)
    for layer in model.layers[:100]:
        layer.trainable = False
    print("Camadas iniciais CONGELADAS para estabilidade.")

    model.compile(
        optimizer=optimizers.Adam(learning_rate=0.0001), 
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
else:
    print(f"\n[ERRO] Modelo '{MODEL_BASE}' não encontrado.")
    exit()

# 4. Callbacks
checkpoint = callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1)
reduce_lr = callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5, min_lr=1e-7, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True)

# 5. Execução (Fase 1: Warmup do Classificador)
print(f"\nIniciando Treino Especialista (Fase 1: Warmup)...")
history = model.fit(train_ds, validation_data=val_ds, epochs=20, callbacks=[checkpoint, early_stop, reduce_lr])

# 6. Descongelamento Total (Fine-Tuning Profundo)
print(f"\nDESCONGELANDO camadas para Fine-Tuning Total...")
for layer in model.layers:
    layer.trainable = True

model.compile(
    optimizer=optimizers.Adam(learning_rate=0.00001), # LR Microscópica para Fine-Tuning
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

print(f"\nIniciando Treino Especialista (Fase 2: Fine-Tuning)...")
history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=[checkpoint, early_stop, reduce_lr])

# 7. Exportação Final
model.save('modelo_fase8_completo.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_v8.keras')

print("\n--- ESPECIALIZAÇÃO V8 FINALIZADA COM SUCESSO ---")
