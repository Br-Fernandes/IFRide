import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';
import 'package:if_ride/views/widgets/city_selector.dart';
import 'package:if_ride/views/widgets/next_step_button.dart';
import 'package:if_ride/views/widgets/vehicle_selector.dart';

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
        VehicleSelector(
          value: controller.vehicle.value,
          onChanged: (v) => controller.vehicle.value = v,
        ),
        SizedBox(height: padding.height * 0.03),
        Row(
          children: [
            Switch(
              value: controller.isRecurring.value,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (v) => controller.isRecurring.value = v,
            ),
            const Text(
              "Carona Recorrente",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        SizedBox(height: padding.height * 0.04),
        Center(child: NextStepButton()),
      ],
    ));
  }
}
