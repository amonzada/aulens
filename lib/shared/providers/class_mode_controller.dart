import 'package:flutter/foundation.dart';

/// Tracks whether class mode is open or dismissed by the user.
class ClassModeController extends ChangeNotifier {
  bool _dismissed = false;
  bool _isOpen = false;

  bool get dismissed => _dismissed;
  bool get isOpen => _isOpen;

  void markDismissed() {
    if (_dismissed) return;
    _dismissed = true;
    notifyListeners();
  }

  void clearDismissed() {
    if (!_dismissed) return;
    _dismissed = false;
    notifyListeners();
  }

  void setOpen(bool value) {
    if (_isOpen == value) return;
    _isOpen = value;
    notifyListeners();
  }
}
