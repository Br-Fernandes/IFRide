import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimeSelectorController extends GetxController {
  Rx<TimeOfDay> selectedTime = TimeOfDay(hour: 0, minute: 0).obs;

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedTime.value,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme:  ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime.value) {
      update();
      selectedTime.value = picked;
    }
  }

  String get formattedTime {
    return "${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}";
  }
}