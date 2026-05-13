import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/user.dart';
import 'package:if_ride/utils/themes.dart';
import 'package:if_ride/views/screens/auth_screen.dart';
import 'package:if_ride/views/screens/chat_screen.dart';
import 'package:if_ride/views/screens/main_navigation_screen.dart';
import 'package:if_ride/views/screens/new_ride_screen.dart';

import 'utils/constants.dart';

// ---------------------------------------------------------------
// MODO DE TESTE: mude para false para voltar ao fluxo normal
const _testChatMode = false;
// ---------------------------------------------------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController(), permanent: true);

    if (_testChatMode) {
      // Injeta usuário fake para que o ChatScreen saiba qual lado é "eu"
      authController.currentUser.value = User(
        id: 'mock-id-123',
        name: 'Eu (teste)',
        email: 'teste@ifride.com',
        imageUrl: '',
        city: 'Orizona',
      );
    }

    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeColors.lightTheme,
      home: _testChatMode
          ? ChatScreen(
              rideId: 'test-ride-001',
              recipientId: 'ghost-user-001',
              recipientName: 'Usuário Fantasma',
              mockMode: true,
            )
          : MainNavigationScreen(),
    );
  }
}

class Initializer extends StatelessWidget {
  const Initializer({super.key});

  @override
  Widget build(BuildContext context) {
  
    return Obx(() {
      if(authController.isAuthenticated) {
        return const MainNavigationScreen();
      } else {
        return AuthScreen();
      }
    });
  }
}