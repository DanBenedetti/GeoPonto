import 'package:flutter/material.dart';
import 'package:geoponto/services/metrics_service.dart';

class MetricsNavigatorObserver extends NavigatorObserver {
  final MetricsService _metricsService = MetricsService();

  void _logScreenMetrics(Route<dynamic> route) {
    // Use route.settings.name, which is a common practice for screen tracking
    final screenName = route.settings.name;
    if (screenName != null && screenName.isNotEmpty) {
      _metricsService.trackPageView(screenName);
      _metricsService.startPageLoadTimer(screenName);
    }
  }

  void _stopTimer(Route<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null && screenName.isNotEmpty) {
      _metricsService.stopPageLoadTimer(screenName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // When a new screen is pushed, we log its view and start the timer.
    _logScreenMetrics(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // When a screen is popped, we stop its load timer.
    _stopTimer(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // When a screen is replaced, we stop the timer for the old one
    // and start the metrics for the new one.
    if (oldRoute != null) {
      _stopTimer(oldRoute);
    }
    if (newRoute != null) {
      _logScreenMetrics(newRoute);
    }
  }
}
