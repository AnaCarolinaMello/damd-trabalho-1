import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/services/Preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await Preferences.getThemeMode();
      _themeMode = savedTheme;
      notifyListeners();
    } catch (e) {
      // Fallback to system theme on error
      _themeMode = ThemeMode.system;
      print('Error loading theme: $e');
    }
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}