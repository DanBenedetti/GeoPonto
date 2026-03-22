import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
import os

# ==============================================================================
# FASE 6: ESPECIALIZAÇÃO ELITE (250 Classes)
# Estratégia: Foco em Dataset Elite e técnica de redundância (Dropout 0.4).
# ==============================================================================

# 1. Configurações
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
NUM_CLASSES = 250
DATASET_PATH = 'GeoPonto/Biometria/dataset_especialista_250/'
MODEL_BASE = 'modelo_fase5_robusto.keras' 
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

# 3. Carregamento e Especialização
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Adaptando para as 250 identidades Elite...")
    base_full_model = tf.keras.models.load_model(MODEL_BASE)
    
    # Detalhado no README: Dropout para redundância interna
    embedding_layer = base_full_model.get_layer("embedding_output").output
    x = layers.Dropout(0.4)(embedding_layer) 
    x = layers.UnitNormalization(axis=1)(x)
    outputs = layers.Dense(NUM_CLASSES, activation='softmax', name="elite_classifier")(x)
    model = models.Model(inputs=base_full_model.input, outputs=outputs)
else:
    print(f"\n[ERRO] Modelo base '{MODEL_BASE}' não encontrado.")
    exit()

model.compile(optimizer=optimizers.Adam(learning_rate=0.0001), loss='categorical_crossentropy', metrics=['accuracy'])

# 4. Callbacks
checkpoint = callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True)

# 5. Execução
print(f"\nIniciando Treinamento Fase 6 (Especialização Elite 250)...")
model.fit(train_ds, validation_data=val_ds, epochs=100, callbacks=[checkpoint, early_stop])

# 6. Exportação
model.save('modelo_completo_fase6.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_fase6.keras')
