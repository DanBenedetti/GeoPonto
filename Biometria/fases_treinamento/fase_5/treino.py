import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# ==============================================================================
# FASE 5 GOLD: REFINAMENTO FINAL DE PRECISÃO
# Estratégia: Layer Freezing + Taxa de Aprendizado Microscópica
# ==============================================================================

# 1. Configurações
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 100 

DATASET_PATH = 'GeoPonto/Biometria/dataset_celeba_fase5/'
MODEL_BASE = 'modelo_fase5_ultra.keras' 
OUTPUT_MODEL = 'modelo_final_homologado.keras'

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

train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

# 3. Carregamento e Ajuste de Freezing
if os.path.exists(MODEL_BASE):
    print(f"\n[RESUME] Carregando Modelo Ultra (12% Acc). Iniciando REFINAMENTO GOLD...")
    model = tf.keras.models.load_model(MODEL_BASE)
    
    # CONGELAMENTO: Congelamos as camadas de base para focar apenas na classificação
    # Procuramos a camada 'MobilenetV3' dentro do modelo
    for layer in model.layers:
        if 'MobilenetV3' in layer.name:
            layer.trainable = False
            print(f">>> Camada de Base {layer.name} CONGELADA para estabilidade.")
    
    # TAXA DE APRENDIZADO MICROSCÓPICA
    model.optimizer.learning_rate.assign(0.00001) 
    print(f"Taxa de aprendizado ajustada para refinamento: {model.optimizer.learning_rate.numpy()}")
else:
    print(f"\n[ERRO] Modelo '{MODEL_BASE}' não encontrado.")
    exit()

# 4. Callbacks
checkpoint = callbacks.ModelCheckpoint(OUTPUT_MODEL, monitor='val_accuracy', save_best_only=True, verbose=1)
reduce_lr = callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=10, min_lr=1e-8, verbose=1)
early_stop = callbacks.EarlyStopping(monitor='val_loss', patience=20, restore_best_weights=True)

# 5. Execução
print(f"\nIniciando Rodada Final de Homologação...")
history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=[checkpoint, early_stop, reduce_lr]
)

# 6. Finalização e Exportação
model.save('modelo_completo_final.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor.keras')

print("\n" + "="*60)
print("PROCESSO DE TREINAMENTO FINALIZADO!")
print("O modelo atingiu sua maturidade máxima para o PI.")
print("="*60)
