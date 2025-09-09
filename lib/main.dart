import 'package:flutter/material.dart';
import 'package:if_ride/utils/themes.dart';
import 'package:if_ride/views/screens/auth_screen.dart';
import 'package:if_ride/views/screens/home_screen.dart';
import 'package:if_ride/views/screens/main_navigation_screen.dart';
import 'package:if_ride/views/screens/new_ride_screen.dart';
import 'package:if_ride/views/screens/your_rides_screen.dart';
import 'package:if_ride/views/widgets/steptwo_ride.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeColors.lightTheme,
      home: AuthScreen(),
    );
  }
}

