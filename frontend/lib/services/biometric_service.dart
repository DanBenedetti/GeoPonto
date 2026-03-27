import 'dart:math';
import 'dart:typed_data';
// import 'package:tflite_flutter/tflite_flutter.dart'; // Comentado para permitir desenvolvimento Web/Chrome
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class BiometricService {
  // dynamic _interpreter; // Alterado de Interpreter? para dynamic para evitar erro de tipo no Web
  final double threshold = 1.80;

  BiometricService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (kIsWeb) {
      print('Aviso: Biometria TFLite não é suportada no navegador.');
      return;
    }
    
    try {
      // final options = InterpreterOptions();
      // _interpreter = await Interpreter.fromAsset(
      //   'assets/models/geoponto_extractor.tflite',
      //   options: options,
      // );
      print('Aviso: Carregamento do modelo TFLite ignorado para desenvolvimento.');
    } catch (e) {
      print('Erro ao carregar modelo TFLite: $e');
    }
  }

  // Extrai o embedding (vetor de 200 posições) de uma imagem
  Future<List<double>?> extractEmbedding(File imageFile) async {
    // if (_interpreter == null) return null;
    print('Aviso: Extração de embedding desabilitada (bypass).');
    return null;

    /* // Código original preservado em comentário para reversão futura
    try {
      final rawImage = img.decodeImage(imageFile.readAsBytesSync());
      if (rawImage == null) return null;
      
      final resizedImage = img.copyResize(rawImage, width: 224, height: 224);

      var input = Float32List(1 * 224 * 224 * 3);
      var buffer = 0;
      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[buffer++] = pixel.r.toDouble();
          input[buffer++] = pixel.g.toDouble();
          input[buffer++] = pixel.b.toDouble();
        }
      }

      var output = Float32List(1 * 128).reshape([1, 128]);
      _interpreter!.run(input.reshape([1, 224, 224, 3]), output);

      List<double> embedding = List<double>.from(output[0]);
      return embedding;
    } catch (e) {
      print('Erro na extração de embedding: $e');
      return null;
    }
    */
  }

  // Calcula a Distância Euclidiana entre dois embeddings
  double calculateDistance(List<double> e1, List<double> e2) {
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow(e1[i] - e2[i], 2);
    }
    return sqrt(sum);
  }

  // Verifica se é a mesma pessoa
  bool isSamePerson(List<double> currentEmbedding, List<double> storedEmbedding) {
    if (kIsWeb) return true; // Bypass para desenvolvimento no Chrome

    double distance = calculateDistance(currentEmbedding, storedEmbedding);
    print('--- VALIDAÇÃO BIOMÉTRICA ---');
    print('Distância calculada: $distance');
    print('Threshold: $threshold');
    print('Resultado: ${distance < threshold ? "MATCH (ACESSO LIBERADO)" : "NO MATCH (ACESSO NEGADO)"}');
    print('----------------------------');
    return distance < threshold;
  }
}
