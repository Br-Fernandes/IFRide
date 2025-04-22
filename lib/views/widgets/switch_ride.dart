import 'package:flutter/material.dart';

class SwitchRide extends StatelessWidget {
  const SwitchRide({super.key, required this.isSwitched});

  final bool isSwitched;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isSwitched,
      activeColor: Theme.of(context).primaryColor,
      inactiveThumbColor: Colors.black,
      trackColor: WidgetStatePropertyAll(Colors.white),
      onChanged: (value) {},
    );
  }
}