import 'package:flutter/material.dart';

class ValueDisplay extends StatelessWidget {
  const ValueDisplay();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Valor:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),  
        const SizedBox(width: 8),
        InkWell(
          customBorder: const OutlineInputBorder(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text("00,00", style: TextStyle(fontSize: 22)),
          ),
        ),
      ],
    );
  }
}