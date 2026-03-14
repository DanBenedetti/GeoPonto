import tensorflow as tf

# 1. Carregar o modelo extrator que você treinou
try:
    model = tf.keras.models.load_model('geoponto_extractor.h5')
    
    # 2. Criar o conversor TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Opcional: Otimizar para o celular (diminui o tamanho do arquivo)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # 3. Converter
    tflite_model = converter.convert()

    # 4. Salvar o arquivo final para o Flutter
    with open('geoponto_model.tflite', 'wb') as f:
        f.write(tflite_model)

    print("\n--- SUCESSO! ---")
    print("Arquivo 'geoponto_model.tflite' criado com sucesso.")
    print("Este é o arquivo que você vai colocar na pasta 'assets' do seu projeto Flutter.")

except Exception as e:
    print(f"ERRO na conversão: {e}")
    print("Certifique-se de que o arquivo 'geoponto_extractor.h5' existe (rode o treino primeiro).")
