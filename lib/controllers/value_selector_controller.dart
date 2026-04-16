import 'package:get/get.dart';

class ValueController extends GetxController {
  final RxInt _cents = 0.obs;

  int get cents => _cents.value;

  String get formattedValue {
    final reais = _cents.value ~/ 100;
    final centavos = _cents.value % 100;
    return '$reais,${centavos.toString().padLeft(2, '0')}';
  }

  void addDigit(String digit) {
    final next = _cents.value * 10 + int.parse(digit);
    if (next <= 99999) _cents.value = next;
  }

  void backspace() {
    _cents.value = _cents.value ~/ 10;
  }

  void clear() {
    _cents.value = 0;
  }
}
