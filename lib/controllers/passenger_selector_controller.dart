import 'package:get/get.dart';

class PassengerSelectorController extends GetxController {
  var passengerCount = 1.obs; 

  void increment() {
    if (passengerCount.value < 6) {
      passengerCount.value++;
    }
  }

  void decrement() {
    if (passengerCount.value > 1) {
      passengerCount.value--;
    }
  }

  bool get canIncrement => passengerCount.value < 6;
  bool get canDecrement => passengerCount.value > 1;
}