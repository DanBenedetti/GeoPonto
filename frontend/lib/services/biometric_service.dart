import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class BiometricService {
  Interpreter? _interpreter;
  final double threshold = 1.80;

  BiometricService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions();
      // Se estiver no Android, pode usar a GPU se disponível
      if (Platform.isAndroid) {
        // options.addDelegate(GpuDelegateV2()); 
      }
      _interpreter = await Interpreter.fromAsset(
        'assets/models/geoponto_extractor.tflite',
        options: options,
      );
      print('Sucesso: Modelo TFLite carregado para o App.');
    } catch (e) {
      print('Erro ao carregar modelo TFLite: $e');
    }
  }

  // Extrai o embedding (vetor de 200 posições) de uma imagem
  Future<List<double>?> extractEmbedding(File imageFile) async {
    if (_interpreter == null) return null;

    try {
      final rawImage = img.decodeImage(imageFile.readAsBytesSync());
      if (rawImage == null) return null;
      
      final resizedImage = img.copyResize(rawImage, width: 224, height: 224);

      // Usar Float32List para garantir o layout de memória que o TFLite espera [1, 224, 224, 3]
      // IMPORTANTE: O modelo TFLite já possui uma camada interna de Rescaling(1./255).
      // Portanto, devemos passar os valores dos pixels no intervalo [0, 255].
      var input = Float32List(1 * 224 * 224 * 3);
      var buffer = 0;
      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // Passar valores puros (0-255) conforme esperado pela primeira camada do modelo
          input[buffer++] = pixel.r.toDouble();
          input[buffer++] = pixel.g.toDouble();
          input[buffer++] = pixel.b.toDouble();
        }
      }

      // Preparar saída [1, 128] conforme o modelo extrator homologado
      var output = Float32List(1 * 128).reshape([1, 128]);

      // Rodar Inferência com tensores formatados
      _interpreter!.run(input.reshape([1, 224, 224, 3]), output);

      // Retornar o embedding bruto conforme o script de validação Python (validacao_real.py)
      // O threshold de 1.80 foi calculado sobre vetores sem normalização L2.
      List<double> embedding = List<double>.from(output[0]);

      print('Embedding extraído (primeiros 5 valores): ${embedding.take(5).toList()}');

      return embedding;
    } catch (e) {
      print('Erro na extração de embedding: $e');
      return null;
    }
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
    double distance = calculateDistance(currentEmbedding, storedEmbedding);
    print('--- VALIDAÇÃO BIOMÉTRICA ---');
    print('Distância calculada: $distance');
    print('Threshold: $threshold');
    print('Resultado: ${distance < threshold ? "MATCH (ACESSO LIBERADO)" : "NO MATCH (ACESSO NEGADO)"}');
    print('----------------------------');
    return distance < threshold;
  }
}
