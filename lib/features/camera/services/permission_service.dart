import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum PermissionFlowResult {
  granted,
  denied,
  permanentlyDenied,
}

/// Handles runtime permissions required by camera capture flow.
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  Future<PermissionFlowResult> ensureCameraFlowPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final mediaStatuses = await _requestMediaPermissions();

    final cameraGranted = cameraStatus.isGranted;
    final mediaGranted = _isMediaGranted(mediaStatuses);

    if (cameraGranted && mediaGranted) return PermissionFlowResult.granted;

    final cameraPermanentlyDenied = cameraStatus.isPermanentlyDenied;
    final mediaPermanentlyDenied = _isMediaPermanentlyDenied(mediaStatuses);
    if (cameraPermanentlyDenied || mediaPermanentlyDenied) {
      return PermissionFlowResult.permanentlyDenied;
    }

    return PermissionFlowResult.denied;
  }

  Future<List<PermissionStatus>> _requestMediaPermissions() async {
    final statuses = <PermissionStatus>[];

    // Keep media access explicit per UX requirement.
    if (Platform.isIOS) {
      statuses.add(await Permission.photos.request());
      return statuses;
    }

    if (Platform.isAndroid) {
      statuses.add(await Permission.photos.request());
      statuses.add(await Permission.storage.request());
    }

    return statuses;
  }

  bool _isMediaGranted(List<PermissionStatus> statuses) {
    if (statuses.isEmpty) return true;
    return statuses.any((status) => status.isGranted || status.isLimited);
  }

  bool _isMediaPermanentlyDenied(List<PermissionStatus> statuses) {
    if (statuses.isEmpty) return false;
    final mediaGranted = _isMediaGranted(statuses);
    if (mediaGranted) return false;
    return statuses.every((status) => status.isPermanentlyDenied);
  }
}
