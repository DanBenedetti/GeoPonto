import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
import os

# --- Configurações da Fase 8.3.1 ---
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
NUM_CLASSES = 250
DATASET_PATH = 'GeoPonto/Biometria/dataset_especialista_250/'
MODEL_BASE_PATH = 'modelo_fase8_3_refinamento_precisao.keras' # Evoluindo a 8.3
NEW_MODEL_PATH = 'modelo_fase8_3_1_ajuste_cirurgico.keras'
NEW_EXTRACTOR_PATH = 'geoponto_extractor_v8_3_1.keras'

# Hiperparâmetros Cirúrgicos
LR = 0.000005  # Fixa e extremamente baixa
EPOCHS = 100
LABEL_SMOOTHING = 0.0  # Removido para forçar a compactação dos clusters

# --- Pipeline de Dados ---
print(f"\n[SETUP] Carregando dataset...")
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

print(f"\n[RESUME] Evoluindo a partir da Base V8.3 (SGD)...")
model = tf.keras.models.load_model(MODEL_BASE_PATH)

# Compilação Cirúrgica
print(f"[CONFIG] Optimizer: SGD com Momentum 0.9 (Nesterov)")
print(f"[CONFIG] LR: {LR} (Fixo)")
print(f"[CONFIG] Label Smoothing: {LABEL_SMOOTHING} (Desativado)")

model.compile(
    optimizer=optimizers.SGD(learning_rate=LR, momentum=0.9, nesterov=True),
    loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=LABEL_SMOOTHING),
    metrics=['accuracy']
)

# Callbacks com paciência aumentada
callbacks_list = [
    callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1),
    callbacks.EarlyStopping(monitor='val_loss', patience=25, restore_best_weights=True), # Mais paciência
    callbacks.CSVLogger('training_log_fase8_3_1.csv', append=True)
]

# --- Treinamento ---
print(f"\n[TRAIN] Iniciando Fase 8.3.1...")
model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=callbacks_list
)

# --- Exportação ---
print("\n[EXPORT] Salvando extrator V8.3.1...")
try:
    embedding_layer = model.get_layer("embedding_output")
    extractor = models.Model(inputs=model.input, outputs=embedding_layer.output)
    extractor.save(NEW_EXTRACTOR_PATH)
    print(f"Sucesso! Extrator salvo em: {NEW_EXTRACTOR_PATH}")
except Exception as e:
    print(f"Erro ao salvar extrator: {e}")
    model.save('backup_modelo_fase8_3_1_completo.keras')

print("\n--- FASE 8.3.1 FINALIZADA ---")
