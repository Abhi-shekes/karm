import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/firebase/bootstrap.dart';
import 'features/home_widget/widget_launch_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  WidgetLaunchListener(rootNavigatorKey);
  runApp(const ProviderScope(child: KarmApp()));
}
