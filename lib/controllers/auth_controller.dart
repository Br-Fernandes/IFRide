import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:if_ride/models/user.dart';
import 'package:if_ride/services/auth_service.dart';
import 'package:if_ride/services/vehicle_service.dart';
import 'package:if_ride/utils/constants.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  final VehicleService _vehicleService = VehicleService();

  final authStatus = AuthStatus.loading.obs;
  final currentUser = Rxn<User>();
  final isCheckingRole = false.obs;

  User? get user => currentUser.value;
  bool get isAuthenticated => authStatus.value == AuthStatus.authenticated;
  bool get isDriver => currentUser.value?.isDriver ?? false;

  @override
  void onInit() {
    super.onInit();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final storedToken = await _storage.read(key: tokenKey);
    if (storedToken == null) {
      authStatus.value = AuthStatus.unauthenticated;
      return;
    }
    // Verifica se o token já expirou localmente antes de usá-lo
    if (_isTokenExpired(storedToken)) {
      await _storage.delete(key: tokenKey);
      await _storage.delete(key: userRoleKey);
      authStatus.value = AuthStatus.unauthenticated;
      return;
    }
    await _fetchCurrentUser(storedToken);
    await refreshRoleFromBackend();
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int?;
      if (exp == null) return false;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
    } catch (_) {
      return true;
    }
  }

  Future<void> _fetchCurrentUser(String token) async {
    try {
      final payload = _decodeJwt(token);
      final String email = payload['sub'] ?? '';

      // Prioriza role salvo localmente (pode ter sido atualizado por refreshRoleFromBackend)
      final storedRole = await _storage.read(key: userRoleKey);
      final String role = storedRole ?? payload['role'] ?? 'PASSENGER';

      final storedId = await _storage.read(key: userIdKey) ?? '';
      final storedName = await _storage.read(key: userNameKey) ?? email;

      currentUser.value = User(
        id: storedId,
        name: storedName,
        email: email,
        role: role,
      );
      authStatus.value = AuthStatus.authenticated;
    } catch (_) {
      await logout();
    }
  }

  // Verifica junto ao backend se o role do usuário foi atualizado.
  // Estratégia: tenta chamar um endpoint exclusivo de DRIVER.
  // O backend Spring Security autoriza com base no role do BANCO, não do JWT,
  // então um PASSENGER aprovado como DRIVER já consegue chamar esses endpoints.
  // Retorna true se a verificação foi executada, false se userId estava vazio (re-login necessário).
  // Funciona nas duas direções: detecta tanto promoção (PASSENGER→DRIVER) quanto rebaixamento (DRIVER→PASSENGER).
  Future<bool> refreshRoleFromBackend() async {
    final u = currentUser.value;
    if (u == null) return false;

    String userId = u.id;
    if (userId.isEmpty) {
      userId = await _storage.read(key: userIdKey) ?? '';
    }
    if (userId.isEmpty) return false; // re-login necessário

    isCheckingRole.value = true;
    try {
      final token = await _storage.read(key: tokenKey);
      final url = Uri.parse('$baseUrl/v1/driver/$userId/vehicles');
      final response = await _vehicleService.rawGet(url, token);

      if (response == 200) {
        await _updateRoleLocally('DRIVER');
      } else if (response == 403) {
        await _updateRoleLocally('PASSENGER');
      }
      // Outros códigos (rede, 500…): não altera role
      return true;
    } catch (_) {
      return true;
    } finally {
      isCheckingRole.value = false;
    }
  }

  Future<void> _updateRoleLocally(String newRole) async {
    await _storage.write(key: userRoleKey, value: newRole);
    final u = currentUser.value;
    if (u != null) {
      currentUser.value = User(
        id: u.id,
        name: u.name,
        email: u.email,
        role: newRole,
        imageUrl: u.imageUrl,
        city: u.city,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      authStatus.value = AuthStatus.loading;
      final response = await _authService.login(email: email, password: password);
      final token = response['token'] as String;

      // Limpa dados do usuário anterior para não vazar nome/id entre sessões
      await _storage.delete(key: userRoleKey);
      await _storage.delete(key: userNameKey);
      await _storage.delete(key: userIdKey);

      await _storage.write(key: tokenKey, value: token);
      if (response['id'] != null) await _storage.write(key: userIdKey, value: response['id'] as String);
      if (response['name'] != null) await _storage.write(key: userNameKey, value: response['name'] as String);
      await _fetchCurrentUser(token);
      await refreshRoleFromBackend();
    } catch (e) {
      authStatus.value = AuthStatus.unauthenticated;
      Get.snackbar(
        'Erro no Login',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    currentUser.value = null;
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: userRoleKey);
    authStatus.value = AuthStatus.unauthenticated;
  }

  Future<void> register(String name, String email, String password, String documentNumber) async {
    try {
      authStatus.value = AuthStatus.loading;
      final response = await _authService.registerPassenger(
        name: name,
        email: email,
        password: password,
        documentNumber: documentNumber,
      );

      await _storage.write(key: userIdKey, value: response['id']?.toString() ?? '');
      await _storage.write(key: userNameKey, value: response['name']?.toString() ?? name);

      Get.snackbar(
        'Conta criada!',
        'Por favor, faça o login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Erro no Cadastro', e.toString().replaceAll('Exception: ', ''));
    } finally {
      authStatus.value = AuthStatus.unauthenticated;
    }
  }

  Future<void> refreshRole(String newRole) => _updateRoleLocally(newRole);

  // Chamado pelos services quando o backend retorna 401 (token expirado/inválido).
  // Desloga silenciosamente e redireciona para o login.
  Future<void> handleExpiredToken() async {
    currentUser.value = null;
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: userRoleKey);
    authStatus.value = AuthStatus.unauthenticated;
    Get.snackbar(
      'Sessão expirada',
      'Sua sessão expirou. Por favor, faça login novamente.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  void updateUserId(String id) {
    final u = currentUser.value;
    if (u != null && u.id.isEmpty) {
      currentUser.value = User(
        id: id,
        name: u.name,
        email: u.email,
        role: u.role,
        imageUrl: u.imageUrl,
        city: u.city,
      );
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Token inválido');
    final normalized = base64Url.normalize(parts[1]);
    return json.decode(utf8.decode(base64Url.decode(normalized)));
  }
}
