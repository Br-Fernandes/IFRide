import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/models/driver_register_request.dart';

class DriverService {
  final String _baseURL = 'http://localhost:8080';
  final _storage = const FlutterSecureStorage();

  Future<void> registerDriver(DriverRegisterRequest request) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$_baseURL/v1/driver/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Motorista cadastrado com sucesso!');
      } else {
        print('Falha ao cadastrar motorista: ${response.body}');
        throw Exception('Falha ao cadastrar motorista: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro de conexão: $e');
      throw Exception('Não foi possível se conectar ao servidor.');
    }
  }

  Future<bool> checkIsDriver() async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$_baseURL/v1/driver/me');

    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
