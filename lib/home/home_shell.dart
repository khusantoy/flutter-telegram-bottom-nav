import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'nav/glass_tab_bar.dart';
import 'tabs/chats_tab.dart';
import 'tabs/contacts_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/settings_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController = PageController();
  late final AnimationController _tapAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 540),
  );

  int _currentIndex = 0;
  double _swipePosition = 0;
  bool _isTapJumping = false;
  int _tapSource = 0;
  int _tapTarget = 0;

  static const _tabs = <GlassTabSpec>[
    GlassTabSpec(
      icon: Icons.chat_bubble_outline,
      label: 'Chats',
      badgeCount: 3,
    ),
    GlassTabSpec(icon: Icons.contacts_outlined, label: 'Contacts'),
    GlassTabSpec(icon: Icons.settings_outlined, label: 'Settings'),
    GlassTabSpec(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
    _tapAnim.addListener(() {
      if (_isTapJumping) setState(() {});
    });
  }

  void _onPageScroll() {
    if (_isTapJumping) return;
    if (_pageController.hasClients &&
        _pageController.position.haveDimensions) {
      final p = _pageController.page;
      if (p != null) {
        setState(() => _swipePosition = p);
      }
    }
  }

  List<double> _computeFactors() {
    if (_isTapJumping) {
      final p = Curves.easeOutQuint.transform(_tapAnim.value);
      return List.generate(_tabs.length, (i) {
        if (i == _tapSource) return 1 - p;
        if (i == _tapTarget) return p;
        return 0.0;
      });
    }
    return List.generate(_tabs.length, (i) {
      return (1.0 - (_swipePosition - i).abs()).clamp(0.0, 1.0);
    });
  }

  Future<void> _onTabTap(int index) async {
    if (_isTapJumping) return;
    if (index == _currentIndex) return;

    setState(() {
      _tapSource = _currentIndex;
      _tapTarget = index;
      _isTapJumping = true;
    });

    // 540ms easeOutQuint — matches ViewPagerFixed.getManualScrollDuration
    // + CubicBezierInterpolator.EASE_OUT_QUINT in Telegram.
    await _tapAnim.forward(from: 0);

    // Sync PageView to the target without scrolling through intermediates.
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }

    setState(() {
      _currentIndex = index;
      _swipePosition = index.toDouble();
      _isTapJumping = false;
    });
  }

  Widget _pageAt(int i) {
    switch (i) {
      case 0:
        return const ChatsTab();
      case 1:
        return const ContactsTab();
      case 2:
        return const SettingsTab();
      case 3:
        return const ProfileTab();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Manual two-page slide that mimics Telegram's ViewPagerFixed: only the
  /// source and destination pages are ever rendered, and they slide a single
  /// screen-width regardless of how far apart their indices are.
  Widget _buildTapOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final t = Curves.easeOutQuint.transform(_tapAnim.value);
        final dir = _tapTarget > _tapSource ? 1.0 : -1.0;
        return Stack(
          children: [
            Positioned(
              left: -dir * w * t,
              top: 0,
              width: w,
              height: h,
              child: _pageAt(_tapSource),
            ),
            Positioned(
              left: dir * w * (1 - t),
              top: 0,
              width: w,
              height: h,
              child: _pageAt(_tapTarget),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final factors = _computeFactors();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Telegram's checkSystemBarColors picks icon brightness via perceived
    // luminance (>= .721f → dark icons). Here we just key off the active
    // theme — equivalent result since our scaffoldBackgroundColor is light
    // grey in light theme and black in dark theme.
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // PageView always mounted so _pageController has clients; swipe
            // still works. During a tap-jump, the overlay covers it
            // completely.
            PageView(
              controller: _pageController,
              onPageChanged: (i) {
                if (!_isTapJumping) {
                  setState(() => _currentIndex = i);
                }
              },
              children: const [
                ChatsTab(),
                ContactsTab(),
                SettingsTab(),
                ProfileTab(),
              ],
            ),
            if (_isTapJumping) _buildTapOverlay(),
            GlassTabBar(
              tabs: _tabs,
              selectionFactors: factors,
              onTap: _onTabTap,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _tapAnim.dispose();
    super.dispose();
  }
}
