import 'package:flutter/material.dart';
import 'package:if_ride/models/auth_form_data.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthFormData _formData = AuthFormData();

  bool _isObscure = true;

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
              _formData.isLogin ? "Entrar" : "Cadastrar",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: SizedBox(
                height:
                    _formData.isSignup
                        ? MediaQuery.of(context).size.height * 0.4
                        : MediaQuery.of(context).size.height * 0.29,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_formData.isSignup) nameTextFormField(context),

                    emailTextFormField(context),
                    passwordTextFormField(context, "senha"),

                    if (_formData.isSignup)
                      passwordTextFormField(context, "confirmar senha"),

                    loginOrSignUpButton(context),
                  ],
                ),
              ),
            ),
            changeAuthMode(),
          ],
        ),
      ),
    );
  }

  TextFormField nameTextFormField(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        label: Text("nome completo"),
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        prefixIcon: Icon(Icons.person, size: 35),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  TextFormField emailTextFormField(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        label: Text("email"),
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        prefixIcon: Icon(Icons.email, size: 35),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget passwordTextFormField(BuildContext context, String passwordLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          obscureText: _isObscure,
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            label: Text(passwordLabel),
            labelStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isObscure ? _isObscure = false : _isObscure = true;
                });
              },
              icon:
                  _isObscure
                      ? Icon(Icons.visibility)
                      : Icon(Icons.visibility_off),
            ),
            prefixIcon: Icon(Icons.lock_outlined, size: 35),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        if (_formData.isLogin && passwordLabel == "senha")
          TextButton(
            onPressed: () {},
            child: Text(
              "Esqueceu a senha?",
              style: TextStyle(color: Theme.of(context).primaryColor),
            )
          ),
      ],
    );
  }

  Widget loginOrSignUpButton(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.065,
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).primaryColor,
          ),
          foregroundColor: WidgetStatePropertyAll(Colors.white),
        ),
        onPressed: () {},
        child: Text(_formData.isSignup ? "Criar Conta" : "Entrar"),
      ),
    );
  }

  Widget changeAuthMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formData.isSignup
              ? "Já possui uma conta? "
              : "Ainda não tem uma conta? ",
          style: TextStyle(fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _formData.toggleAuthMode();
            });
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            "Clique aqui",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
