import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# 1. Configurações - FASE 7: POLIMENTO ESTÁVEL (Transição SGD)
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
NUM_CLASSES = 250
DATASET_PATH = 'GeoPonto/Biometria/dataset_especialista_250/'
MODEL_BASE = 'modelo_fase6_especialista.keras' # Ponto de partida
NEW_MODEL_PATH = 'modelo_fase7_polido.keras'

# 2. Pipeline de Dados
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.15, subset="training", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.15, subset="validation", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

# 3. Carregamento e Transição para SGD
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Carregando Modelo da Fase 6 para Polimento Final...")
    model = tf.keras.models.load_model(MODEL_BASE)
    
    # TRANSIÇÃO ESTRATÉGICA: Mudando de Adam para SGD com Momentum (Nesterov)
    # Motivo: Polimento mais fino e estável para atingir o mínimo global.
    optimizer_sgd = optimizers.SGD(
        learning_rate=0.00005, 
        momentum=0.9, 
        nesterov=True # Técnica que 'olha para frente' para evitar oscilações
    )
    
    model.compile(
        optimizer=optimizer_sgd, 
        loss='categorical_crossentropy', 
        metrics=['accuracy']
    )
else:
    print(f"\n[ERRO] Modelo base '{MODEL_BASE}' não encontrado.")
    exit()

# 4. Callbacks (Early Stopping com paciência aumentada para SGD)
checkpoint = callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=20, restore_best_weights=True)

# 5. Execução do Polimento
print(f"\nIniciando Polimento Estável (Transição para SGD)...")
history = model.fit(train_ds, validation_data=val_ds, epochs=100, callbacks=[checkpoint, early_stop])

# 6. Salvar Resultados
model.save('modelo_completo_fase7.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_fase7.keras')
