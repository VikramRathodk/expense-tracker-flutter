import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupErrorHandlers();

  await Hive.initFlutter();
  await Hive.openBox<Map>('dashboard_cache');

  runApp(const App());
}

void _setupErrorHandlers() {
  // Catches Flutter framework errors (e.g. widget build exceptions)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // TODO: forward to Sentry / Firebase Crashlytics in production
    }
  };

  // Catches all other Dart errors (async, isolate, platform channel)
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {

      debugPrint('Unhandled error: $error\n$stack');
    }
    // TODO: forward to Sentry / Firebase Crashlytics in production
    return true; // prevents crash
  };
}
