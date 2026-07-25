import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Initializes Firebase, App Check, and Crashlytics error hooks. Must run
/// before [runApp] with `WidgetsFlutterBinding.ensureInitialized()` already
/// called.
Future<void> bootstrapFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Play Integrity doesn't work from a debug-signed APK (device/app aren't
  // attestable), so debug builds fall back to the debug provider, which
  // requires allow-listing each developer device's token in the Firebase
  // Console (App Check → Apps → Manage debug tokens).
  await FirebaseAppCheck.instance.activate(
    androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
