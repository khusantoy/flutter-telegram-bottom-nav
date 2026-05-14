import 'package:flutter/material.dart';

import '../models/glass_nav_style.dart';

/// Owns the runtime state for `GlassNavScaffold` — current index, swipe
/// position, and the tap-jump animation. Exposes a [selectionFactors]
/// vector that the bar widget consumes directly.
///
/// Selection-factor semantics (matching Telegram):
/// - **Swipe** (gesture): factor[i] = `max(0, 1 - |swipePos - i|)` — only
///   adjacent tabs activate.
/// - **Tap-jump**: only `source` and `target` animate; intermediates stay
///   at 0. Mirrors `MainTabsActivity.selectTab(current, next, progress)`.
/// - **Interrupted tap-jump**: the previous target's factor fades smoothly
///   to 0 instead of snapping, so users never see a pill flash on a tab
///   they didn't end up navigating to.
class GlassNavController extends ChangeNotifier {
  GlassNavController({
    required this.itemCount,
    required TickerProvider vsync,
    required this.style,
    int initialIndex = 0,
  })  : assert(itemCount > 0),
        assert(initialIndex >= 0 && initialIndex < itemCount),
        _currentIndex = initialIndex,
        _swipePosition = initialIndex.toDouble(),
        _pageController = PageController(initialPage: initialIndex),
        _tapAnim = AnimationController(
          vsync: vsync,
          duration: style.tapDuration,
        ) {
    _pageController.addListener(_onPageScroll);
    _tapAnim.addListener(_onTapTick);
  }

  final int itemCount;
  final GlassNavStyle style;
  final PageController _pageController;
  final AnimationController _tapAnim;

  int _currentIndex;
  double _swipePosition;
  bool _isTapJumping = false;
  int _tapSource = 0;
  int _tapTarget = 0;

  // Snapshot of per-tab factors captured at the moment a jump starts. While
  // the jump animates, every tab fades from its snapshot value to its target
  // value (1 for [_tapTarget], 0 for everyone else) interpolated by the curve.
  // Interrupting a jump just re-snapshots the live factors, so users never
  // see a tab snap from a partial value to 1 (the bug where Profile briefly
  // re-activated when a 0→3 jump was interrupted by a tap on tab 1).
  late List<double> _factorSnapshot = List<double>.filled(itemCount, 0)
    ..[_currentIndex] = 1;

  /// Bumped on every jumpTo so a superseded animation can detect that it is
  /// stale and skip finalization.
  int _jumpVersion = 0;

  PageController get pageController => _pageController;
  int get currentIndex => _currentIndex;
  bool get isTapJumping => _isTapJumping;
  int get tapSource => _tapSource;
  int get tapTarget => _tapTarget;
  double get tapProgress => _tapAnim.value;

  /// Per-item factor in `[0, 1]`, ready to feed into `GlassNavigationBar`.
  List<double> selectionFactors() {
    if (_isTapJumping) {
      final p = style.tapCurve.transform(_tapAnim.value);
      final factors = List<double>.filled(itemCount, 0);
      for (var i = 0; i < itemCount; i++) {
        final start = _factorSnapshot[i];
        final end = i == _tapTarget ? 1.0 : 0.0;
        factors[i] = start + (end - start) * p;
      }
      return factors;
    }

    final factors = List<double>.filled(itemCount, 0);
    for (var i = 0; i < itemCount; i++) {
      factors[i] = (1.0 - (_swipePosition - i).abs()).clamp(0.0, 1.0);
    }
    return factors;
  }

  // Compute the visible factor for tab [i] right now — used to snapshot
  // factors at the moment a jump starts (or is interrupted by another jump).
  double _currentFactor(int i) {
    if (_isTapJumping) {
      final p = style.tapCurve.transform(_tapAnim.value);
      final start = _factorSnapshot[i];
      final end = i == _tapTarget ? 1.0 : 0.0;
      return start + (end - start) * p;
    }
    return (1.0 - (_swipePosition - i).abs()).clamp(0.0, 1.0);
  }

  void _onPageScroll() {
    if (_isTapJumping) return;
    if (!_pageController.hasClients ||
        !_pageController.position.haveDimensions) {
      return;
    }
    final p = _pageController.page;
    if (p == null) return;
    _swipePosition = p.clamp(0.0, (itemCount - 1).toDouble());
    notifyListeners();
  }

  void _onTapTick() {
    if (_isTapJumping) notifyListeners();
  }

  /// Called by the host when PageView's onPageChanged fires.
  void onPageSettled(int index) {
    if (_isTapJumping) return;
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// Initiate a tap-driven jump to [target]. If another jump is in flight,
  /// it is canceled and this one takes over from the last settled tab.
  Future<void> jumpTo(int target) async {
    assert(target >= 0 && target < itemCount);
    // Idle and already on this tab → no-op (host can hook for scroll-to-top).
    if (!_isTapJumping && target == _currentIndex) return;
    // Already animating toward this exact target → ignore repeated taps so
    // we don't restart the animation on every press.
    if (_isTapJumping && target == _tapTarget) return;

    // Snapshot the CURRENT visible factors before resetting state. Whether
    // this is a fresh jump (from idle/swipe) or interrupting another jump,
    // _currentFactor reflects what the user sees right now — so the new
    // animation will continuously fade those values toward the new target
    // instead of snapping any tab to a different starting value.
    _factorSnapshot =
        List<double>.generate(itemCount, _currentFactor, growable: false);

    final myVersion = ++_jumpVersion;
    _tapSource = _currentIndex;
    _tapTarget = target;
    _currentIndex = target;
    _isTapJumping = true;
    _tapAnim.duration = style.tapDuration;
    _tapAnim.value = 0;
    notifyListeners();

    try {
      await _tapAnim.forward();
    } catch (_) {
      return;
    }

    if (myVersion != _jumpVersion) return;

    if (_pageController.hasClients) {
      _pageController.jumpToPage(target);
    }
    _swipePosition = target.toDouble();
    _isTapJumping = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _tapAnim.dispose();
    super.dispose();
  }
}
