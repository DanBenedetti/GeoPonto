import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
import os

# ==============================================================================
# FASE 1: INICIALIZAÇÃO MASSIVA (COLD START)
# Estratégia: Treinar do ZERO com 10.177 identidades para quebrar a inércia.
# ==============================================================================

# 1. Configurações Profissionais
IMG_SIZE = (224, 224)
BATCH_SIZE = 32 
EMBEDDING_SIZE = 128
EPOCHS = 100 

DATASET_PATH = 'GeoPonto/Biometria/dataset_celeba_completo/' # 10k identidades
NUM_CLASSES = 10177 

# 2. Pipeline de Dados
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.05, subset="training", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.05, subset="validation", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
)

# 3. Arquitetura MobileNetV3 (TREINAMENTO DO ZERO - REQUISITO PI)
print("\n[START] Criando Modelo MobileNetV3 (weights=None)...")
base_model = tf.keras.applications.MobileNetV3Small(
    input_shape=(224, 224, 3),
    include_top=False,
    weights=None # Crucial para o PI: treinamento do zero
)

inputs = tf.keras.Input(shape=(224, 224, 3))
x = layers.Rescaling(1./255)(inputs)
x = base_model(x)
x = layers.GlobalAveragePooling2D()(x) # Detalhado no README: Evita overfit e reduz conexões
x = layers.BatchNormalization()(x)

embedding_layer = layers.Dense(EMBEDDING_SIZE, name="embedding_output")(x)
x = layers.UnitNormalization(axis=1)(embedding_layer)

outputs = layers.Dense(NUM_CLASSES, activation='softmax')(x)
model = models.Model(inputs=inputs, outputs=outputs)

# 4. Compilação (Otimizador Adam e CategoricalCrossentropy)
model.compile(
    optimizer=optimizers.Adam(learning_rate=0.001), # Detalhado no README: Piloto automático para início rápido
    loss='categorical_crossentropy', # Detalhado no README: Padrão para classificação massiva
    metrics=['accuracy']
)

# 5. Callbacks
checkpoint = callbacks.ModelCheckpoint('modelo_fase1_inicial.keras', monitor='val_accuracy', save_best_only=True, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)

# 6. Treinamento
print(f"\nIniciando Treinamento Fase 1 (10.177 Identidades)...")
model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=[checkpoint, early_stop])

# 7. Salvar Extrator de Características
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_fase1.keras')
