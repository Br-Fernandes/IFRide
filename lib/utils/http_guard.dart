import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/controllers/auth_controller.dart';

// Verifica se a resposta indica token expirado/inválido e desloga automaticamente.
// Retorna true se o token está OK, false se foi expirado e o logout foi disparado.
bool guardResponse(http.Response response) {
  if (response.statusCode == 401) {
    _triggerLogout();
    return false;
  }
  return true;
}

void _triggerLogout() {
  if (Get.isRegistered<AuthController>()) {
    Get.find<AuthController>().handleExpiredToken();
  }
}
