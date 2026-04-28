import 'dart:convert';
import 'dart:io' show File;
import 'package:http/http.dart' as http;
import 'package:geoponto/config/api_config.dart';
import 'dart:math';

class BiometricImplementation {
  final double threshold = 1.80;

  BiometricImplementation() {
    print('Biometria Web: Usando processamento remoto no servidor para segurança real.');
  }

  Future<void> _loadModel() async {}

  Future<List<double>?> extractEmbedding(File imageFile) async {
    try {
      print('Enviando imagem para o servidor para extração de biometria...');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/biometry/extract'),
      );
      
      // Adiciona a imagem no request multipart
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

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
