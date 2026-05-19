import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth_controller.dart';
import 'controllers/favorite_controller.dart';
import 'routes/app_routes.dart';
import 'services/favorite_service.dart';
import 'services/session_service.dart';
import 'services/tvmaze_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await FavoriteService.init();

  final preferences = await SharedPreferences.getInstance();
  setupDependencies(preferences);

  final isLoggedIn = await Get.find<SessionService>().isLoggedIn();

  runApp(MyApp(initialRoute: isLoggedIn ? AppRoutes.main : AppRoutes.login));
}

void setupDependencies(SharedPreferences preferences) {
  if (!Get.isRegistered<SessionService>()) {
    Get.put(SessionService(preferences), permanent: true);
  }
  if (!Get.isRegistered<TvMazeApiService>()) {
    Get.put(TvMazeApiService(), permanent: true);
  }
  if (!Get.isRegistered<FavoriteService>()) {
    Get.put(FavoriteService(), permanent: true);
  }
  if (!Get.isRegistered<AuthController>()) {
    Get.put(AuthController(), permanent: true);
  }
  if (!Get.isRegistered<FavoriteController>()) {
    Get.put(FavoriteController(), permanent: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute = AppRoutes.login});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF006D77),
          brightness: Brightness.light,
        ).copyWith(
          secondary: const Color(0xFFE76F51),
          tertiary: const Color(0xFF6A4C93),
          surface: const Color(0xFFF8FAFC),
        );

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hydra Games',
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: scheme.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}
