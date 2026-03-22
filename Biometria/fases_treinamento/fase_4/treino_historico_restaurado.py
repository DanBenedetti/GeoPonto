import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# 1. Configurações - FASE 4: REFINAMENTO DE PESOS
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EMBEDDING_SIZE = 128
EPOCHS = 100 

DATASET_PATH = 'GeoPonto/Biometria/dataset_celeba_otimizado/'
MODEL_BASE = 'modelo_fase3_impulso.keras' # Ponto de partida
NEW_MODEL_PATH = 'modelo_fase4_refinado.keras'

# 2. Pipeline de Dados
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.1, subset="training", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH, validation_split=0.1, subset="validation", seed=123,
    image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='categorical'
).prefetch(tf.data.AUTOTUNE)

# 3. Carregamento e Ajuste para Estabilidade
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Carregando pesos da Fase 3 para Refinamento...")
    model = tf.keras.models.load_model(MODEL_BASE)
    
    # Adicionando L2 Regularization (Penalização) para evitar pesos explosivos
    for layer in model.layers:
        if isinstance(layer, layers.Dense):
            layer.kernel_regularizer = regularizers.l2(0.005)
    
    # Taxa de aprendizado fixa e reduzida para estabilidade (LR 0.0002)
    model.optimizer.learning_rate.assign(0.0002) 
else:
    print(f"\n[ERRO] Modelo base '{MODEL_BASE}' não encontrado.")
    exit()

# 4. Callbacks de Monitoramento
checkpoint = callbacks.ModelCheckpoint(NEW_MODEL_PATH, monitor='val_accuracy', save_best_only=True, verbose=1)
reduce_lr = callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5, min_lr=1e-7, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True)

# 5. Execução
print(f"\nIniciando Treinamento Fase 4 (Refinamento Estável)...")
history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=[checkpoint, early_stop, reduce_lr])

# 6. Salvamento
model.save('modelo_completo_fase4.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor_fase4.keras')
