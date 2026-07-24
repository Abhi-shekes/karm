import 'package:firebase_messaging/firebase_messaging.dart';

/// Requests push-notification permission and returns this device's FCM
/// token so it can be stored against the signed-in user for Cloud
/// Functions to target (assignment pushes, shared-task reminders).
class FcmService {
  FcmService(this._messaging);
  final FirebaseMessaging _messaging;

  Future<String?> registerAndGetToken() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    return _messaging.getToken();
  }
}
