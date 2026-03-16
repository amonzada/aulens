import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  int _preGraceMinutes = AppConstants.sessionPreGraceMinutes;
  int _postGraceMinutes = AppConstants.sessionPostGraceMinutes;
  bool _savePhotosToGallery = false;
  bool _loading = false;

  int get preGraceMinutes => _preGraceMinutes;
  int get postGraceMinutes => _postGraceMinutes;
  bool get savePhotosToGallery => _savePhotosToGallery;
  bool get loading => _loading;

  SettingsProvider(this._service) {
    _load();
  }

  Future<void> _load() async {
    _loading = true;
    notifyListeners();
    _preGraceMinutes = await _service.getPreGraceMinutes();
    _postGraceMinutes = await _service.getPostGraceMinutes();
    _savePhotosToGallery = await _service.getSavePhotosToGallery();
    _loading = false;
    notifyListeners();
  }

  Future<void> updatePreGraceMinutes(int value) async {
    _preGraceMinutes = value;
    notifyListeners();
    await _service.setPreGraceMinutes(value);
  }

  Future<void> updatePostGraceMinutes(int value) async {
    _postGraceMinutes = value;
    notifyListeners();
    await _service.setPostGraceMinutes(value);
  }

  Future<void> updateSavePhotosToGallery(bool value) async {
    _savePhotosToGallery = value;
    notifyListeners();
    await _service.setSavePhotosToGallery(value);
  }
}
