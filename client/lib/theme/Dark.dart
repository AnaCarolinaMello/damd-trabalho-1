import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

final ThemeData dark = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: Tokens.primary400,
    onPrimary: Tokens.neutral0,
    primaryContainer: Tokens.primary700,
    onPrimaryContainer: Tokens.primary100,
    secondary: Tokens.neutral300,
    onSecondary: Tokens.neutral950,
    secondaryContainer: Tokens.neutral700,
    onSecondaryContainer: Tokens.neutral100,
    tertiary: Tokens.primary300,
    onTertiary: Tokens.primary950,
    tertiaryContainer: Tokens.primary800,
    onTertiaryContainer: Tokens.primary100,
    error: Colors.red.shade300,
    onError: Colors.red.shade900,
    errorContainer: Colors.red.shade800,
    onErrorContainer: Colors.red.shade100,
    background: Tokens.neutral900,
    onBackground: Tokens.neutral100,
    surface: Tokens.neutral950,
    onSurface: Tokens.neutral100,
    surfaceVariant: Tokens.neutral800,
    onSurfaceVariant: Tokens.neutral200,
    outline: Tokens.neutral500,
    outlineVariant: Tokens.neutral700,
    shadow: Tokens.neutral950.withOpacity(0.5),
    scrim: Tokens.neutral950.withOpacity(0.7),
    inverseSurface: Tokens.neutral100,
    onInverseSurface: Tokens.neutral900,
    inversePrimary: Tokens.primary700,
    surfaceTint: Tokens.primary400.withOpacity(0.1),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: Tokens.fontSize32,
      fontWeight: FontWeight.bold,
      color: Tokens.neutral50,
    ),
    displayMedium: TextStyle(
      fontSize: Tokens.fontSize28,
      fontWeight: FontWeight.bold,
      color: Tokens.neutral50,
    ),
    displaySmall: TextStyle(
      fontSize: Tokens.fontSize24,
      fontWeight: FontWeight.bold,
      color: Tokens.neutral50,
    ),
    headlineLarge: TextStyle(
      fontSize: Tokens.fontSize24,
      fontWeight: FontWeight.bold,
      color: Tokens.neutral50,
    ),
    headlineMedium: TextStyle(
      fontSize: Tokens.fontSize20,
      fontWeight: FontWeight.bold,
      color: Tokens.neutral50,
    ),
    headlineSmall: TextStyle(
      fontSize: Tokens.fontSize16,
      fontWeight: FontWeight.bold,
      color: Tokens.neutral50,
    ),
    bodyLarge: TextStyle(fontSize: Tokens.fontSize16, color: Tokens.neutral200),
    bodyMedium: TextStyle(
      fontSize: Tokens.fontSize14,
      color: Tokens.neutral200,
    ),
    bodySmall: TextStyle(fontSize: Tokens.fontSize12, color: Tokens.neutral300),
  ),
  scaffoldBackgroundColor: Tokens.neutral900,
  appBarTheme: AppBarTheme(
    backgroundColor: Tokens.neutral900,
    foregroundColor: Tokens.neutral100,
    elevation: 0,
  ),
  snackBarTheme: const SnackBarThemeData(
    actionTextColor: Tokens.primary500,
    backgroundColor: Tokens.neutral950,
    contentTextStyle: TextStyle(color: Tokens.neutral0),
    elevation: 20,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Tokens.primary500,
      foregroundColor: Tokens.neutral0,
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.spacing16,
        vertical: Tokens.spacing12,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.radius8),
      ),
    ),
  ),
  cardTheme: CardThemeData(
    color: Tokens.neutral800,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Tokens.radius12),
    ),
    margin: const EdgeInsets.all(Tokens.spacing8),
  ),
);
