import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/glass_nav_item.dart';
import '../models/glass_nav_style.dart';
import 'glass_fade_backdrop.dart';
import 'glass_tab.dart';

/// Telegram MainTabsActivity-style floating pill navigation bar.
///
/// Pure presentational widget — takes a list of [items] and a
/// [selectionFactors] vector (one factor per item in `[0, 1]`). Selection
/// state is owned by the parent so the same widget works with either a
/// PageView-driven controller (continuous swipe) or a discrete external
/// state-machine.
///
/// For a batteries-included setup with paged content + tap animations, see
/// `GlassNavScaffold`.
class GlassNavigationBar extends StatelessWidget {
  const GlassNavigationBar({
    super.key,
    required this.items,
    required this.selectionFactors,
    required this.onTap,
    this.style = const GlassNavStyle(),
  }) : assert(items.length == selectionFactors.length);

  final List<GlassNavItem> items;
  final List<double> selectionFactors;
  final ValueChanged<int> onTap;
  final GlassNavStyle style;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: style.outerHeight + bottomInset,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(child: GlassFadeBackdrop(style: style)),
            Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SizedBox(
                width: style.outerWidth,
                height: style.outerHeight,
                child: Center(child: _Pill(
                  items: items,
                  selectionFactors: selectionFactors,
                  onTap: onTap,
                  style: style,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.items,
    required this.selectionFactors,
    required this.onTap,
    required this.style,
  });

  final List<GlassNavItem> items;
  final List<double> selectionFactors;
  final ValueChanged<int> onTap;
  final GlassNavStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: style.pillWidth,
      height: style.pillHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style.pillRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: style.blurSigma,
            sigmaY: style.blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: style.glassTint,
              borderRadius: BorderRadius.circular(style.pillRadius),
              border: Border.all(
                color: style.glassBorderColor,
                width: style.glassBorderWidth,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(style.innerPadding),
              child: Row(
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: GlassTab(
                      item: items[i],
                      selectionFactor: selectionFactors[i],
                      style: style,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
