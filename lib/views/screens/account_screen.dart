import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color?>(Colors.red),
            foregroundColor: WidgetStateProperty.all<Color?>(Colors.black)
          ),
          onPressed: () => authController.logout(),
          child: Text("Sair da conta")
        ),
      ),
    );
  }
}