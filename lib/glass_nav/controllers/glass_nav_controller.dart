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

  PageController get pageController => _pageController;
  int get currentIndex => _currentIndex;
  bool get isTapJumping => _isTapJumping;
  int get tapSource => _tapSource;
  int get tapTarget => _tapTarget;
  double get tapProgress => _tapAnim.value;

  /// Per-item factor in `[0, 1]` — fed directly to `GlassNavigationBar`.
  List<double> selectionFactors() {
    if (_isTapJumping) {
      final p = style.tapCurve.transform(_tapAnim.value);
      return List.generate(itemCount, (i) {
        if (i == _tapSource) return 1 - p;
        if (i == _tapTarget) return p;
        return 0.0;
      });
    }
    return List.generate(itemCount, (i) {
      return (1.0 - (_swipePosition - i).abs()).clamp(0.0, 1.0);
    });
  }

  void _onPageScroll() {
    if (_isTapJumping) return;
    if (!_pageController.hasClients ||
        !_pageController.position.haveDimensions) {
      return;
    }
    final p = _pageController.page;
    if (p == null) return;
    _swipePosition = p;
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

  /// Initiate a tap-driven jump to [target]. Returns the animation future.
  /// Caller is responsible for syncing the PageView via [jumpPageView] after.
  Future<void> jumpTo(int target) async {
    if (_isTapJumping) return;
    if (target == _currentIndex) return;
    assert(target >= 0 && target < itemCount);

    _tapSource = _currentIndex;
    _tapTarget = target;
    _isTapJumping = true;
    _tapAnim.duration = style.tapDuration;
    notifyListeners();

    await _tapAnim.forward(from: 0);

    if (_pageController.hasClients) {
      _pageController.jumpToPage(target);
    }
    _currentIndex = target;
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
