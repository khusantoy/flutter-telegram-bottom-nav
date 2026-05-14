import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home/home_shell.dart';
import 'theme/telegram_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Equivalent to Telegram's AndroidUtilities.enableEdgeToEdge(this) — lets
  // the app draw behind both system bars so the floating tab pill can sit
  // above a transparent nav bar.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Bottom Nav',
      debugShowCheckedModeBanner: false,
      theme: telegramLightTheme(),
      darkTheme: telegramDarkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
