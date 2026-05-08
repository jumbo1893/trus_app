import 'package:firebase_messaging/firebase_messaging.dart';

class PushPermissionInfo {
  final AuthorizationStatus authorizationStatus;
  final String? token;
  final bool backendSynced;

  const PushPermissionInfo({
    required this.authorizationStatus,
    required this.token,
    required this.backendSynced,
  });

  bool get allowed =>
      authorizationStatus == AuthorizationStatus.authorized ||
          authorizationStatus == AuthorizationStatus.provisional;

  bool get hasToken => token != null && token!.isNotEmpty;
}