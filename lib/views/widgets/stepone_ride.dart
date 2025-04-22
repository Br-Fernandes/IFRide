import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';
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
          hint: "Selecione uma cidade",
          value: controller.fromCity.value,
          onChanged: controller.fromCity,
        ),
        CitySelector(
          label: "Para onde você vai?",
          hint: "Selecione uma cidade",
          value: controller.toCity.value,
          onChanged: controller.toCity,
        ),
        CitySelector(
          label: "Veículo",
          hint: "Selecione seu veículo",
          value: controller.vehicle.value,
          onChanged: controller.vehicle,
        ),
        Row(
          children: [
            Switch(
              value: controller.isRecurring.value,
              onChanged: controller.isRecurring,
            ),
            const Text("Carona Recorrente"),
          ],
        ),
        SizedBox(height: padding.height * 0.04),
        Center(child: NextStepButton())
      ],
    ));
  }
}

