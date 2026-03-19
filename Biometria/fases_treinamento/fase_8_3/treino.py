import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
import os

# --- Configurações da Fase 8.3 ---
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
NUM_CLASSES = 250
DATASET_PATH = 'GeoPonto/Biometria/dataset_especialista_250/'
MODEL_BASE_PATH = 'modelo_fase8_v8_1_completo.keras'
NEW_MODEL_PATH = 'modelo_fase8_3_refinamento_precisao.keras'
NEW_EXTRACTOR_PATH = 'geoponto_extractor_v8_3.keras'

# Hiperparâmetros de Alta Precisão
INITIAL_LR = 0.00001  # LR baixo para não "chutar" os pesos bons
FINAL_LR = 0.0000001
EPOCHS = 100
LABEL_SMOOTHING = 0.05 # Menos agressivo para manter a separação de embeddings

# --- Pipeline de Dados ---
print(f"\n[SETUP] Carregando dataset de: {DATASET_PATH}")
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.15, subset="training", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.15, subset="validation", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

# --- Carregamento ---
if not os.path.exists(MODEL_BASE_PATH):
    print(f"ERRO: Modelo base {MODEL_BASE_PATH} não encontrado!")
    exit(1)

print(f"\n[RESUME] Restaurando Base V8.1 (86.5% 1:1)...")
model = tf.keras.models.load_model(MODEL_BASE_PATH)

# Schedule de Cosine Decay
lr_schedule = optimizers.schedules.CosineDecay(
    initial_learning_rate=INITIAL_LR,
    decay_steps=len(train_ds) * EPOCHS,
    alpha=FINAL_LR / INITIAL_LR
)

# Compilação com SGD + Momentum (Padrão ouro para refinamento de precisão)
print(f"[CONFIG] Optimizer: SGD com Momentum 0.9 (Nesterov)")
print(f"[CONFIG] LR: {INITIAL_LR} (Cosine Decay)")
print(f"[CONFIG] Label Smoothing: {LABEL_SMOOTHING}")

model.compile(
    optimizer=optimizers.SGD(learning_rate=lr_schedule, momentum=0.9, nesterov=True),
    loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=LABEL_SMOOTHING),
    metrics=['accuracy']
)

# Callbacks
callbacks_list = [
    callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1),
    callbacks.EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True),
    callbacks.CSVLogger('training_log_fase8_3.csv', append=True)
]

# --- Treinamento ---
print(f"\n[TRAIN] Iniciando Fase 8.3")
model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=callbacks_list
)

# --- Exportação ---
print("\n[EXPORT] Salvando novo extrator de embeddings V8.3...")
try:
    embedding_layer = model.get_layer("embedding_output")
    extractor = models.Model(inputs=model.input, outputs=embedding_layer.output)
    extractor.save(NEW_EXTRACTOR_PATH)
    print(f"Sucesso! Extrator salvo em: {NEW_EXTRACTOR_PATH}")
except Exception as e:
    print(f"Erro ao salvar extrator: {e}")
    model.save('backup_modelo_fase8_3_completo.keras')

print("\n--- FASE 8.3 FINALIZADA ---")
