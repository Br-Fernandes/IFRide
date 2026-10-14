import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/driver_application.dart';
import 'package:if_ride/services/auth_service.dart';
import 'package:if_ride/services/driver_service.dart';
import 'package:if_ride/views/screens/edit_profile_screen.dart';
import 'package:if_ride/views/screens/vehicle_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _authController = Get.find<AuthController>();
  final _driverService = DriverService();
  final _authService = AuthService();

  DriverApplicationSummary? _application;
  bool _loadingApplication = false;
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _loadApplicationIfPassenger();
  }

  Future<void> _loadApplicationIfPassenger() async {
    final role = _authController.currentUser.value?.role;
    if (role != 'PASSENGER') return;
    setState(() => _loadingApplication = true);
    try {
      final app = await _driverService.getMyApplication();
      setState(() => _application = app);
    } catch (_) {
      // 404 = nunca solicitou; outros erros silenciados
    } finally {
      setState(() => _loadingApplication = false);
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeletingAccount = true);
    try {
      await _authService.deleteAccount();
      await _authController.logout();
    } catch (e) {
      setState(() => _isDeletingAccount = false);
      Get.snackbar(
        'Erro ao excluir conta',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final user = _authController.currentUser.value;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
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
              SizedBox(height: Get.height * 0.03),

              // Status da solicitação de motorista (apenas PASSENGER)
              if (user.role == 'PASSENGER') ...[
                _DriverApplicationCard(
                  application: _application,
                  isLoading: _loadingApplication,
                ),
                SizedBox(height: Get.height * 0.02),
              ],

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
                onTap: () => Get.to(() => const EditProfileScreen()),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: Get.height * 0.03),
                height: 1,
                color: Colors.grey.shade200,
              ),
              _ActionItem(
                icon: Icons.logout,
                label: 'Sair',
                onTap: () => _authController.logout(),
                color: Colors.black,
              ),
              SizedBox(height: Get.height * 0.02),
              _isDeletingAccount
                  ? const Center(child: CircularProgressIndicator())
                  : _ActionItem(
                      icon: Icons.delete_outline,
                      label: 'Excluir conta',
                      onTap: _confirmDeleteAccount,
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

class _DriverApplicationCard extends StatelessWidget {
  const _DriverApplicationCard({
    required this.application,
    required this.isLoading,
  });
  final DriverApplicationSummary? application;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Verificando solicitação...', style: TextStyle(color: Colors.black54, fontSize: 13)),
          ],
        ),
      );
    }
    if (application == null) return const SizedBox.shrink();

    final info = _statusInfo(application!.applicationStatus);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: info.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(info.icon, color: info.color, size: 18),
              const SizedBox(width: 8),
              Text(
                'Solicitação de Motorista',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: info.color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  info.label,
                  style: TextStyle(fontSize: 11, color: info.color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (application!.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Text(
              'Motivo: ${application!.rejectionReason}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  _AppStatusInfo _statusInfo(String status) {
    switch (status) {
      case 'APPROVED':
        return _AppStatusInfo('Aprovada', Colors.green, Icons.check_circle_outline);
      case 'DENIED':
        return _AppStatusInfo('Negada', Colors.red, Icons.cancel_outlined);
      case 'PENDING':
      default:
        return _AppStatusInfo('Em análise', Colors.orange, Icons.hourglass_empty);
    }
  }
}

class _AppStatusInfo {
  final String label;
  final Color color;
  final IconData icon;
  _AppStatusInfo(this.label, this.color, this.icon);
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
