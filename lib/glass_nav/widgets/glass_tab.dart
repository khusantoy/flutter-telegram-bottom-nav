import 'package:flutter/material.dart';

import '../models/glass_nav_item.dart';
import '../models/glass_nav_style.dart';
import 'glass_tab_badge.dart';

/// Single tab cell. Stateless — takes a precomputed [selectionFactor] in
/// `[0, 1]` and renders the pill, icon, label, and optional badge.
///
/// Pill semantics (matching Telegram `GlassTabView`):
/// - opacity = `style.pillIndicatorOpacity * pillCurve(selectionFactor)`
/// - scale   = lerp(`pillScaleStart`, `pillScaleEnd`, selectionFactor)
/// - drawn behind icon/label (Stack child #0)
class GlassTab extends StatelessWidget {
  const GlassTab({
    super.key,
    required this.item,
    required this.selectionFactor,
    required this.style,
    required this.onTap,
  });

  final GlassNavItem item;
  final double selectionFactor;
  final GlassNavStyle style;
  final VoidCallback onTap;

  bool get _isSelected => selectionFactor > 0.5;

  @override
  Widget build(BuildContext context) {
    final pillAlpha = style.pillCurve.transform(selectionFactor.clamp(0, 1));
    final pillScale = style.pillScaleStart +
        (style.pillScaleEnd - style.pillScaleStart) * selectionFactor;
    final color = Color.lerp(
      style.unselectedColor,
      style.selectedColor,
      selectionFactor,
    )!;
    final activeIcon = _isSelected ? (item.selectedIcon ?? item.icon) : item.icon;
    final hasBadge = item.badge != null && item.badge!.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final pillRadius = (w < h ? w : h) / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              _PillIndicator(
                opacity: style.pillIndicatorOpacity * pillAlpha,
                color: style.selectedColor,
                scale: pillScale,
                radius: pillRadius,
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: IconTheme(
                  data: IconThemeData(color: color, size: style.iconSize),
                  child: Center(child: activeIcon),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: style.labelTopOffset,
                child: Center(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: style.labelFontSize,
                      color: color,
                      fontWeight: _isSelected
                          ? style.selectedWeight
                          : style.unselectedWeight,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              if (hasBadge)
                Positioned(
                  left: w / 2 + 11 - 8,
                  top: 10 - 8,
                  child: GlassTabBadge(text: item.badge!, style: style),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PillIndicator extends StatelessWidget {
  const _PillIndicator({
    required this.opacity,
    required this.color,
    required this.scale,
    required this.radius,
  });

  final double opacity;
  final Color color;
  final double scale;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Transform.scale(
        scale: scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
