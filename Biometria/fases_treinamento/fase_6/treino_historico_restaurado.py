import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# 1. Configurações - FASE 6: ESPECIALIZAÇÃO ELITE (250 Classes)
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EMBEDDING_SIZE = 128
EPOCHS = 100 

DATASET_PATH = 'GeoPonto/Biometria/dataset_especialista_250/'
NUM_CLASSES = 250
MODEL_BASE = 'modelo_fase5_robusto.keras' # Ponto de partida
NEW_MODEL_PATH = 'modelo_fase6_especialista.keras'

# 2. Pipeline de Dados
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.15, subset="training", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.15, subset="validation", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

# 3. Augmentation Robusto
augmentation_layer = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
])

# 4. Carregamento e Adaptação do Classificador
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Adaptando Modelo da Fase 5 para 250 classes Elite...")
    base_full_model = tf.keras.models.load_model(MODEL_BASE)
    
    # Injetando Dropout (0.4) para evitar overfit na base menor de 250 classes
    try:
        embedding_layer = base_full_model.get_layer("embedding_output").output
        x = layers.Dropout(0.4)(embedding_layer) # Técnica de reserva para robustez
        x = layers.UnitNormalization(axis=1)(x)
        outputs = layers.Dense(NUM_CLASSES, activation='softmax', name="elite_classifier")(x)
        model = models.Model(inputs=base_full_model.input, outputs=outputs)
    except Exception as e:
        print(f"Erro na adaptação: {e}")
        exit()
else:
    print(f"\n[ERRO] Modelo base '{MODEL_BASE}' não encontrado.")
    exit()

model.compile(optimizer=optimizers.Adam(learning_rate=0.0001), loss='categorical_crossentropy', metrics=['accuracy'])

# 5. Callbacks
checkpoint = callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True)

# 6. Execução
print(f"\nIniciando Treinamento Fase 6 (Especialização Elite 250)...")
history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=[checkpoint, early_stop])

# 7. Salvar Resultados
model.save('modelo_completo_fase6.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_fase6.keras')
