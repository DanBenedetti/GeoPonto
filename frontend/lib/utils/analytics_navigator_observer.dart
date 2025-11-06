import 'package:flutter/material.dart';
import 'package:geoponto/services/analytics_service.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      // Page view is now recorded by RenderTimeMixin, so this call is disabled.
      // AnalyticsService.recordPageView(route.settings.name!, 0); 
      print('Page pushed: ${route.settings.name}');
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      AnalyticsService.recordPageView(newRoute!.settings.name!, 0);
      print('Page replaced: ${newRoute.settings.name}');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name != null) {
      // We don't record pop as a new page view, but you could if needed.
      print('Page popped: ${route.settings.name}');
    }
  }
}
