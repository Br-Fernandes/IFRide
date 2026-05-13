import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/driver_register_request.dart';
import 'package:if_ride/services/driver_service.dart';
import 'package:image_picker/image_picker.dart';

class RegisterDriverController extends GetxController {
  final _driverService = DriverService();
  final _picker = ImagePicker();

  final isLoading = false.obs;

  final cnh = ''.obs;
  final vehicleModel = ''.obs;
  final vehiclePlate = ''.obs;
  final Rxn<File> profilePhoto = Rxn<File>();

  bool get isValid =>
      cnh.value.trim().isNotEmpty &&
      vehicleModel.value.trim().isNotEmpty &&
      vehiclePlate.value.trim().isNotEmpty &&
      profilePhoto.value != null;

  Future<void> pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) profilePhoto.value = File(picked.path);
  }

  Future<void> submit() async {
    if (profilePhoto.value == null) {
      Get.snackbar(
        'Foto obrigatória',
        'Adicione uma foto de perfil para continuar.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning_rounded, color: Colors.white),
      );
      return;
    }

    if (!isValid) {
      Get.snackbar(
        'Campo obrigatório',
        'Preencha todos os campos antes de continuar.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning_rounded, color: Colors.white),
      );
      return;
    }

    isLoading.value = true;

    try {
      // TODO: enviar profilePhoto.value junto ao registerDriver quando o backend suportar upload
      await _driverService.registerDriver(
        DriverRegisterRequest(
          cnh: cnh.value.trim(),
          vehicleModel: vehicleModel.value.trim(),
          vehiclePlate: vehiclePlate.value.trim().toUpperCase(),
        ),
      );

      Get.find<AuthController>().setIsDriver(true);

      Get.back();

      Get.snackbar(
        'Pronto!',
        'Você agora é um motorista cadastrado.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
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
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
