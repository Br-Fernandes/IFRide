import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:if_ride/utils/constants.dart';

class AuthService {
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
    throw Exception('Falha ao registrar: ${response.statusCode}');
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
