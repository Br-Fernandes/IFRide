import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:if_ride/services/auth_service.dart';
import 'package:if_ride/views/screens/auth_screen.dart';
import 'package:if_ride/views/screens/main_navigation_screen.dart';

class AuthController extends GetxController {

  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  final Rxn<String> _token = Rxn<String>();

  bool get isAuthenticated => _token.value != null;
  String? get token => _token.value;

  @override
  void onInit() {
    super.onInit();
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'jwt_token');
    if(storedToken != null) {
      _token.value = storedToken;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _authService.login(email: email, password: password);
      final receivedToken = response['token'];
      print(receivedToken);
      _token.value = receivedToken;
      await _storage.write(key: 'jwt_token', value: receivedToken);
      Get.offAll(MainNavigationScreen());
    } catch (e) {
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
    _token.value = null;
    await _storage.delete(key: 'jwt_token');
    Get.offAll(() => AuthScreen());
  }

  Future<void> register(String name, String email, String password) async {
    _authService.registerPassenger(
      name: name,
      email: email,
      password: password
    );
  }
}