import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, PlatformDispatcher;
import 'ui/welcome_page.dart';
import 'theme_notifier.dart';
import 'package:get/get.dart';
import 'controllers/global_user_controller.dart';
import 'controllers/chat_background_controller.dart';

void main() {
  // Pastikan binding Flutter siap sebelum memanggil API platform
  WidgetsFlutterBinding.ensureInitialized();

  // ── Suppress known Flutter Web engine bug (ViewInsets negative on resize) ──
  // Terjadi saat Chrome DevTools Responsive Mode me-resize jendela.
  // Ini bug di Flutter engine (window.dart:347), bukan bug di kode app.
  if (kIsWeb) {
    // Handler 1: Flutter framework errors (sync)
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.exceptionAsString();
      if (msg.contains('ViewInsets cannot be negative') ||
          msg.contains('_viewInsets.isNonNegative')) {
        return; // abaikan — bug Flutter Web engine saat browser resize
      }
      FlutterError.presentError(details);
    };

    // Handler 2: Dart async errors (uncaught in promise)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final msg = error.toString();
      if (msg.contains('ViewInsets cannot be negative') ||
          msg.contains('_viewInsets.isNonNegative') ||
          msg.contains('physicalSize')) {
        return true; // ditangani — jangan lempar ke console
      }
      return false; // biarkan sistem menangani error lain
    };
  }

  // Inisialisasi State Management global sebelum runApp
  Get.put(GlobalUserController());
  // permanent: true → controller TIDAK pernah di-dispose saat halaman pop
  // Tanpa ini, BackgroundPesanPage yang juga memanggil Get.put akan
  // men-dispose controller saat halaman ditutup → data wallpaper hilang.
  Get.put(ChatBackgroundController(), permanent: true);

  runApp(const SpeakApp());
}

class SpeakApp extends StatelessWidget {
  const SpeakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        // GetMaterialApp WAJIB agar Get.back(), Get.snackbar(), Get.find()
        // semuanya berjalan di Web maupun Android tanpa LateInitializationError.
        return GetMaterialApp(
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
            scaffoldBackgroundColor: const Color(0xFF0A1128),
            cardColor: const Color(0xFF111C44),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: const WelcomePage(),
        );
      },
    );
  }
}
