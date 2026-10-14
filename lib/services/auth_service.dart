import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/utils/constants.dart';
import 'package:if_ride/utils/http_guard.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: tokenKey);
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> deleteAccount() async {
    final url = Uri.parse('$baseUrl/v1/users/me');
    final response = await http.delete(url, headers: await _authHeaders());

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 204 || response.statusCode == 200) return;
    throw Exception('Erro ao excluir conta: ${response.statusCode}');
  }
  Future<Map<String, dynamic>> registerPassenger({
    required String name,
    required String email,
    required String password,
    required String documentNumber,
  }) async {
    final url = Uri.parse('$baseUrl/v1/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'documentNumber': documentNumber,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 409) {
      throw Exception('Este e-mail já está cadastrado.');
    }
    if (response.statusCode == 400) {
      final body = _parseErrorMessage(response.body);
      throw Exception(body ?? 'Dados inválidos. Verifique os campos e tente novamente.');
    }
    throw Exception('Falha ao registrar: ${response.statusCode}');
  }

  String? _parseErrorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile({required String name, String? city}) async {
    final url = Uri.parse('$baseUrl/v1/users/me');
    final body = <String, dynamic>{'name': name};
    if (city != null && city.isNotEmpty) body['city'] = city;

    final response = await http.patch(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );

    if (!guardResponse(response)) throw Exception('Sessão expirada.');
    if (response.statusCode == 200 || response.statusCode == 204) return;
    if (response.statusCode == 400) {
      final msg = _parseErrorMessage(response.body);
      throw Exception(msg ?? 'Dados inválidos.');
    }
    throw Exception('Erro ao atualizar perfil: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/v1/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('E-mail ou senha inválidos.');
  }
}
