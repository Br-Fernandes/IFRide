import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';
import 'package:if_ride/controllers/vehicle_controller.dart';
import 'package:if_ride/models/vehicle.dart';
import 'package:if_ride/views/screens/vehicle_screen.dart';
import 'package:if_ride/views/widgets/city_selector.dart';
import 'package:if_ride/views/widgets/next_step_button.dart';

class StepOneRide extends StatelessWidget {
  StepOneRide({super.key});

  final controller = Get.find<NewRideController>();

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size;

    return Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CitySelector(
              label: "De onde você vai sair?",
              hint: "Selecione a cidade",
              value: controller.fromCity.value,
              onChanged: (v) => controller.fromCity.value = v,
            ),
            CitySelector(
              label: "Para onde você vai?",
              hint: "Selecione a cidade",
              value: controller.toCity.value,
              onChanged: (v) => controller.toCity.value = v,
            ),
            SizedBox(height: padding.height * 0.02),
            _buildVehicleSelector(context),
            SizedBox(height: padding.height * 0.02),
            Row(
              children: [
                Switch(
                  value: controller.isRecurring.value,
                  activeThumbColor: Theme.of(context).primaryColor,
                  onChanged: (v) => controller.isRecurring.value = v,
                ),
                const Text("Carona Recorrente", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: padding.height * 0.03),
            Center(child: NextStepButton()),
          ],
        ));
  }

  Widget _buildVehicleSelector(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => _showVehicleSheet(context, primaryColor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: controller.selectedVehicle.value == null
                ? Colors.black26
                : primaryColor,
          ),
          borderRadius: BorderRadius.circular(14),
          color: controller.selectedVehicle.value != null
              ? primaryColor.withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.directions_car_outlined,
                color: controller.selectedVehicle.value != null
                    ? primaryColor
                    : Colors.black54,
                size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.selectedVehicle.value != null
                    ? '${controller.selectedVehicle.value!.model} • ${controller.selectedVehicle.value!.plate}'
                    : 'Selecione o veículo',
                style: TextStyle(
                  fontSize: 14,
                  color: controller.selectedVehicle.value != null
                      ? Colors.black87
                      : Colors.black45,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showVehicleSheet(BuildContext context, Color primaryColor) {
    if (!Get.isRegistered<VehicleController>()) {
      Get.put(VehicleController());
    }
    final vehicleCtrl = Get.find<VehicleController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Selecione o veículo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              if (vehicleCtrl.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                );
              }
              if (vehicleCtrl.vehicles.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text('Nenhum veículo cadastrado.',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Get.to(() => VehicleScreen());
                        },
                        child: const Text('Cadastrar veículo'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: vehicleCtrl.vehicles.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final v = vehicleCtrl.vehicles[i];
                  return _VehicleOption(
                    vehicle: v,
                    isSelected: controller.selectedVehicle.value?.id == v.id,
                    primaryColor: primaryColor,
                    onTap: () {
                      controller.selectedVehicle.value = v;
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VehicleOption extends StatelessWidget {
  const _VehicleOption({
    required this.vehicle,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  final VehicleResponse vehicle;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.directions_car,
          color: isSelected ? primaryColor : Colors.grey),
      title: Text(vehicle.model,
          style: TextStyle(
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text('${vehicle.plate} • ${vehicle.color}'),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: primaryColor)
          : null,
      onTap: onTap,
    );
  }
}
