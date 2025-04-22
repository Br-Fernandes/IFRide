import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';
import 'package:if_ride/utils/cities.dart';
import 'package:if_ride/views/widgets/stepone_ride.dart';
import 'package:if_ride/views/widgets/steptwo_ride.dart';
import 'package:if_ride/views/widgets/switch_ride.dart';

class NewRideScreen extends StatelessWidget {
  NewRideScreen({super.key});

  final controller = Get.put(NewRideController());

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
        child: Obx(() {
          final index = controller.stepIndex.value;

          return IndexedStack(
            index: index,
            children: [
              StepOneRide(),
              SteptwoRide()
            ],
          );
        })
      ),
    );
  }
}
