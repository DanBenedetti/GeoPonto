import 'dart:typed_data';
import 'biometry/biometric_stub.dart'
    if (dart.library.io) 'biometry/biometric_mobile.dart';

class BiometricService {
  final BiometricImplementation _implementation = BiometricImplementation();

  double get threshold => _implementation.threshold;

  Future<List<double>?> extractEmbedding(Uint8List imageBytes) async {
    return await _implementation.extractEmbedding(imageBytes);
  }

  bool isSamePerson(List<double> currentEmbedding, List<double> storedEmbedding) {
    return _implementation.isSamePerson(currentEmbedding, storedEmbedding);
  }
}
