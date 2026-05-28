import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/models/ride.dart';
import 'package:if_ride/utils/constants.dart';
import 'package:if_ride/utils/http_guard.dart';

class RideService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: tokenKey);
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message']?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<RideResponse> createRide(RideRequest request) async {
    final url = Uri.parse('$baseUrl/v1/rides');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 201 || response.statusCode == 200) {
      return RideResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception(_errorMessage(response, 'Erro ao criar carona.'));
  }

  Future<List<RideResponse>> searchRides({String? origin, String? destination}) async {
    final queryParams = <String, String>{};
    if (origin != null && origin.isNotEmpty) queryParams['origin'] = origin;
    if (destination != null && destination.isNotEmpty) queryParams['destination'] = destination;
    queryParams['size'] = '20';

    final url = Uri.parse('$baseUrl/v1/rides').replace(queryParameters: queryParams);
    final response = await http.get(url, headers: await _authHeaders());

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);
      final List<dynamic> content = page['content'] ?? [];
      return content.map((e) => RideResponse.fromJson(e)).toList();
    }
    throw Exception(_errorMessage(response, 'Erro ao buscar caronas.'));
  }

  Future<List<RideResponse>> getMyDriverRides() async {
    final url = Uri.parse('$baseUrl/v1/rides/me').replace(
      queryParameters: {'size': '50', 'sort': 'departureTime,desc'},
    );
    final response = await http.get(url, headers: await _authHeaders());

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);
      final List<dynamic> content = page['content'] ?? [];
      return content.map((e) => RideResponse.fromJson(e)).toList();
    }
    throw Exception(_errorMessage(response, 'Erro ao buscar suas caronas.'));
  }

  Future<List<RideParticipantResponse>> getMyPassengerRides() async {
    final url = Uri.parse('$baseUrl/v1/ride-participant/me').replace(
      queryParameters: {'size': '50', 'sort': 'requestedAt,desc'},
    );
    final response = await http.get(url, headers: await _authHeaders());

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);
      final List<dynamic> content = page['content'] ?? [];
      return content.map((e) => RideParticipantResponse.fromJson(e)).toList();
    }
    throw Exception(_errorMessage(response, 'Erro ao buscar suas participações.'));
  }

  Future<void> requestSeat(String rideId, String pickupPoint) async {
    final url = Uri.parse('$baseUrl/v1/rides/$rideId/request-seat');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({'pickupPoint': pickupPoint}),
    );

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 201 || response.statusCode == 200) return;
    throw Exception(_errorMessage(response, 'Não foi possível solicitar a vaga.'));
  }

  Future<List<RideParticipantResponse>> getRideParticipants(String rideId) async {
    final url = Uri.parse('$baseUrl/v1/rides/$rideId/participants?size=50');
    final response = await http.get(url, headers: await _authHeaders());

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);
      final List<dynamic> content = page['content'] ?? [];
      return content.map((e) => RideParticipantResponse.fromJson(e)).toList();
    }
    throw Exception(_errorMessage(response, 'Erro ao buscar participantes.'));
  }

  Future<void> acceptParticipant(String participantId) async {
    final url = Uri.parse('$baseUrl/v1/ride-participant/$participantId/accept');
    final response = await http.patch(url, headers: await _authHeaders());
    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Erro ao aceitar passageiro.'));
    }
  }

  Future<void> rejectParticipant(String participantId) async {
    final url = Uri.parse('$baseUrl/v1/ride-participant/$participantId/reject');
    final response = await http.patch(url, headers: await _authHeaders());
    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Erro ao rejeitar passageiro.'));
    }
  }

  Future<void> cancelParticipation(String participantId) async {
    final url = Uri.parse('$baseUrl/v1/ride-participant/$participantId/cancel');
    final response = await http.patch(url, headers: await _authHeaders());
    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Erro ao cancelar participação.'));
    }
  }

  Future<void> startRide(String rideId) async {
    final url = Uri.parse('$baseUrl/v1/rides/$rideId/start');
    final response = await http.patch(url, headers: await _authHeaders());
    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Erro ao iniciar carona.'));
    }
  }

  Future<void> finishRide(String rideId) async {
    final url = Uri.parse('$baseUrl/v1/rides/$rideId/finish');
    final response = await http.patch(url, headers: await _authHeaders());
    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Erro ao finalizar carona.'));
    }
  }
}
