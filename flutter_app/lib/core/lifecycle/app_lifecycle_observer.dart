import 'package:flutter/material.dart';

/// Mixin that logs and handles app lifecycle transitions.
/// Demonstrates the Mobile OS App Lifecycle concept.
///
/// Usage:
///   class _MyScreenState extends State<MyScreen> with AppLifecycleObserver { ... }
mixin AppLifecycleObserver<T extends StatefulWidget> on State<T>
    implements WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('[Lifecycle] → resumed: app visible, refresh data');
        onAppResumed();
        break;
      case AppLifecycleState.inactive:
        debugPrint('[Lifecycle] → inactive: losing focus (call/overlay)');
        onAppInactive();
        break;
      case AppLifecycleState.paused:
        debugPrint('[Lifecycle] → paused: background, save state');
        onAppPaused();
        break;
      case AppLifecycleState.detached:
        debugPrint('[Lifecycle] → detached: engine detached');
        break;
      case AppLifecycleState.hidden:
        debugPrint('[Lifecycle] → hidden');
        break;
    }
  }

  // Override these in your screen as needed
  void onAppResumed() {}
  void onAppInactive() {}
  void onAppPaused() {}

  // Required stubs for WidgetsBindingObserver
  @override void didChangeAccessibilityFeatures() {}
  @override void didChangeLocales(locales) {}
  @override void didChangeMetrics() {}
  @override void didChangePlatformBrightness() {}
  @override void didChangeTextScaleFactor() {}
  @override void didHaveMemoryPressure() {}
  @override Future<bool> didPopRoute() async => false;
  @override Future<bool> didPushRoute(route) async => false;
  @override Future<bool> didPushRouteInformation(routeInformation) async => false;
  @override void didChangeViewFocus(v) {}
}
