import 'package:flutter/material.dart';

@immutable
class TelegramTabColors extends ThemeExtension<TelegramTabColors> {
  const TelegramTabColors({
    required this.tabUnselected,
    required this.tabSelectedText,
    required this.tabSelectedPill,
    required this.glassBackground,
    required this.glassBorder,
    required this.badgeColor,
    required this.badgeBlue,
  });

  final Color tabUnselected;
  final Color tabSelectedText;
  final Color tabSelectedPill;
  final Color glassBackground;
  final Color glassBorder;
  final Color badgeColor;
  final Color badgeBlue;

  static const light = TelegramTabColors(
    tabUnselected: Color(0xFF8E8E93),
    tabSelectedText: Color(0xFF007AFF),
    tabSelectedPill: Color(0xFF007AFF),
    glassBackground: Color(0xB8FFFFFF),
    glassBorder: Color(0x1A000000),
    badgeColor: Color(0xFFFA3C3C),
    badgeBlue: Color(0xFF3478F6),
  );

  static const dark = TelegramTabColors(
    tabUnselected: Color(0xFF8E8E93),
    tabSelectedText: Color(0xFF3478F6),
    tabSelectedPill: Color(0xFF3478F6),
    glassBackground: Color(0xB81C1C1E),
    glassBorder: Color(0x33FFFFFF),
    badgeColor: Color(0xFFFA3C3C),
    badgeBlue: Color(0xFF3478F6),
  );

  @override
  TelegramTabColors copyWith({
    Color? tabUnselected,
    Color? tabSelectedText,
    Color? tabSelectedPill,
    Color? glassBackground,
    Color? glassBorder,
    Color? badgeColor,
    Color? badgeBlue,
  }) {
    return TelegramTabColors(
      tabUnselected: tabUnselected ?? this.tabUnselected,
      tabSelectedText: tabSelectedText ?? this.tabSelectedText,
      tabSelectedPill: tabSelectedPill ?? this.tabSelectedPill,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      badgeColor: badgeColor ?? this.badgeColor,
      badgeBlue: badgeBlue ?? this.badgeBlue,
    );
  }

  @override
  TelegramTabColors lerp(ThemeExtension<TelegramTabColors>? other, double t) {
    if (other is! TelegramTabColors) return this;
    return TelegramTabColors(
      tabUnselected: Color.lerp(tabUnselected, other.tabUnselected, t)!,
      tabSelectedText: Color.lerp(tabSelectedText, other.tabSelectedText, t)!,
      tabSelectedPill: Color.lerp(tabSelectedPill, other.tabSelectedPill, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      badgeColor: Color.lerp(badgeColor, other.badgeColor, t)!,
      badgeBlue: Color.lerp(badgeBlue, other.badgeBlue, t)!,
    );
  }
}

ThemeData telegramLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF007AFF),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    extensions: const [TelegramTabColors.light],
  );
}

ThemeData telegramDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3478F6),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF000000),
    extensions: const [TelegramTabColors.dark],
  );
}
