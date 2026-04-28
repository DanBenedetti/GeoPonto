import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:geoponto/config/api_config.dart';
import 'dart:math';

class BiometricImplementation {
  final double threshold = 1.80;

  BiometricImplementation() {
    print('Biometria Web: Usando processamento remoto via Uint8List.');
  }

  Future<void> _loadModel() async {}

  Future<List<double>?> extractEmbedding(Uint8List imageBytes) async {
    try {
      print('Enviando bytes da imagem para o servidor (Web)...');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/biometry/extract'),
      );
      
      // Criamos o arquivo multipart diretamente dos bytes
      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'face.jpg',
      );
      
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<double> embedding = List<double>.from(
          data['embedding'].map((e) => e.toDouble()),
        );
        print('Embedding recebido do servidor com sucesso.');
        return embedding;
      } else {
        print('Erro no servidor ao extrair biometria: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão ao extrair biometria no servidor: $e');
      return null;
    }
  }

  bool isSamePerson(List<double> currentEmbedding, List<double> storedEmbedding) {
    double distance = calculateDistance(currentEmbedding, storedEmbedding);
    print('--- VALIDAÇÃO BIOMÉTRICA (WEB/SERVER) ---');
    print('Distância calculada: $distance');
    print('Threshold: $threshold');
    print('Resultado: ${distance < threshold ? "MATCH" : "NO MATCH"}');
    print('-----------------------------------------');
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
