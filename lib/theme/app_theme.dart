import 'package:flutter/material.dart';

/// Light/dark theme presets used by the demo app. The `glass_nav` package
/// does NOT depend on these — it ships its own style tokens.
abstract final class AppTheme {
  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      );

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3478F6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
      );
}
