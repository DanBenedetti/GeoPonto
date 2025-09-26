import 'package:http/http.dart' as http;

class ABTestService {
  static Future<void> sendMetric({
    required String variant,
    required int loadTimeMs,
    required String action,
  }) async {
    await http.post(
      Uri.parse('http://localhost:5000/ab-metric'), // Troque para seu IP se necessário
      headers: {'Content-Type': 'application/json'},
      body: '''
        {
          "variant": "$variant",
          "load_time_ms": $loadTimeMs,
          "action": "$action"
        }
      ''',
    );
  }
}