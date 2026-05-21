import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/new_ride_controller.dart';
import 'package:if_ride/views/widgets/next_step_button.dart';
import 'package:if_ride/views/widgets/ride_card_widgets/time_selector.dart';
import 'ride_card_widgets/passenger_selector.dart';
import 'ride_card_widgets/value_display.dart';

class SteptwoRide extends StatelessWidget {
  const SteptwoRide({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RideCard(),
          NextStepButton(),
        ],
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  const RideCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      elevation: 8,
      color: const Color(0xFFE8E7E7),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: size.height * 0.75,
        width: size.width * 0.8,
        decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
        child: Container(
          padding: EdgeInsets.only(bottom: size.height * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _CardHeader(),
              _DateSelector(),
              TimeSelector(),
              PassengerSelector(),
              ValueDisplay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1)),
      ),
      child: const Center(
        child: Text(
          "Detalhes",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  _DateSelector();

  final controller = Get.find<NewRideController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            const Text(
              'Data de partida',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => controller.selectDate(context),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.065,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      controller.formattedDepartureDate,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
