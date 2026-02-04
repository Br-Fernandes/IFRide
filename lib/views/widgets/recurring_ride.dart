import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/views/widgets/steptwo_ride.dart';

import 'ride_card_widgets/passenger_selector.dart';
import 'ride_card_widgets/time_selector.dart';
import 'ride_card_widgets/value_display.dart';

class RecurringRide extends StatefulWidget {
  const RecurringRide({super.key});

  @override
  State<RecurringRide> createState() => _RecurringRideState();
}

class _RecurringRideState extends State<RecurringRide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Caronas Recorrentes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.close(1),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExpandableRideCard(day: "Segunda-Feira"),
            ExpandableRideCard(day: "Terça-Feira"),
            ExpandableRideCard(day: "Quarta-Feira"),
            ExpandableRideCard(day: "Quinta-Feira"),
            ExpandableRideCard(day: "Sexta-Feira"),
          ],
        ),
      ),
    );
  }
}

class ExpandableRideCard extends StatefulWidget {
  final String day;

  const ExpandableRideCard({super.key, required this.day});

  @override
  State<ExpandableRideCard> createState() => _ExpandableRideCardState();
}

class _ExpandableRideCardState extends State<ExpandableRideCard> {
  bool _isExpanded = false;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        height: _isExpanded ? MediaQuery.of(context).size.height * 0.7 : MediaQuery.of(context).size.height * 0.1, 
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E7E7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: SingleChildScrollView( 
          physics: const NeverScrollableScrollPhysics(), 
          child: Column(
            children: [
              _buildHeader(),
              if (_isExpanded)
                wideCard(context) 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1, 
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [ 
              Text(
                widget.day, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Checkbox(
                checkColor:Color(0xFFEF1A1A),
                activeColor: Theme.of(context).primaryColor,
                value: _isChecked,
                 onChanged: (bool? checked) {
                  setState(() {
                    _isChecked = checked!;
                  });
                 } 
              )
            ]  
          ),
          Icon(_isExpanded
              ? Icons.keyboard_arrow_up_sharp
              : Icons.keyboard_arrow_down_sharp),
        ],
      ),
    );
  }

  Widget wideCard(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.6,
      //width: size.width * 0.8,
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.black12),
      // ),
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TimeSelector(),
            PassengerSelector(),
            ValueDisplay(),
          ],
        ),
      ),
    );
  }
}