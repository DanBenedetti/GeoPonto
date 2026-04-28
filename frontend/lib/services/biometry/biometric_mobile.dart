import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io' show File;

class BiometricImplementation {
  Interpreter? _interpreter;
  final double threshold = 1.80;

  BiometricImplementation() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(
        'assets/models/geoponto_extractor.tflite',
        options: options,
      );
      print('Biometria: Modelo TFLite carregado com sucesso.');
    } catch (e) {
      print('Erro ao carregar modelo TFLite: $e');
    }
  }

  Future<List<double>?> extractEmbedding(File imageFile) async {
    if (_interpreter == null) {
      print('Erro: Interpretador TFLite não inicializado.');
      return null;
    }

    try {
      final rawImage = img.decodeImage(imageFile.readAsBytesSync());
      if (rawImage == null) return null;
      
      final resizedImage = img.copyResize(rawImage, width: 224, height: 224);

      var input = Float32List(1 * 224 * 224 * 3);
      var buffer = 0;
      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // Normalização básica se necessária (o modelo v8.3.1 foi treinado com 0-255 ou 0-1?)
          // Geralmente modelos MobileNetV3 esperam normalização. 
          // Mantendo o padrão que estava no seu comentário original.
          input[buffer++] = pixel.r.toDouble();
          input[buffer++] = pixel.g.toDouble();
          input[buffer++] = pixel.b.toDouble();
        }
      }

      // O modelo v8.3.1 gera 128 embeddings de acordo com o comentário original
      var output = Float32List(1 * 128).reshape([1, 128]);
      _interpreter!.run(input.reshape([1, 224, 224, 3]), output);

      List<double> embedding = List<double>.from(output[0]);
      return embedding;
    } catch (e) {
      print('Erro na extração de embedding: $e');
      return null;
    }
  }

  bool isSamePerson(List<double> currentEmbedding, List<double> storedEmbedding) {
    double distance = calculateDistance(currentEmbedding, storedEmbedding);
    print('--- VALIDAÇÃO BIOMÉTRICA ---');
    print('Distância calculada: $distance');
    print('Threshold: $threshold');
    print('Resultado: ${distance < threshold ? "MATCH" : "NO MATCH"}');
    print('----------------------------');
    return distance < threshold;
  }

  double calculateDistance(List<double> e1, List<double> e2) {
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow(e1[i] - e2[i], 2);
    }
    return sqrt(sum);
  }
}
