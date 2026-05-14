import 'package:flutter/material.dart';

import '../controllers/glass_nav_controller.dart';
import '../models/glass_nav_item.dart';
import '../models/glass_nav_style.dart';
import 'glass_navigation_bar.dart';

/// Batteries-included shell: PageView + GlassNavigationBar + the Telegram
/// "destination slides in from one screen away" tap transition.
///
/// Usage:
/// ```dart
/// GlassNavScaffold(
///   items: [
///     GlassNavItem(icon: Icon(Icons.chat), label: 'Chats'),
///     GlassNavItem(icon: Icon(Icons.person), label: 'Profile'),
///   ],
///   pages: [ChatsPage(), ProfilePage()],
/// )
/// ```
class GlassNavScaffold extends StatefulWidget {
  const GlassNavScaffold({
    super.key,
    required this.items,
    required this.pages,
    this.style = const GlassNavStyle(),
    this.initialIndex = 0,
    this.onTabChanged,
  })  : assert(items.length == pages.length),
        assert(items.length > 0);

  final List<GlassNavItem> items;
  final List<Widget> pages;
  final GlassNavStyle style;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;

  @override
  State<GlassNavScaffold> createState() => _GlassNavScaffoldState();
}

class _GlassNavScaffoldState extends State<GlassNavScaffold>
    with SingleTickerProviderStateMixin {
  late final GlassNavController _controller = GlassNavController(
    itemCount: widget.items.length,
    vsync: this,
    style: widget.style,
    initialIndex: widget.initialIndex,
  );

  // Drops taps that arrive too soon after the previous one — guards against
  // two-finger drumming on the bar, which would otherwise restart the jump
  // animation on every press and look like a flicker.
  static const _tapDebounce = Duration(milliseconds: 150);
  DateTime _lastTapAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    final now = DateTime.now();
    if (now.difference(_lastTapAt) < _tapDebounce) return;
    _lastTapAt = now;

    widget.onTabChanged?.call(index);
    _controller.jumpTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              PageView(
                controller: _controller.pageController,
                onPageChanged: _controller.onPageSettled,
                children: widget.pages,
              ),
              if (_controller.isTapJumping)
                _TapJumpOverlay(
                  source: widget.pages[_controller.tapSource],
                  target: widget.pages[_controller.tapTarget],
                  forward: _controller.tapTarget > _controller.tapSource,
                  progress: widget.style.tapCurve
                      .transform(_controller.tapProgress),
                ),
              GlassNavigationBar(
                items: widget.items,
                selectionFactors: _controller.selectionFactors(),
                style: widget.style,
                onTap: _handleTap,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Single-screen-width slide between [source] and [target] pages — used
/// during tap-jumps so intermediate pages are never rendered (matches
/// Telegram's `ViewPagerFixed.scrollToPosition`).
class _TapJumpOverlay extends StatelessWidget {
  const _TapJumpOverlay({
    required this.source,
    required this.target,
    required this.forward,
    required this.progress,
  });

  final Widget source;
  final Widget target;
  final bool forward;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final dir = forward ? 1.0 : -1.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            Positioned(
              left: -dir * w * progress,
              top: 0,
              width: w,
              height: h,
              child: source,
            ),
            Positioned(
              left: dir * w * (1 - progress),
              top: 0,
              width: w,
              height: h,
              child: target,
            ),
          ],
        );
      },
    );
  }
}
