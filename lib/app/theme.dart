import 'package:flutter/material.dart';

/// Rozgari design tokens converted from Frontend/code.html Tailwind config.
/// Deep forest green + amber, warm canvas background, bilingual editorial type.
class KsColors {
  static const primary = Color(0xFF00231A);
  static const primaryContainer = Color(0xFF17392F);
  static const primaryFixedDim = Color(0xFFAACEB0);
  static const secondary = Color(0xFF825500);
  static const secondaryContainer = Color(0xFFFDB64C);
  static const secondaryFixed = Color(0xFFFFDDB3);
  static const canvas = Color(0xFFF7F3EA);
  static const surface = Color(0xFFFCF9F8);
  static const card = Colors.white;
  static const muted = Color(0xFF68645E);
  static const successBg = Color(0xFFE8F5EF);
  static const successDeep = Color(0xFF005236);
  static const amberBg = Color(0xFFFEF5E7);
  static const danger = Color(0xFFC94C42);
  static const surfaceContainer = Color(0xFFF0EDED);
  static const surfaceHigh = Color(0xFFEAE7E7);
}

ThemeData rozgariTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: KsColors.primary,
    primary: KsColors.primary,
    secondary: KsColors.secondary,
    surface: KsColors.surface,
    error: KsColors.danger,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
      primary: KsColors.primary,
      onPrimary: Colors.white,
      primaryContainer: KsColors.primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: KsColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: KsColors.secondaryContainer,
      surface: KsColors.surface,
    ),
    scaffoldBackgroundColor: KsColors.canvas,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w800,
        fontSize: 28,
        height: 1.15,
        color: KsColors.primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: KsColors.primary,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: KsColors.primary,
      ),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45),
      bodySmall: TextStyle(fontSize: 12.5, color: KsColors.muted),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: KsColors.card,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: KsColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 56),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: const StadiumBorder(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
