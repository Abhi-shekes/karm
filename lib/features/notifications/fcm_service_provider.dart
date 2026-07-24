import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'fcm_service.dart';

part 'fcm_service_provider.g.dart';

@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) {
  return FcmService(FirebaseMessaging.instance);
}
