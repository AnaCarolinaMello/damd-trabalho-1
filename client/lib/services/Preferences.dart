import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Preferences {
  static Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode.name);
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('themeMode');
    return ThemeMode.values.byName(themeMode ?? 'system');
  }
}
