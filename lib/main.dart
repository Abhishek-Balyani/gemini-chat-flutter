import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/network/dio_client.dart';
import 'core/services/audio_service.dart';
import 'core/services/document_parser_service.dart';
import 'core/services/gemini_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'modules/auth/bindings/auth_binding.dart';
import 'modules/auth/views/auth_routes.dart';
import 'modules/home/home_binding.dart';
import 'modules/home/home_view.dart';
import 'modules/profile/profile_binding.dart';
import 'modules/profile/profile_view.dart';
import 'modules/settings/settings_binding.dart';
import 'modules/settings/settings_view.dart';
import 'modules/splash/splash_binding.dart';
import 'modules/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // If .env asset fails to load, fallback safely
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Falls back if native config is not attached yet
  }

  // Initialize Core Services
  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService, permanent: true);
  Get.put<ThemeService>(ThemeService(storageService), permanent: true);

  final dioClient = DioClient();
  Get.put<DioClient>(dioClient, permanent: true);

  Get.put<GeminiService>(
    GeminiService(dioClient, storageService),
    permanent: true,
  );

  final audioService = await AudioService().init();
  Get.put<AudioService>(audioService, permanent: true);

  Get.put<DocumentParserService>(DocumentParserService(), permanent: true);

  // Initialize Auth Module Dependencies
  AuthBinding().dependencies();

  runApp(const AIChatApp());
}

class AIChatApp extends StatelessWidget {
  const AIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return GetMaterialApp(
      title: 'AI Chat Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsView(),
          binding: SettingsBinding(),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileView(),
          binding: ProfileBinding(),
        ),
        ...AuthRoutes.routes,
      ],
    );
  }
}
