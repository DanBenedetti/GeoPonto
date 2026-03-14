import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
import matplotlib.pyplot as plt
import os
import pandas as pd

# 1. Configurações
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EMBEDDING_SIZE = 128
NUM_CLASSES = len([d for d in os.listdir('dataset_treino/') if os.path.isdir(os.path.join('dataset_treino/', d))])
EPOCHS = 100 # Colocamos 100, mas o EarlyStopping vai parar antes se começar a decorar!

# 2. Datasets
train_ds = tf.keras.utils.image_dataset_from_directory(
    'dataset_treino/',
    validation_split=0.2,
    subset="training",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    'dataset_treino/',
    validation_split=0.2,
    subset="validation",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='categorical'
)

# 3. Data Augmentation Robusto
data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.15), # Aumentamos o giro
    layers.RandomZoom(0.15),
    layers.RandomContrast(0.15), # Mudança de contraste ajuda a ignorar iluminação
    layers.RandomTranslation(height_factor=0.1, width_factor=0.1)
])

# 4. Arquitetura
base_model = tf.keras.applications.MobileNetV3Small(
    input_shape=(224, 224, 3),
    include_top=False,
    weights='imagenet'
)
base_model.trainable = True
# Congelamos as primeiras 40 camadas (aprendizado genérico) e liberamos o resto para rostos
for layer in base_model.layers[:-40]:
    layer.trainable = False

inputs = tf.keras.Input(shape=(224, 224, 3))
x = data_augmentation(inputs)
x = base_model(x, training=True)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.4)(x) # Aumentamos o Dropout para evitar memorização!
embedding_layer = layers.Dense(EMBEDDING_SIZE, name="embedding_output")(x)
x = layers.UnitNormalization(axis=1)(embedding_layer)
outputs = layers.Dense(NUM_CLASSES, activation='softmax')(x)

model = models.Model(inputs, outputs)

# 5. Callbacks (A "Inteligência" do Treino)
# Para o treino se ele parar de melhorar na validação
early_stop = callbacks.EarlyStopping(
    monitor='val_accuracy', 
    patience=10, 
    restore_best_weights=True,
    verbose=1
)

# Reduz o passo do otimizador se o erro estagnar (ajuste fino)
reduce_lr = callbacks.ReduceLROnPlateau(
    monitor='val_loss', 
    factor=0.2, 
    patience=5, 
    min_lr=1e-6,
    verbose=1
)

model.compile(
    optimizer=optimizers.Adam(learning_rate=0.0005),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# 6. Treinamento
print(f"\nTreinando modelo para o GeoPonto com Proteção Anti-Memorização...")
history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=[early_stop, reduce_lr]
)

# 7. Salvar e Gerar Gráficos
model.save('modelo_classificacao.keras')
embedding_model = models.Model(inputs=model.input, outputs=model.get_layer("embedding_output").output)
embedding_model.save('geoponto_extractor.keras')

plt.figure(figsize=(10, 5))
plt.plot(history.history['accuracy'], label='Treino')
plt.plot(history.history['val_accuracy'], label='Validação')
plt.title('Acurácia com Proteção Anti-Overfitting')
plt.legend(); plt.savefig('grafico_acuracia.png')

print("\n--- MODELO GERADOCOM SUCESSO ---")
