import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Minimal permission explanation dialogs.
class PermissionAlerts {
  PermissionAlerts._();

  static Future<void> showDenied(BuildContext context) {
    return _show(
      context,
      title: 'Permission needed',
      message:
          'We need camera and media permissions to capture whiteboard photos and store your class notes.',
      primaryLabel: 'Try again',
      onPrimary: () => Navigator.of(context).pop(),
      secondaryLabel: 'Not now',
      onSecondary: () => Navigator.of(context).pop(),
    );
  }

  static Future<void> showPermanentlyDenied(BuildContext context) {
    return _show(
      context,
      title: 'Enable permissions in Settings',
      message:
          'Camera or media permission is permanently denied. Open app settings to allow access and continue capturing whiteboards.',
      primaryLabel: 'Open Settings',
      onPrimary: () async {
        Navigator.of(context).pop();
        await openAppSettings();
      },
      secondaryLabel: 'Cancel',
      onSecondary: () => Navigator.of(context).pop(),
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimary,
    required String secondaryLabel,
    required VoidCallback onSecondary,
  }) {
    final cs = Theme.of(context).colorScheme;

    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(Icons.lock_outline_rounded, color: cs.primary),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel)),
          FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
        ],
      ),
    );
  }
}
