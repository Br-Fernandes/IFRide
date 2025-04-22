import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewRideController extends GetxController {
  var stepIndex = 0.obs;

  var fromCity = RxnString();
  var toCity = RxnString();
  var vehicle = RxnString();
  var isRecurring = false.obs;

  var rawValue = ''.obs;

  void nextStep() {
    stepIndex.value++;
  }

  void previousStep() {
    if (stepIndex > 0) stepIndex.value--;
  }

  String get formattedValue {
    int cents = int.tryParse(rawValue.value) ?? 0;
    double reais = cents / 100;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(reais);
  }

  void addDigit(String digit) {
    if (rawValue.value.length < 6) {
      rawValue.value += digit;
    }
  }

  void clear() {
    rawValue.value = '';
  }

  void backspace() {
    if (rawValue.value.isNotEmpty) {
      rawValue.value = rawValue.value.substring(0, rawValue.value.length - 1);
    }
  }
}
