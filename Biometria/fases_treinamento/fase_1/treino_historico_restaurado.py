import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks, regularizers
import os

# 1. Configurações Profissionais (Treino do Zero na CPU)
IMG_SIZE = (224, 224)
BATCH_SIZE = 32  # Seguro para evitar OOM
EMBEDDING_SIZE = 128
EPOCHS = 100 

# Novo Dataset: CelebA Otimizado (Fase 2)
DATASET_PATH = 'GeoPonto/Biometria/dataset_celeba_otimizado/'
NUM_CLASSES = len([d for d in os.listdir(DATASET_PATH) if os.path.isdir(os.path.join(DATASET_PATH, d))])

print(f"Detectadas {NUM_CLASSES} identidades selecionadas para a Fase 2.")

# 2. Pipeline de Dados de Alto Desempenho
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH,
    validation_split=0.05,
    subset="training",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_PATH,
    validation_split=0.05,
    subset="validation",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

# Otimização para SSD: Prefetch sem Cache (Cache esgotaria a RAM com 1M de fotos)
train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

# 3. Data Augmentation (Essencial para aprender do zero)
data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
    layers.RandomContrast(0.2)
])

# 4. Arquitetura ou Carregamento de Modelo Existente (Fase 4)
MODEL_PATH = 'modelo_fase3_refinado.keras' # Carrega o progresso da Fase 3
NEW_CHECKPOINT_PATH = 'modelo_fase4_final.keras'

if os.path.exists(MODEL_PATH):
    print(f"\n[RESUME] Modelo encontrado em '{MODEL_PATH}'. Carregando pesos para Fase 4...")
    model = tf.keras.models.load_model(MODEL_PATH)
    # Taxa de aprendizado equilibrada para REFINAMENTO FINAL
    model.optimizer.learning_rate.assign(0.0002) 
    print(f"Taxa de aprendizado ajustada para: {model.optimizer.learning_rate.numpy()}")
else:
    print("\n[START] Nenhum modelo prévio encontrado. Iniciando criação do zero (Requisito PI)...")
    base_model = tf.keras.applications.MobileNetV3Small(
        input_shape=(224, 224, 3),
        include_top=False,
        weights=None 
    )
    base_model.trainable = True 

    inputs = tf.keras.Input(shape=(224, 224, 3))
    x = data_augmentation(inputs)
    x = layers.Rescaling(1./255)(x)
    x = base_model(x)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.4)(x)

    embedding_layer = layers.Dense(
        EMBEDDING_SIZE, 
        kernel_regularizer=regularizers.l2(0.005),
        name="embedding_output"
    )(x)
    x = layers.UnitNormalization(axis=1)(embedding_layer)

    outputs = layers.Dense(NUM_CLASSES, activation='softmax')(x)
    model = models.Model(inputs, outputs)

    model.compile(
        optimizer=optimizers.Adam(learning_rate=0.0001), 
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

# 6. Callbacks Inteligentes
checkpoint = callbacks.ModelCheckpoint(
    'modelo_fase4_final.keras', 
    monitor='val_accuracy',
    save_best_only=True,
    verbose=1
)

# Reduz o aprendizado se o modelo parar de melhorar, em vez de apenas parar o treino
reduce_lr = callbacks.ReduceLROnPlateau(
    monitor='val_loss', 
    factor=0.2, 
    patience=5, 
    min_lr=1e-7,
    verbose=1
)

early_stop = callbacks.EarlyStopping(
    monitor='val_loss', 
    patience=20, # Mais paciência para dar tempo de "clicar" o aprendizado
    restore_best_weights=True
)

# 7. Treinamento Fase 4
print(f"\nIniciando Treinamento Fase 4 (Refinamento Final)...")
print(f"O modelo será salvo como 'modelo_fase4_final.keras'")

history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=[checkpoint, early_stop, reduce_lr]
)

# 8. Salvar Extrator de Características
model.save('modelo_completo_final.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor.keras')

print("\n--- MODELO ACADÊMICO MASSIVO GERADO ---")
