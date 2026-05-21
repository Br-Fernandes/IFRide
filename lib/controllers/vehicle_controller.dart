import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/vehicle.dart';
import 'package:if_ride/services/vehicle_service.dart';

class VehicleController extends GetxController {
  final _vehicleService = VehicleService();

  final vehicles = <VehicleResponse>[].obs;
  final isLoading = false.obs;

  final model = ''.obs;
  final plate = ''.obs;
  final color = ''.obs;
  final capacity = 4.obs;

  bool get isFormValid =>
      model.value.trim().isNotEmpty &&
      plate.value.trim().length >= 7 &&
      color.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    final userId = Get.find<AuthController>().user?.id ?? '';
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      vehicles.value = await _vehicleService.getVehicles(userId);
    } catch (e) {
      Get.snackbar('Erro', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addVehicle() async {
    final userId = Get.find<AuthController>().user?.id ?? '';
    if (userId.isEmpty || !isFormValid) return;

    isLoading.value = true;
    try {
      final created = await _vehicleService.createVehicle(
        userId,
        VehicleCreationRequest(
          model: model.value.trim(),
          plate: plate.value.trim().toUpperCase(),
          color: color.value.trim(),
          capacity: capacity.value,
        ),
      );
      vehicles.add(created);
      model.value = '';
      plate.value = '';
      color.value = '';
      capacity.value = 4;

      Get.back();
      Get.snackbar('Veículo cadastrado!', '${created.model} adicionado com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erro', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
