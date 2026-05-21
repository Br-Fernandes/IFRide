import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:if_ride/controllers/auth_controller.dart';
import 'package:if_ride/models/auth_form_data.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthFormData _formData = AuthFormData();
  String _documentNumber = '';
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();
    setState(() => _isLoading = true);

    final authController = Get.find<AuthController>();

    if (_formData.isLogin) {
      await authController.login(_formData.email, _formData.password);
    } else {
      await authController.register(
        _formData.name,
        _formData.email,
        _formData.password,
        _documentNumber,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.04,
          horizontal: 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formData.isLogin ? 'Entrar' : 'Cadastrar',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: SizedBox(
                height: _formData.isSignup
                    ? MediaQuery.of(context).size.height * 0.52
                    : MediaQuery.of(context).size.height * 0.30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_formData.isSignup) _nameField(context),
                    if (_formData.isSignup) _documentField(context),
                    _emailField(context),
                    _passwordField(context, 'senha'),
                    if (_formData.isSignup) _passwordField(context, 'confirmar senha'),
                    _submitButton(context),
                  ],
                ),
              ),
            ),
            _toggleAuthMode(),
          ],
        ),
      ),
    );
  }

  TextFormField _nameField(BuildContext context) {
    return TextFormField(
      key: const ValueKey('name'),
      onSaved: (v) => _formData.name = v ?? '',
      validator: (v) {
        if (v == null || v.trim().length < 4) return 'Nome deve ter no mínimo 4 caracteres.';
        return null;
      },
      cursorColor: Theme.of(context).primaryColor,
      decoration: _decoration('nome completo', Icons.person),
    );
  }

  TextFormField _documentField(BuildContext context) {
    return TextFormField(
      key: const ValueKey('document'),
      onSaved: (v) => _documentNumber = v ?? '',
      validator: (v) {
        if (v == null || v.trim().length < 11) return 'CPF deve ter 11 dígitos.';
        return null;
      },
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      cursorColor: Theme.of(context).primaryColor,
      decoration: _decoration('CPF (somente números)', Icons.badge_outlined),
    );
  }

  TextFormField _emailField(BuildContext context) {
    return TextFormField(
      key: const ValueKey('email'),
      onSaved: (v) => _formData.email = v ?? '',
      validator: (v) {
        if (v == null || !v.contains('@')) return 'E-mail inválido.';
        return null;
      },
      keyboardType: TextInputType.emailAddress,
      cursorColor: Theme.of(context).primaryColor,
      decoration: _decoration('e-mail', Icons.email),
    );
  }

  Widget _passwordField(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          key: ValueKey(label),
          onSaved: (v) {
            if (label == 'senha') _formData.password = v ?? '';
          },
          validator: (v) {
            if (v == null || v.length < 8) return 'Senha deve ter no mínimo 8 caracteres.';
            return null;
          },
          obscureText: _isObscure,
          cursorColor: Theme.of(context).primaryColor,
          decoration: _decoration(label, Icons.lock_outlined).copyWith(
            suffixIcon: IconButton(
              onPressed: () => setState(() => _isObscure = !_isObscure),
              icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
            ),
          ),
        ),
        if (_formData.isLogin && label == 'senha')
          TextButton(
            onPressed: () {},
            child: Text(
              'Esqueceu a senha?',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _submitButton(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.065,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(_formData.isSignup ? 'Criar Conta' : 'Entrar'),
      ),
    );
  }

  Widget _toggleAuthMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formData.isSignup ? 'Já possui uma conta? ' : 'Ainda não tem uma conta? ',
          style: const TextStyle(fontSize: 14),
        ),
        TextButton(
          onPressed: () => setState(() => _formData.toggleAuthMode()),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Text(
            'Clique aqui',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon, size: 28),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.black),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
