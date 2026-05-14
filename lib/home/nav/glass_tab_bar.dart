import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/telegram_theme.dart';
import 'glass_tab_item.dart';

class GlassTabSpec {
  const GlassTabSpec({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
    this.badgeText,
  });

  final IconData icon;
  final String label;
  final int badgeCount;
  final String? badgeText;
}

/// Telegram MainTabsActivity bottom bar — two visual layers.
///
/// 1. **fadeView** — full-width bottom-anchored blur strip. Covers the tab
///    area + the system navigation bar area. Top 60 dp is a transparent→
///    opaque gradient (Telegram's `setFadeHeight(60dp, true)`); below it is
///    fully opaque blur. The opaque region behind the system nav bar is
///    what makes the OS buttons appear over a blurred backdrop.
///
/// 2. **tabsView** — the 328×56 floating pill on top of fadeView, with its
///    own BackdropFilter for an additional glass layer.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.tabs,
    required this.selectionFactors,
    required this.onTap,
  }) : assert(tabs.length == selectionFactors.length);

  final List<GlassTabSpec> tabs;
  final List<double> selectionFactors;
  final ValueChanged<int> onTap;

  static const double _outerWidth = 344;
  static const double _outerHeight = 72;
  static const double _pillWidth = 328;
  static const double _pillHeight = 56;
  static const double _innerPad = 4;
  static const double _fadeHeight = 60;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TelegramTabColors>()!;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    // Telegram fadeView height = navigationBarHeight + MAIN_TABS_HEIGHT_WITH_MARGINS
    // (72dp). The 60dp fade zone is INSIDE this strip (at its top), NOT
    // added on top of it. So the strip top aligns with the pill top — the
    // fade overlaps with the pill region itself.
    final stripHeight = _outerHeight + bottomInset;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: stripHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: _FadeBlurStrip(
                  fadeHeight: _fadeHeight,
                  totalHeight: stripHeight,
                  tint: colors.glassBackground,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SizedBox(
                width: _outerWidth,
                height: _outerHeight,
                child: Center(
                  child: SizedBox(
                    width: _pillWidth,
                    height: _pillHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_pillHeight / 2),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.glassBackground,
                            borderRadius:
                                BorderRadius.circular(_pillHeight / 2),
                            border: Border.all(
                              color: colors.glassBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(_innerPad),
                            child: Row(
                              children: List.generate(tabs.length, (i) {
                                final spec = tabs[i];
                                return Expanded(
                                  child: GlassTabItem(
                                    icon: spec.icon,
                                    label: spec.label,
                                    selectionFactor: selectionFactors[i],
                                    onTap: () => onTap(i),
                                    badgeCount: spec.badgeCount,
                                    badgeText: spec.badgeText,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flutter equivalent of Telegram's `BlurredBackgroundWithFadeDrawable` +
/// `setFadeHeight(60dp)`. ShaderMask applies a vertical alpha gradient so
/// the top of the strip is fully transparent and the rest is opaque blur.
class _FadeBlurStrip extends StatelessWidget {
  const _FadeBlurStrip({
    required this.fadeHeight,
    required this.totalHeight,
    required this.tint,
  });

  final double fadeHeight;
  final double totalHeight;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final fadeStop = (fadeHeight / totalHeight).clamp(0.0, 1.0);
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Colors.transparent, Colors.black],
          stops: [0.0, fadeStop],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: ColoredBox(color: tint),
        ),
      ),
    );
  }
}
