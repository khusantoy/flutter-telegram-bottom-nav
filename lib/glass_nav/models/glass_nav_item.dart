import 'package:flutter/widgets.dart';

/// Pure data model for a single tab. Decoupled from any styling so the
/// caller can swap [icon] for Icon, SvgPicture, Lottie, etc.
@immutable
class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  /// Default icon. Recieves a [Color] via parent's `IconTheme` so it tints
  /// with selection state.
  final Widget icon;

  /// Optional alternate icon shown when this tab is fully selected.
  /// If null, [icon] is used in both states.
  final Widget? selectedIcon;

  final String label;

  /// Plain string badge — e.g. unread count "12" or "!" for warnings. Null
  /// or empty hides the badge.
  final String? badge;
}
