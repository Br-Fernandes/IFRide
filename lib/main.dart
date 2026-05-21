import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/utils/themes.dart';
import 'package:if_ride/views/screens/auth_screen.dart';
import 'package:if_ride/views/screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController(), permanent: true);

    return GetMaterialApp(
      title: 'IF Ride',
      debugShowCheckedModeBanner: false,
      theme: ThemeColors.lightTheme,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      switch (authController.authStatus.value) {
        case AuthStatus.loading:
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        case AuthStatus.authenticated:
          return const MainNavigationScreen();
        case AuthStatus.unauthenticated:
          return const AuthScreen();
      }
    });
  }
}
