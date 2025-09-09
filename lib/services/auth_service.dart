import 'dart:convert'; 
import 'package:http/http.dart' as http;

class AuthService {

  final String _baseURL = 'http://10.0.2.2:8080/v1/users';

  Future<Map<String, dynamic>> registerPassenger({
    required String name,
    required String email,
    required String password
  }) async {
    final url = Uri.parse('$_baseURL/register/passenger');

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
}