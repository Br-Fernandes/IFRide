import 'package:flutter/material.dart';
import 'package:if_ride/views/widgets/steptwo_ride.dart';

class RecurringRide extends StatefulWidget {
  const RecurringRide({super.key});

  @override
  State<RecurringRide> createState() => _RecurringRideState();
}

class _RecurringRideState extends State<RecurringRide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caronas Recorrentes')),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isExpanded ? 350 : 80, 
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
                RideCard() 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80, 
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.day, 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Icon(_isExpanded
              ? Icons.keyboard_arrow_up_sharp
              : Icons.keyboard_arrow_down_sharp),
        ],
      ),
    );
  }
}