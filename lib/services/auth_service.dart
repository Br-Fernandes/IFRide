import 'dart:convert'; 
import 'package:http/http.dart' as http;

class AuthService {

  final String _baseURL = 'http://10.0.2.2:8080';

  Future<Map<String, dynamic>> registerPassenger({
    required String name,
    required String email,
    required String password
  }) async {
    final url = Uri.parse('$_baseURL/v1/users/register/passenger');

    final Map<String, String> body = {
      'name': name,
      'email': email,
      'password': password
    };

    try{
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(body)
      );

      if(response.statusCode == 200 || response.statusCode == 201) {
        print("Registro de passageiro bem sucedido!");
        return jsonDecode(response.body);
      } else {
        print("Falha no registro ${response.body}");
        throw Exception("Falha ao registrar passageiro ${response.statusCode}");
      }
    } catch (e) {
      print("Erro de conexao: $e");
      throw Exception('Nao foi possivel se conectar ao servidor');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password
  }) async {
    final url = Uri.parse('$_baseURL/v1/auth/login');

    final Map<String, String> body = {
      "email": email,
      "password": password
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body)
      );

      if (response.statusCode == 200) {
        print('Login bem-sucedido!');
        return jsonDecode(response.body); 
      } else {
        print('Falha no login: ${response.body}');
        throw Exception('Email ou senha inválidos.');
      }
    } catch (e) {
      print('Erro de conexão: $e');
      throw Exception('Não foi possível se conectar ao servidor.');
    }
  }
}