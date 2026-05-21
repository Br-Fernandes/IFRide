import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/driver_application.dart';
import 'package:if_ride/services/driver_service.dart';
import 'package:if_ride/utils/constants.dart';

class RegisterDriverController extends GetxController {
  final _driverService = DriverService();
  final _storage = const FlutterSecureStorage();

  final isLoading = false.obs;

  final cnhNumber = ''.obs;
  final cnhCategory = 'B'.obs;
  final cnhExpiration = Rxn<DateTime>();

  final cnhCategories = ['A', 'B', 'C', 'D', 'E', 'AB', 'AC', 'AD', 'AE'];

  bool get isValid =>
      cnhNumber.value.trim().length == 11 && cnhExpiration.value != null;

  String get formattedExpiration {
    final d = cnhExpiration.value;
    if (d == null) return 'Selecionar data';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> selectExpiration(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2060),
      helpText: 'Validade da CNH',
    );
    if (picked != null) cnhExpiration.value = picked;
  }

  Future<void> submit() async {
    final authController = Get.find<AuthController>();
    String userId = authController.user?.id ?? '';

    // Se userId está vazio, tenta recuperar do storage
    if (userId.isEmpty) {
      userId = await _storage.read(key: userIdKey) ?? '';
    }

    if (userId.isEmpty) {
      // userId nunca foi salvo — ocorreu em versões antigas do app
      // O logout forçará um novo login que retornará o JWT com role atualizado
      _showReloginDialog(
        'Dados de sessão incompletos',
        'Saia e entre novamente para sincronizar seus dados e enviar a solicitação.',
      );
      return;
    }

    if (!isValid) {
      Get.snackbar(
        'Campo obrigatório',
        'Preencha o número da CNH (11 dígitos) e a data de validade.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;
    try {
      final d = cnhExpiration.value!;
      final expiration =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final result = await _driverService.applyForDriver(
        DriverApplicationRequest(
          requesterId: userId,
          cnhNumber: cnhNumber.value.trim(),
          cnhCategory: cnhCategory.value,
          expiration: expiration,
        ),
      );

      // Garante que o userId fica salvo (útil se veio de sessão antiga)
      if (result.requesterId.isNotEmpty) {
        await _storage.write(key: userIdKey, value: result.requesterId);
        authController.updateUserId(result.requesterId);
      }

      Get.back();
      Get.snackbar(
        'Solicitação enviada!',
        'Aguarde a aprovação do administrador.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showReloginDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
            child: const Text('Sair agora'),
          ),
        ],
      ),
    );
  }
}
