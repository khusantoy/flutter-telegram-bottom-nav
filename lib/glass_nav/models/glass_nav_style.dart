import 'package:flutter/material.dart';

/// Single source of truth for every visual / motion token used by the
/// `glass_nav` widget tree.
///
/// All defaults reproduce DrKLO/Telegram's MainTabsActivity look; override
/// any subset via [copyWith] or the named constructors (e.g. [material]).
@immutable
class GlassNavStyle {
  const GlassNavStyle({
    // Geometry
    this.pillWidth = 328,
    this.pillHeight = 56,
    this.outerVerticalMargin = 8,
    this.innerPadding = 4,
    this.iconSize = 24,
    this.labelTopOffset = 30,
    this.labelFontSize = 12,
    this.fadeHeight = 60,
    // Colors
    this.unselectedColor = const Color(0xFF8E8E93),
    this.selectedColor = const Color(0xFF007AFF),
    this.glassTint = const Color(0xB8FFFFFF),
    this.glassBorderColor = const Color(0x1A000000),
    this.glassBorderWidth = 0.5,
    this.pillIndicatorOpacity = 0.09,
    this.badgeColor = const Color(0xFFFA3C3C),
    this.badgeTextColor = Colors.white,
    this.badgeBorderColor = Colors.white,
    // Typography
    this.unselectedWeight = FontWeight.w700,
    this.selectedWeight = FontWeight.w900,
    // Motion
    this.swipeFollowsPage = true,
    this.tapDuration = const Duration(milliseconds: 540),
    this.tapCurve = Curves.easeOutQuint,
    this.pillCurve = Curves.decelerate,
    this.pillScaleStart = 0.6,
    this.pillScaleEnd = 1.0,
    this.blurSigma = 24,
  });

  /// Stronger pill contrast / no fade — useful for plain backgrounds.
  factory GlassNavStyle.material() => const GlassNavStyle(
        pillIndicatorOpacity: 0.16,
        fadeHeight: 0,
        glassTint: Color(0xF5FFFFFF),
      );

  // Geometry (logical pixels)
  final double pillWidth;
  final double pillHeight;
  final double outerVerticalMargin;
  final double innerPadding;
  final double iconSize;
  final double labelTopOffset;
  final double labelFontSize;
  final double fadeHeight;

  // Colors
  final Color unselectedColor;
  final Color selectedColor;
  final Color glassTint;
  final Color glassBorderColor;
  final double glassBorderWidth;
  final double pillIndicatorOpacity;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color badgeBorderColor;

  // Typography
  final FontWeight unselectedWeight;
  final FontWeight selectedWeight;

  // Motion
  final bool swipeFollowsPage;
  final Duration tapDuration;
  final Curve tapCurve;
  final Curve pillCurve;
  final double pillScaleStart;
  final double pillScaleEnd;
  final double blurSigma;

  // ---- Derived ----------------------------------------------------------
  double get pillRadius => pillHeight / 2;
  double get outerWidth => pillWidth + outerVerticalMargin * 2;
  double get outerHeight => pillHeight + outerVerticalMargin * 2;

  GlassNavStyle copyWith({
    double? pillWidth,
    double? pillHeight,
    double? outerVerticalMargin,
    double? innerPadding,
    double? iconSize,
    double? labelTopOffset,
    double? labelFontSize,
    double? fadeHeight,
    Color? unselectedColor,
    Color? selectedColor,
    Color? glassTint,
    Color? glassBorderColor,
    double? glassBorderWidth,
    double? pillIndicatorOpacity,
    Color? badgeColor,
    Color? badgeTextColor,
    Color? badgeBorderColor,
    FontWeight? unselectedWeight,
    FontWeight? selectedWeight,
    bool? swipeFollowsPage,
    Duration? tapDuration,
    Curve? tapCurve,
    Curve? pillCurve,
    double? pillScaleStart,
    double? pillScaleEnd,
    double? blurSigma,
  }) {
    return GlassNavStyle(
      pillWidth: pillWidth ?? this.pillWidth,
      pillHeight: pillHeight ?? this.pillHeight,
      outerVerticalMargin: outerVerticalMargin ?? this.outerVerticalMargin,
      innerPadding: innerPadding ?? this.innerPadding,
      iconSize: iconSize ?? this.iconSize,
      labelTopOffset: labelTopOffset ?? this.labelTopOffset,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      fadeHeight: fadeHeight ?? this.fadeHeight,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      selectedColor: selectedColor ?? this.selectedColor,
      glassTint: glassTint ?? this.glassTint,
      glassBorderColor: glassBorderColor ?? this.glassBorderColor,
      glassBorderWidth: glassBorderWidth ?? this.glassBorderWidth,
      pillIndicatorOpacity: pillIndicatorOpacity ?? this.pillIndicatorOpacity,
      badgeColor: badgeColor ?? this.badgeColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      badgeBorderColor: badgeBorderColor ?? this.badgeBorderColor,
      unselectedWeight: unselectedWeight ?? this.unselectedWeight,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      swipeFollowsPage: swipeFollowsPage ?? this.swipeFollowsPage,
      tapDuration: tapDuration ?? this.tapDuration,
      tapCurve: tapCurve ?? this.tapCurve,
      pillCurve: pillCurve ?? this.pillCurve,
      pillScaleStart: pillScaleStart ?? this.pillScaleStart,
      pillScaleEnd: pillScaleEnd ?? this.pillScaleEnd,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }
}

/// Convenience [InheritedWidget]-like accessor. Wrap your subtree with
/// [GlassNavStyleProvider] to share a single style, otherwise fall back to
/// the const default.
class GlassNavStyleProvider extends InheritedWidget {
  const GlassNavStyleProvider({
    super.key,
    required this.style,
    required super.child,
  });

  final GlassNavStyle style;

  static GlassNavStyle of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<GlassNavStyleProvider>();
    return provider?.style ?? const GlassNavStyle();
  }

  @override
  bool updateShouldNotify(GlassNavStyleProvider oldWidget) =>
      style != oldWidget.style;
}
