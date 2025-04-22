import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';

class NextStepButton extends StatelessWidget {
  NextStepButton({super.key});

  NewRideController controller = Get.find<NewRideController>();
  //NewRideController controller = Get.put(NewRideController());


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.065,
      width: MediaQuery.of(context).size.width * 0.4,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).primaryColor,
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
        onPressed: controller.nextStep,
        child: const Text("Próximo"),
      ),
    );
  }
}
