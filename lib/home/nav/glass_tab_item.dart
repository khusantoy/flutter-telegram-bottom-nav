import 'package:flutter/material.dart';

import '../../theme/telegram_theme.dart';
import 'tab_badge.dart';

class GlassTabItem extends StatelessWidget {
  const GlassTabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selectionFactor,
    required this.onTap,
    this.badgeCount = 0,
    this.badgeText,
  });

  final IconData icon;
  final String label;
  final double selectionFactor;
  final VoidCallback onTap;
  final int badgeCount;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TelegramTabColors>()!;

    // Telegram uses DECELERATE_INTERPOLATOR on selectedFactor for alpha.
    final pillAlphaFactor = Curves.decelerate.transform(selectionFactor);
    final pillScale = 0.6 + 0.4 * selectionFactor;

    final iconColor = Color.lerp(
      colors.tabUnselected,
      colors.tabSelectedText,
      selectionFactor,
    )!;
    final textColor = iconColor;
    // Typeface swaps instantly at selection start (no crossfade).
    final fontWeight =
        selectionFactor > 0.5 ? FontWeight.w900 : FontWeight.w700;

    final showBadge =
        badgeCount > 0 || (badgeText != null && badgeText!.isNotEmpty);

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
              // Per-tab pill background — drawn behind children, scaled around
              // center. This is what Telegram's GlassTabView does in
              // dispatchDraw BEFORE super.dispatchDraw().
              Positioned.fill(
                child: Transform.scale(
                  scale: pillScale,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.tabSelectedPill.withValues(
                        alpha: 0.09 * pillAlphaFactor,
                      ),
                      borderRadius: BorderRadius.circular(pillRadius),
                    ),
                  ),
                ),
              ),
              // Icon (Telegram: 24dp Lottie inside 44dp frame, marginTop -6dp).
              // Approximated as a static icon at y=4 from top of cell.
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: Icon(icon, size: 24, color: iconColor),
              ),
              // Label at marginTop=28.33dp, fontSize=12dp.
              Positioned(
                left: 0,
                right: 0,
                top: 30,
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: fontWeight,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              // Counter badge — positioned at cx = viewWidth/2 + 11dp,
              // cy = 10dp (in Telegram). Translate accordingly.
              if (showBadge)
                Positioned(
                  left: w / 2 + 11 - 8,
                  top: 10 - 8,
                  child: TabBadge(
                    text: badgeText ?? '$badgeCount',
                    color: colors.badgeColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
