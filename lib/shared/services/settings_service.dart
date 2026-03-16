import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class SettingsService {
  static const _preGraceKey = 'pre_grace_minutes';
  static const _postGraceKey = 'post_grace_minutes';
  static const _savePhotosToGalleryKey = 'save_photos_to_gallery';

  Future<int> getPreGraceMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_preGraceKey) ?? AppConstants.sessionPreGraceMinutes;
  }

  Future<int> getPostGraceMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_postGraceKey) ?? AppConstants.sessionPostGraceMinutes;
  }

  Future<void> setPreGraceMinutes(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_preGraceKey, value);
  }

  Future<void> setPostGraceMinutes(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_postGraceKey, value);
  }

  Future<bool> getSavePhotosToGallery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_savePhotosToGalleryKey) ?? false;
  }

  Future<void> setSavePhotosToGallery(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_savePhotosToGalleryKey, value);
  }
}
