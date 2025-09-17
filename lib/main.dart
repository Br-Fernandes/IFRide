import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/utils/themes.dart';
import 'package:if_ride/views/screens/auth_screen.dart';
import 'package:if_ride/views/screens/home_screen.dart';
import 'package:if_ride/views/screens/main_navigation_screen.dart';
import 'package:if_ride/views/screens/new_ride_screen.dart';
import 'package:if_ride/views/screens/your_rides_screen.dart';
import 'package:if_ride/views/widgets/recurring_ride.dart';
import 'package:if_ride/views/widgets/steptwo_ride.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeColors.lightTheme,
      home: RecurringRide(),
    );
  }
}

class Initializer extends StatelessWidget {
  const Initializer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController(), permanent: true);
  
    return Obx(() {
      if(authController.isAuthenticated) {
        return const MainNavigationScreen();
      } else {
        return AuthScreen();
      }
    });
  }
}