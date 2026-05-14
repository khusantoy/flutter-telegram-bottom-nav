import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../glass_nav/glass_nav.dart';
import 'tabs/chats_tab.dart';
import 'tabs/contacts_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/settings_tab.dart';

/// Demo screen — shows how a host app wires up `GlassNavScaffold`. Custom
/// SystemUI overlay style is the only host concern; the package handles the
/// rest.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _items = <GlassNavItem>[
    GlassNavItem(
      icon: Icon(Icons.chat_bubble_outline),
      label: 'Chats',
      badge: '3',
    ),
    GlassNavItem(icon: Icon(Icons.contacts_outlined), label: 'Contacts'),
    GlassNavItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
    GlassNavItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  static const _pages = <Widget>[
    ChatsTab(),
    ContactsTab(),
    SettingsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: GlassNavScaffold(
        items: _items,
        pages: _pages,
        style: isDark ? _darkStyle : _lightStyle,
      ),
    );
  }

  // Theme-aware tints — package style is just a value object, so we keep
  // two presets here instead of plumbing context-dependent colors inside.
  static const _lightStyle = GlassNavStyle();
  static const _darkStyle = GlassNavStyle(
    glassTint: Color(0xB81C1C1E),
    glassBorderColor: Color(0x33FFFFFF),
    selectedColor: Color(0xFF3478F6),
  );
}
