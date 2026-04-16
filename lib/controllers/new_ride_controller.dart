import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/value_selector_controller.dart';
import 'package:intl/intl.dart';

class DayRideConfig {
  final String dayName;
  final RxBool enabled = false.obs;
  final Rx<TimeOfDay> time = TimeOfDay(hour: 0, minute: 0).obs;
  final RxInt passengerCount = 1.obs;
  final RxString price = '00,00'.obs;

  DayRideConfig({required this.dayName});

  bool get canIncrement => passengerCount.value < 6;
  bool get canDecrement => passengerCount.value > 1;

  void increment() {
    if (canIncrement) passengerCount.value++;
  }

  void decrement() {
    if (canDecrement) passengerCount.value--;
  }

  String get formattedTime =>
      '${time.value.hour.toString().padLeft(2, '0')}:${time.value.minute.toString().padLeft(2, '0')}';

  void updatePrice(String newValue) {
    String numbers = newValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length > 4) numbers = numbers.substring(numbers.length - 4);
    numbers = numbers.padLeft(4, '0');
    price.value = '${numbers.substring(0, 2)},${numbers.substring(2)}';
  }
}

class NewRideController extends GetxController {
  var stepIndex = 0.obs;

  var fromCity = RxnString();
  var toCity = RxnString();
  var vehicle = RxnString();
  var isRecurring = false.obs;

  var rawValue = ''.obs;

  final List<DayRideConfig> weekDays = [
    DayRideConfig(dayName: 'Segunda'),
    DayRideConfig(dayName: 'Terça'),
    DayRideConfig(dayName: 'Quarta'),
    DayRideConfig(dayName: 'Quinta'),
    DayRideConfig(dayName: 'Sexta'),
    //DayRideConfig(dayName: 'Sábado'),
  ];

  void nextStep() {
    final error = _validate();
    if (error != null) {
      Get.snackbar(
        'Campo obrigatório',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning_rounded, color: Colors.white),
      );
      return;
    }

    if (stepIndex.value == 0) {
      stepIndex.value = isRecurring.value ? 2 : 1;
    } else {
      submitRide();
    }
  }

  void previousStep() {
    if (stepIndex.value == 1 || stepIndex.value == 2) {
      stepIndex.value = 0;
    }
  }

  String? _validate() {
    switch (stepIndex.value) {
      case 0:
        if (fromCity.value == null) return 'Selecione a cidade de origem.';
        if (toCity.value == null) return 'Selecione a cidade de destino.';
        if (fromCity.value == toCity.value) return 'Origem e destino não podem ser iguais.';
        if (vehicle.value == null) return 'Selecione um veículo.';
        return null;

      case 1:
        if (!Get.isRegistered<ValueController>()) return 'Informe o valor da carona.';
        if (Get.find<ValueController>().cents == 0) return 'Informe o valor da carona.';
        return null;

      case 2:
        final hasDay = weekDays.any((d) => d.enabled.value);
        if (!hasDay) return 'Selecione ao menos um dia da semana.';
        return null;

      default:
        return null;
    }
  }

  Future<void> submitRide() async {
    // TODO: chamar RideService com os dados abaixo
    // fromCity, toCity, vehicle, isRecurring
    // Não recorrente: TimeSelectorController, PassengerSelectorController, ValueController
    // Recorrente: weekDays.where((d) => d.enabled.value)
    Get.snackbar(
      'Carona criada!',
      'Sua carona foi cadastrada com sucesso.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
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
