class RegisterRequest {
  final String email;
  final String password;
  final String name;   // ou nome completo – veja o que o backend espera

  RegisterRequest({required this.email, required this.password, required this.name});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
  };
}