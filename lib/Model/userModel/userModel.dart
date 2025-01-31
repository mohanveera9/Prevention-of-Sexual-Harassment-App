import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String _name = '';
  String _primary = '';

  // Getters
  String get name => _name;
  String get primary => _primary;

  // Set user details
  void setUserDetails({
    required String name,
    required String primary,
  }) {
    _name = name;
    _primary = primary;
    notifyListeners(); // Notify listeners of updates
  }

  // Update name (e.g., from Profile screen)
  void updateName(String name) {
    _name = name;
    notifyListeners();
  }
  void updateNumber(String primary) {
    _primary = primary;
    notifyListeners();
  }
}
