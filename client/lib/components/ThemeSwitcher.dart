import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:damd_trabalho_1/services/ThemeNotifier.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return IconButton(
          icon: Icon(
            themeNotifier.themeMode == ThemeMode.dark || 
            (themeNotifier.themeMode == ThemeMode.system && isDark)
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: () {
            themeNotifier.setTheme(
              themeNotifier.themeMode == ThemeMode.dark || 
              (themeNotifier.themeMode == ThemeMode.system && isDark)
                  ? ThemeMode.light 
                  : ThemeMode.dark,
            );
          },
        );
      },
    );
  }
}
