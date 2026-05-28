import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/models/driver_application.dart';
import 'package:if_ride/utils/constants.dart';
import 'package:if_ride/utils/http_guard.dart';

class DriverService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: tokenKey);
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Envia solicitação de upgrade para motorista (CNH + dados da habilitação)
  // O backend valida que requesterId == usuário logado
  Future<DriverApplicationSummary> applyForDriver(DriverApplicationRequest request) async {
    final url = Uri.parse('$baseUrl/v1/driver-requests');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 201 || response.statusCode == 200) {
      return DriverApplicationSummary.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 409) {
      throw Exception('Você já possui uma solicitação ativa ou já é motorista.');
    }
    if (response.statusCode == 403) {
      throw Exception('Você não tem permissão para fazer esta solicitação.');
    }
    throw Exception('Erro ao enviar solicitação: ${response.statusCode}');
  }
}
