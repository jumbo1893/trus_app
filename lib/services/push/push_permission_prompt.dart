import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PushPermissionPrompt {
  static Future<bool> ensureAllowed(BuildContext context) async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (_allowed(settings.authorizationStatus)) return true;
    if (!context.mounted) return false;

    final blocked =
        settings.authorizationStatus == AuthorizationStatus.denied &&
        await Permission.notification.isPermanentlyDenied;
    if (!context.mounted) return false;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(blocked ? 'Oznámení jsou blokovaná' : 'Povolit oznámení'),
        content: Text(
          blocked
              ? 'Oznámení aplikace jsou v systému zablokovaná. Povol je v nastavení aplikace.'
              : 'Aby ti mohly chodit zprávy a další oznámení, povol aplikaci oznámení.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(blocked ? 'Otevřít nastavení' : 'Povolit'),
          ),
        ],
      ),
    );
    if (proceed != true) return false;
    if (blocked) {
      await openAppSettings();
      return false;
    }

    final requested = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (_allowed(requested.authorizationStatus)) return true;
    if (!context.mounted) return false;
    final open = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Oznámení nejsou povolená'),
        content: const Text('Povol oznámení v nastavení aplikace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Zavřít'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Otevřít nastavení'),
          ),
        ],
      ),
    );
    if (open == true) await openAppSettings();
    return false;
  }

  static bool _allowed(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;
}
