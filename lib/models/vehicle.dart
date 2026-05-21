class DriverSummary {
  final String id;
  final String name;
  final String cnhCategory;

  DriverSummary({required this.id, required this.name, required this.cnhCategory});

  factory DriverSummary.fromJson(Map<String, dynamic> json) {
    return DriverSummary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cnhCategory: json['cnhCategory'] ?? '',
    );
  }
}

class VehicleResponse {
  final String id;
  final String model;
  final String plate;
  final String color;
  final DriverSummary owner;

  VehicleResponse({
    required this.id,
    required this.model,
    required this.plate,
    required this.color,
    required this.owner,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      id: json['id'] ?? '',
      model: json['model'] ?? '',
      plate: json['plate'] ?? '',
      color: json['color'] ?? '',
      owner: DriverSummary.fromJson(json['owner'] ?? {}),
    );
  }
}

class VehicleCreationRequest {
  final String model;
  final String plate;
  final String color;
  final int capacity;

  VehicleCreationRequest({
    required this.model,
    required this.plate,
    required this.color,
    required this.capacity,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'plate': plate,
        'color': color,
        'capacity': capacity,
      };
}
