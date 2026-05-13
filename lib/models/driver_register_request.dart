class DriverRegisterRequest {
  final String cnh;
  final String vehicleModel;
  final String vehiclePlate;

  DriverRegisterRequest({
    required this.cnh,
    required this.vehicleModel,
    required this.vehiclePlate,
  });

  Map<String, dynamic> toJson() => {
        'cnh': cnh,
        'vehicleModel': vehicleModel,
        'vehiclePlate': vehiclePlate,
      };
}
