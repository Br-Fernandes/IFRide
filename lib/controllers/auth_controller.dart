import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:if_ride/models/user.dart';
import 'package:if_ride/services/auth_service.dart';
import 'package:if_ride/views/screens/auth_screen.dart';
import 'package:if_ride/views/screens/main_navigation_screen.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  final authStatus = AuthStatus.loading.obs;
  final currentUser = Rxn<User>();

  User? get user => currentUser.value;
  bool get isAuthenticated => authStatus.value == AuthStatus.authenticated;

  @override
  void onInit() {
    super.onInit();
    _tryAutoLogin(); 
  }

  Future<void> _tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'jwt_token');
    if (storedToken == null) {
      authStatus.value = AuthStatus.unauthenticated;
      return;
    }
    await _fetchCurrentUser(storedToken);
  }

  Future<void> _fetchCurrentUser(String token) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); 
      final decodedToken = _decodeJwt(token); 
      currentUser.value = User(id: 'mock-id-123', name: 'Usuário Logado', email: decodedToken['sub']);
      
      authStatus.value = AuthStatus.authenticated;
    } catch (e) {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      authStatus.value = AuthStatus.loading;
      final response = await _authService.login(email: email, password: password);
      final receivedToken = response['token'];

      await _storage.write(key: 'jwt_token', value: receivedToken);
      await _fetchCurrentUser(receivedToken); 
      
      Get.offAll(() => MainNavigationScreen());

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
    await _storage.delete(key: 'jwt_token');
    authStatus.value = AuthStatus.unauthenticated;
    Get.offAll(() => AuthScreen());
  }

  Future<void> register(String name, String email, String password) async {
    try {
      authStatus.value = AuthStatus.loading;
      await _authService.registerPassenger(
        name: name,
        email: email,
        password: password,
      );
      Get.snackbar(
        'Sucesso!',
        'Conta criada. Por favor, faça o login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Erro no Registro', e.toString());
    } finally {
      authStatus.value = AuthStatus.unauthenticated;
    }
  }
  
  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    return json.decode(resp);
  }
}