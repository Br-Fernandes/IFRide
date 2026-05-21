import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/utils/constants.dart';

class RideService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: tokenKey);
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<RideResponse> createRide(RideRequest request) async {
    final url = Uri.parse('$baseUrl/v1/rides');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return RideResponse.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 409) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Conflito ao criar carona.');
    }
    throw Exception('Erro ao criar carona: ${response.statusCode}');
  }

  Future<List<RideResponse>> searchRides({String? origin, String? destination}) async {
    final queryParams = <String, String>{};
    if (origin != null && origin.isNotEmpty) queryParams['origin'] = origin;
    if (destination != null && destination.isNotEmpty) queryParams['destination'] = destination;
    queryParams['size'] = '20';

    final url = Uri.parse('$baseUrl/v1/rides').replace(queryParameters: queryParams);
    final response = await http.get(url, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);
      final List<dynamic> content = page['content'] ?? [];
      return content.map((e) => RideResponse.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar caronas: ${response.statusCode}');
  }

  Future<void> requestSeat(String rideId, String pickupPoint) async {
    final url = Uri.parse('$baseUrl/v1/rides/$rideId/request-seat');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({'pickupPoint': pickupPoint}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) return;
    if (response.statusCode == 409) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Não foi possível solicitar a vaga.');
    }
    throw Exception('Erro ao solicitar vaga: ${response.statusCode}');
  }

  Future<List<RideParticipantResponse>> getRideParticipants(String rideId) async {
    final url = Uri.parse('$baseUrl/v1/rides/$rideId/participants?size=50');
    final response = await http.get(url, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);
      final List<dynamic> content = page['content'] ?? [];
      return content.map((e) => RideParticipantResponse.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar participantes: ${response.statusCode}');
  }

  Future<void> acceptParticipant(String participantId) async {
    final url = Uri.parse('$baseUrl/v1/ride-participant/$participantId/accept');
    final response = await http.patch(url, headers: await _authHeaders());
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao aceitar passageiro: ${response.statusCode}');
    }
  }

  Future<void> rejectParticipant(String participantId) async {
    final url = Uri.parse('$baseUrl/v1/ride-participant/$participantId/reject');
    final response = await http.patch(url, headers: await _authHeaders());
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao rejeitar passageiro: ${response.statusCode}');
    }
  }

  Future<void> cancelParticipation(String participantId) async {
    final url = Uri.parse('$baseUrl/v1/ride-participant/$participantId/cancel');
    final response = await http.patch(url, headers: await _authHeaders());
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao cancelar participação: ${response.statusCode}');
    }
  }

  Future<void> startRide(String rideId) async {
    final url = Uri.parse('$baseUrl/v1/rides/$rideId/start');
    final response = await http.patch(url, headers: await _authHeaders());
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao iniciar carona: ${response.statusCode}');
    }
  }

  Future<void> finishRide(String rideId) async {
    final url = Uri.parse('$baseUrl/v1/rides/$rideId/finish');
    final response = await http.patch(url, headers: await _authHeaders());
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao finalizar carona: ${response.statusCode}');
    }
  }
}
