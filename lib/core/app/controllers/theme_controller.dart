import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  // Start with System to match the user's phone setting
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    // FIX: If it is currently Dark, go Light.
    // Otherwise (if Light OR System), go Dark.
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }
}
