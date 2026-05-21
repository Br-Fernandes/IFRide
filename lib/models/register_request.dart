class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String documentNumber; // CPF

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.documentNumber,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        'documentNumber': documentNumber,
      };
}
