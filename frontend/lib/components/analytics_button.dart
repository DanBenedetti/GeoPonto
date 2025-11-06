import 'package:flutter/material.dart';
import 'package:geoponto/services/analytics_service.dart';
import 'package:geoponto/main.dart'; // Import main.dart to access navigatorKey

class AnalyticsButton extends StatelessWidget {
  final String buttonId;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const AnalyticsButton({
    super.key,
    required this.buttonId,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: () {
        // Get the current route name from the navigatorKey
        final String? currentRouteName = ModalRoute.of(navigatorKey.currentContext!)?.settings.name;
        AnalyticsService.recordButtonClick(buttonId, pageName: currentRouteName);
        onPressed();
      },
      child: child,
    );
  }
}
