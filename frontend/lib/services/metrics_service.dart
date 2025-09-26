import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MetricsService {
  static final MetricsService _instance = MetricsService._internal();
  factory MetricsService() => _instance;
  MetricsService._internal();

  final List<Map<String, dynamic>> _metrics = [];
  final Map<String, Stopwatch> _pageLoadTimers = {};
  String _testVersion = 'A'; // Default to version A
  final String _backendUrl = 'http://10.0.2.2:5000/metrics'; // Assuming backend is on localhost

  // Method to set the test version (A or B)
  void setTestVersion(String version) {
    _testVersion = version;
  }

  void trackButtonClick(String buttonId) {
    final metric = {
      'type': 'click',
      'id': buttonId,
      'versao_teste': _testVersion,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _metrics.add(metric);
    debugPrint('Metric tracked: $metric');
  }

  void trackPageView(String screenName) {
    final metric = {
      'type': 'page_view',
      'id': screenName,
      'versao_teste': _testVersion,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _metrics.add(metric);
    debugPrint('Metric tracked: $metric');
  }

  void startPageLoadTimer(String screenName) {
    _pageLoadTimers[screenName] = Stopwatch()..start();
    debugPrint('Page load timer started for: $screenName');
  }

  void stopPageLoadTimer(String screenName) {
    final timer = _pageLoadTimers[screenName];
    if (timer != null) {
      timer.stop();
      final metric = {
        'type': 'page_load_time',
        'id': screenName,
        'duration_ms': timer.elapsedMilliseconds,
        'versao_teste': _testVersion,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _metrics.add(metric);
      _pageLoadTimers.remove(screenName);
      debugPrint('Metric tracked: $metric');
    }
  }

  List<Map<String, dynamic>> getMetrics() {
    return List.from(_metrics);
  }

  void clearMetrics() {
    _metrics.clear();
  }

  Future<void> sendMetrics() async {
    if (_metrics.isEmpty) {
      debugPrint('No metrics to send.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_metrics),
      );

      if (response.statusCode == 201) {
        debugPrint('Metrics sent successfully.');
        clearMetrics();
      } else {
        debugPrint('Failed to send metrics. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending metrics: $e');
    }
  }
}
