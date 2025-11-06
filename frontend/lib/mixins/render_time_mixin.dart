import 'package:flutter/material.dart';
import 'package:geoponto/services/analytics_service.dart';

mixin RenderTimeMixin<T extends StatefulWidget> on State<T> {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stopwatch.stop();
      final routeName = ModalRoute.of(context)?.settings.name;
      if (routeName != null) {
        AnalyticsService.recordPageView(routeName, _stopwatch.elapsedMilliseconds);
        print('Page: $routeName, Render Time: ${_stopwatch.elapsedMilliseconds}ms');
      }
    });
  }
}
