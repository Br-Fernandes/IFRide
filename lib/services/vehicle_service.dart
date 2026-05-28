import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/models/vehicle.dart';
import 'package:if_ride/utils/constants.dart';
import 'package:if_ride/utils/http_guard.dart';

class VehicleService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: tokenKey);
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<VehicleResponse> createVehicle(String driverId, VehicleCreationRequest request) async {
    final url = Uri.parse('$baseUrl/v1/driver/$driverId/vehicles');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 201 || response.statusCode == 200) {
      return VehicleResponse.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 409) {
      throw Exception('Já existe um veículo com essa placa cadastrado.');
    }
    throw Exception('Erro ao cadastrar veículo: ${response.statusCode}');
  }

  Future<List<VehicleResponse>> getVehicles(String driverId) async {
    final url = Uri.parse('$baseUrl/v1/driver/$driverId/vehicles');
    final response = await http.get(url, headers: await _authHeaders());

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => VehicleResponse.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar veículos: ${response.statusCode}');
  }

  // Retorna apenas o status code — usado para verificar role sem lançar exceção.
  // Não usa guardResponse pois 401 é esperado quando ainda é PASSENGER.
  Future<int> rawGet(Uri url, String? token) async {
    final response = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return response.statusCode;
  }
}
