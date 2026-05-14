/// Telegram MainTabsActivity-style floating glass bottom navigation.
///
/// Two entry points:
/// - [GlassNavScaffold] — full screen: PageView + bar + tap-jump overlay.
/// - [GlassNavigationBar] — just the bar; bring your own state.
///
/// Customize via [GlassNavStyle.copyWith] or [GlassNavStyleProvider].
library;

export 'controllers/glass_nav_controller.dart';
export 'models/glass_nav_item.dart';
export 'models/glass_nav_style.dart';
export 'widgets/glass_fade_backdrop.dart';
export 'widgets/glass_nav_scaffold.dart';
export 'widgets/glass_navigation_bar.dart';
export 'widgets/glass_tab.dart';
export 'widgets/glass_tab_badge.dart';
