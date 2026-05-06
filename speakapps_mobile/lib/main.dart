import 'package:flutter/material.dart';
import 'ui/welcome_page.dart';
import 'theme_notifier.dart';

void main() {
  runApp(const SpeakApp());
}

class SpeakApp extends StatelessWidget {
  const SpeakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'SpeakApp',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF6A039),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F1EB),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF6A039),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0A1128), // Deep navy blue
            cardColor: const Color(0xFF111C44), // New navy for cards
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: const WelcomePage(),
        );
      },
    );
  }
}
