import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/views/screens/vehicle_screen.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.05, vertical: Get.height * 0.05),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        user.name,
                        maxFontSize: 25,
                        minFontSize: 17,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      AutoSizeText(
                        _roleLabel(user.role),
                        maxFontSize: 16,
                        minFontSize: 12,
                        style: TextStyle(
                          color: _roleColor(user.role),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AutoSizeText(
                        user.email,
                        maxFontSize: 13,
                        minFontSize: 10,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: Get.height * 0.05,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 36, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: Get.height * 0.04),
              if (user.isDriver) ...[
                _ActionItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Meus veículos',
                  onTap: () => Get.to(() => VehicleScreen()),
                ),
                SizedBox(height: Get.height * 0.02),
              ],
              _ActionItem(
                icon: Icons.edit_outlined,
                label: 'Alterar dados pessoais',
                onTap: () {},
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: Get.height * 0.03),
                height: 1,
                color: Colors.grey.shade200,
              ),
              _ActionItem(
                icon: Icons.logout,
                label: 'Sair',
                onTap: () => authController.logout(),
                color: Colors.black,
              ),
              SizedBox(height: Get.height * 0.02),
              _ActionItem(
                icon: Icons.delete_outline,
                label: 'Excluir conta',
                onTap: () {},
                color: Colors.red,
              ),
            ],
          ),
        );
      }),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'DRIVER':
        return 'Motorista';
      case 'ADMIN':
        return 'Administrador';
      default:
        return 'Passageiro';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'DRIVER':
        return Colors.green;
      case 'ADMIN':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: c, fontSize: 15)),
        ],
      ),
    );
  }
}
