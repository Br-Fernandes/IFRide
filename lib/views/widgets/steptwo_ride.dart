import 'package:flutter/material.dart';
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
          NextStepButton()
        ],
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  const RideCard();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      elevation: 8,
      color: Color(0xFFE8E7E7),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      
      child: Container(
        height: size.height * 0.7,
        width: size.width * 0.8,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
        ),
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardHeader(),
              //const SizedBox(height: 20),
              const TimeSelector(),
              //const SizedBox(height: 20),
              const PassengerSelector(),
              //const SizedBox(height: 20),
              const ValueDisplay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1),
        ),
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