import 'package:if_ride/models/vehicle.dart';

class RideResponse {
  final String? id;
  final DriverSummary driver;
  final VehicleResponse vehicle;
  final String origin;
  final String destination;
  final List<String> pickupPoints;
  final int availableSeats;
  final double price;
  final DateTime? departureTime;
  final String? rideStatus;

  RideResponse({
    this.id,
    required this.driver,
    required this.vehicle,
    required this.origin,
    required this.destination,
    required this.pickupPoints,
    required this.availableSeats,
    required this.price,
    this.departureTime,
    this.rideStatus,
  });

  factory RideResponse.fromJson(Map<String, dynamic> json) {
    return RideResponse(
      id: json['id'],
      driver: DriverSummary.fromJson(json['driver'] ?? {}),
      vehicle: VehicleResponse.fromJson(json['vehicle'] ?? {}),
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      pickupPoints: List<String>.from(json['pickupPoints'] ?? []),
      availableSeats: json['availableSeats'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      departureTime: json['departureTime'] != null
          ? DateTime.parse(json['departureTime'] as String)
          : null,
      rideStatus: json['rideStatus'] as String?,
    );
  }
}

class RideRequest {
  final String vehicleId;
  final String origin;
  final String destination;
  final List<String> pickupPoints;
  final String departureTime; // formato: "2026-02-20T14:30:00"
  final int availableSeats;
  final double price;
  final bool isRecurrent;
  final String? recurrentDay; // ex: "MONDAY"
  final String? recurrencyDeparture; // ex: "08:00:00"

  RideRequest({
    required this.vehicleId,
    required this.origin,
    required this.destination,
    required this.pickupPoints,
    required this.departureTime,
    required this.availableSeats,
    required this.price,
    this.isRecurrent = false,
    this.recurrentDay,
    this.recurrencyDeparture,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'vehicleId': vehicleId,
      'origin': origin,
      'destination': destination,
      'pickupPoints': pickupPoints,
      'departureTime': departureTime,
      'availableSeats': availableSeats,
      'price': price,
      'isRecurrent': isRecurrent,
    };
    if (isRecurrent) {
      map['recurrentDay'] = recurrentDay;
      map['recurrencyDeparture'] = recurrencyDeparture;
    }
    return map;
  }
}

class RideParticipantResponse {
  // NOTA: o backend não retorna 'id' do participante em RideParticipantResponseDTO.
  // Para aceitar/rejeitar/cancelar, o backend precisa incluir o 'id' do participante.
  final String? id;
  final RideResponse ride;
  final String passengerName;
  final String passengerId;
  final String status; // PENDING, ACCEPTED, REJECTED, CANCELLED
  final String requestedAt;

  RideParticipantResponse({
    this.id,
    required this.ride,
    required this.passengerName,
    required this.passengerId,
    required this.status,
    required this.requestedAt,
  });

  factory RideParticipantResponse.fromJson(Map<String, dynamic> json) {
    final passenger = json['passenger'] as Map<String, dynamic>? ?? {};
    return RideParticipantResponse(
      id: json['id'],
      ride: RideResponse.fromJson(json['ride'] ?? {}),
      passengerName: passenger['name'] ?? '',
      passengerId: passenger['id'] ?? '',
      status: json['status'] ?? 'PENDING',
      requestedAt: json['requestedAt'] ?? '',
    );
  }
}
