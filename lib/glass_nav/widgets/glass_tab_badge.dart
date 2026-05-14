import 'package:flutter/material.dart';

import '../models/glass_nav_style.dart';

/// Telegram-style counter badge — 16dp tall pill with a 1.33dp outer ring.
class GlassTabBadge extends StatelessWidget {
  const GlassTabBadge({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final GlassNavStyle style;

  static const double _height = 16;
  static const double _ringWidth = 1.33;
  static const double _radius = 9.33;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: _height),
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: style.badgeColor,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: style.badgeBorderColor,
          width: _ringWidth,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: style.badgeTextColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}
