import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  const TimeSelector();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Selecione o hor\u00e1rio de sua viagem",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.height * 0.07,
          width: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(45),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45),
              side: const BorderSide(width: 3, color: Colors.black),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.watch_later_outlined, size: 45.0),
                SizedBox(width: 8),
                Text("00:00", style: TextStyle(fontSize: 25)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}