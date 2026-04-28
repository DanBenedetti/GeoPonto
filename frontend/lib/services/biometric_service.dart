import 'dart:io' show File;
import 'biometry/biometric_stub.dart'
    if (dart.library.io) 'biometry/biometric_mobile.dart';

class BiometricService {
  final BiometricImplementation _implementation = BiometricImplementation();

  double get threshold => _implementation.threshold;

  Future<List<double>?> extractEmbedding(File imageFile) async {
    return await _implementation.extractEmbedding(imageFile);
  }

  bool isSamePerson(List<double> currentEmbedding, List<double> storedEmbedding) {
    return _implementation.isSamePerson(currentEmbedding, storedEmbedding);
  }
}
