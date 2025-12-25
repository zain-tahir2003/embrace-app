import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/app/theme/app_theme.dart';
import 'features/auth/lock_screen.dart';

class ThemeController extends GetxController {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(_themeMode);
    update();
  }
}

void main() async {
  // Required to ensure Flutter is ready before GetX starts
  WidgetsFlutterBinding.ensureInitialized();

  // Inject the controller
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: controller.themeMode,
          home: const LockScreen(),
        );
      },
    );
  }
}
