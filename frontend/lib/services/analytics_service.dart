import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geoponto/config/api_config.dart';

class AnalyticsService {
  static final String _baseUrl = ApiConfig.baseUrl;

  static Future<void> recordPageView(String pageName, int renderTimeMs) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analytics/page-view'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'page_name': pageName,
          'render_time_ms': renderTimeMs,
        }),
      );

      if (response.statusCode != 201) {
        print('Failed to record page view: ${response.body}');
      }
    } catch (e) {
      print('Error recording page view: $e');
    }
  }

  static Future<void> recordButtonClick(String buttonId, {String? pageName}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analytics/button-click'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'button_id': buttonId,
          'page_name': pageName,
        }),
      );

      if (response.statusCode != 201) {
        print('Failed to record button click: ${response.body}');
      }
    } catch (e) {
      print('Error recording button click: $e');
    }
  }

  static Future<Map<String, dynamic>> getAnalyticsMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/metrics'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load analytics metrics: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error loading analytics metrics: $e');
      return {};
    }
  }
}
