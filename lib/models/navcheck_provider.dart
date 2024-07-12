import 'package:flutter/material.dart';

class NavcheckProvider extends ChangeNotifier {
  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;
  set isNavigating(bool status) {
    _isNavigating = status;
    notifyListeners();
  }
}
