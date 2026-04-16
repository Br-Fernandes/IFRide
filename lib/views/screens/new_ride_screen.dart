import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';
import 'package:if_ride/views/widgets/stepone_ride.dart';
import 'package:if_ride/views/widgets/stepthree_ride.dart';
import 'package:if_ride/views/widgets/steptwo_ride.dart';

class NewRideScreen extends StatelessWidget {
  NewRideScreen({super.key});

  final controller = Get.put(NewRideController());

  // Instâncias fixas fora do Obx — evita recriar widgets a cada mudança de index
  late final _stepOne = StepOneRide();
  late final _stepTwo = SteptwoRide();
  late final _stepThree = StepThreeRide();

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding.width * 0.05,
          vertical: padding.height * 0.05,
        ),
        child: Obx(() => IndexedStack(
          index: controller.stepIndex.value,
          children: [_stepOne, _stepTwo, _stepThree],
        )),
      ),
    );
  }
}
