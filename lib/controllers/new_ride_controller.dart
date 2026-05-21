import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/passenger_selector_controller.dart';
import 'package:if_ride/controllers/time_selector_controller.dart';
import 'package:if_ride/controllers/value_selector_controller.dart';
import 'package:if_ride/controllers/vehicle_controller.dart';
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/models/vehicle.dart';
import 'package:if_ride/services/ride_service.dart';
import 'package:intl/intl.dart';

class DayRideConfig {
  final String dayName;
  final String apiDayName; // ex: MONDAY
  final RxBool enabled = false.obs;
  final Rx<TimeOfDay> time = const TimeOfDay(hour: 7, minute: 0).obs;
  final RxInt passengerCount = 1.obs;
  final RxInt priceCents = 0.obs;

  DayRideConfig({required this.dayName, required this.apiDayName});

  bool get canIncrement => passengerCount.value < 6;
  bool get canDecrement => passengerCount.value > 1;

  void increment() { if (canIncrement) passengerCount.value++; }
  void decrement() { if (canDecrement) passengerCount.value--; }

  String get formattedTime =>
      '${time.value.hour.toString().padLeft(2, '0')}:${time.value.minute.toString().padLeft(2, '0')}';

  String get apiTime => '$formattedTime:00';

  String get formattedPrice {
    double reais = priceCents.value / 100;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(reais);
  }
}

class NewRideController extends GetxController {
  final _rideService = RideService();

  var stepIndex = 0.obs;

  var fromCity = RxnString();
  var toCity = RxnString();
  var isRecurring = false.obs;

  final Rxn<VehicleResponse> selectedVehicle = Rxn<VehicleResponse>();

  // Data de partida para carona não recorrente (horário vem do TimeSelectorController)
  final Rxn<DateTime> departureDate = Rxn<DateTime>();

  // Pontos de parada intermediários (opcional)
  final pickupPoints = <String>[].obs;

  var isSubmitting = false.obs;

  final List<DayRideConfig> weekDays = [
    DayRideConfig(dayName: 'Segunda', apiDayName: 'MONDAY'),
    DayRideConfig(dayName: 'Terça', apiDayName: 'TUESDAY'),
    DayRideConfig(dayName: 'Quarta', apiDayName: 'WEDNESDAY'),
    DayRideConfig(dayName: 'Quinta', apiDayName: 'THURSDAY'),
    DayRideConfig(dayName: 'Sexta', apiDayName: 'FRIDAY'),
  ];

  String get formattedDepartureDate {
    final d = departureDate.value;
    if (d == null) return 'Selecionar data';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) departureDate.value = picked;
  }

  void addPickupPoint(String point) {
    if (point.trim().isNotEmpty) pickupPoints.add(point.trim());
  }

  void removePickupPoint(int index) => pickupPoints.removeAt(index);

  void nextStep() {
    final error = _validate();
    if (error != null) {
      Get.snackbar('Campo obrigatório', error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.warning_rounded, color: Colors.white));
      return;
    }

    if (stepIndex.value == 0) {
      stepIndex.value = isRecurring.value ? 2 : 1;
    } else {
      submitRide();
    }
  }

  void previousStep() {
    if (stepIndex.value == 1 || stepIndex.value == 2) stepIndex.value = 0;
  }

  String? _validate() {
    switch (stepIndex.value) {
      case 0:
        if (fromCity.value == null) return 'Selecione a cidade de origem.';
        if (toCity.value == null) return 'Selecione a cidade de destino.';
        if (fromCity.value == toCity.value) return 'Origem e destino não podem ser iguais.';
        if (selectedVehicle.value == null) return 'Selecione um veículo.';
        return null;
      case 1:
        if (departureDate.value == null) return 'Selecione a data de partida.';
        final price = Get.isRegistered<ValueController>()
            ? Get.find<ValueController>().cents
            : 0;
        if (price == 0) return 'Informe o valor da carona.';
        return null;
      case 2:
        if (!weekDays.any((d) => d.enabled.value)) return 'Selecione ao menos um dia da semana.';
        return null;
      default:
        return null;
    }
  }

  Future<void> submitRide() async {
    isSubmitting.value = true;
    try {
      if (isRecurring.value) {
        await _submitRecurringRides();
      } else {
        await _submitSingleRide();
      }
      _resetForm();
      stepIndex.value = 0;
      Get.snackbar('Carona criada!', 'Sua carona foi cadastrada com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white));
    } catch (e) {
      Get.snackbar('Erro ao criar carona', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _submitSingleRide() async {
    final date = departureDate.value!;
    final time = Get.find<TimeSelectorController>().selectedTime.value;
    final seats = Get.isRegistered<PassengerSelectorController>()
        ? Get.find<PassengerSelectorController>().passengerCount.value
        : 1;
    final price = Get.isRegistered<ValueController>()
        ? Get.find<ValueController>().cents / 100
        : 0.0;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final departureStr = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt);

    await _rideService.createRide(RideRequest(
      vehicleId: selectedVehicle.value!.id,
      origin: fromCity.value!,
      destination: toCity.value!,
      pickupPoints: List.from(pickupPoints),
      departureTime: departureStr,
      availableSeats: seats,
      price: price,
    ));
  }

  Future<void> _submitRecurringRides() async {
    final enabledDays = weekDays.where((d) => d.enabled.value).toList();
    for (final day in enabledDays) {
      await _rideService.createRide(RideRequest(
        vehicleId: selectedVehicle.value!.id,
        origin: fromCity.value!,
        destination: toCity.value!,
        pickupPoints: List.from(pickupPoints),
        departureTime: DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        availableSeats: day.passengerCount.value,
        price: day.priceCents.value / 100,
        isRecurrent: true,
        recurrentDay: day.apiDayName,
        recurrencyDeparture: day.apiTime,
      ));
    }
  }

  void _resetForm() {
    fromCity.value = null;
    toCity.value = null;
    isRecurring.value = false;
    selectedVehicle.value = null;
    departureDate.value = null;
    pickupPoints.clear();
    for (final d in weekDays) {
      d.enabled.value = false;
    }
    if (Get.isRegistered<ValueController>()) Get.find<ValueController>().clear();
  }

  List<VehicleResponse> get driverVehicles {
    if (Get.isRegistered<VehicleController>()) {
      return Get.find<VehicleController>().vehicles;
    }
    return [];
  }
}
