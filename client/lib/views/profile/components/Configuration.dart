import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/services/ThemeNotifier.dart';
import 'package:damd_trabalho_1/services/Preferences.dart';
import 'package:provider/provider.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/views/profile/components/ThemeOption.dart';

class Configuration extends StatefulWidget {
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveThemeMode(
    ThemeMode mode,
    ThemeNotifier themeNotifier,
  ) async {
    themeNotifier.setTheme(mode);
    await Preferences.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(Tokens.spacing16),
          child: Text(
            'APPEARANCE',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: Tokens.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Tokens.spacing16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Light theme option
              ThemeOption(
                label: 'Light',
                isSelected: themeNotifier.themeMode == ThemeMode.light,
                onTap: () => _saveThemeMode(ThemeMode.light, themeNotifier),
                theme: theme,
                child: Container(
                  width: 90,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Tokens.neutral50,
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: Tokens.borderSize1,
                    ),
                    borderRadius: BorderRadius.circular(Tokens.radius8),
                  ),
                  child: Center(
                    child: Text(
                      'Aa',
                      style: TextStyle(
                        color: Tokens.neutral900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Dark theme option
              ThemeOption(
                label: 'Dark',
                isSelected: themeNotifier.themeMode == ThemeMode.dark,
                onTap: () => _saveThemeMode(ThemeMode.dark, themeNotifier),
                theme: theme,
                child: Container(
                  width: 90,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Tokens.neutral900,
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: Tokens.borderSize1,
                    ),
                    borderRadius: BorderRadius.circular(Tokens.radius8),
                  ),
                  child: Center(
                    child: Text(
                      'Aa',
                      style: TextStyle(
                        color: Tokens.neutral50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // System theme option
              ThemeOption(
                label: 'System',
                isSelected: themeNotifier.themeMode == ThemeMode.system,
                onTap: () => _saveThemeMode(ThemeMode.system, themeNotifier),
                theme: theme,
                child: Container(
                  width: 90,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Tokens.radius8),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: Tokens.borderSize1,
                    ),
                    gradient: const LinearGradient(
                      colors: [Tokens.neutral900, Tokens.neutral50],
                      stops: [0.5, 0.5],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Aa',
                        style: TextStyle(
                          color: Tokens.neutral50,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: Tokens.spacing8),
                      Text(
                        'Aa',
                        style: TextStyle(
                          color: Tokens.neutral900,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
