class RegisterResponse {
  final String id;
  final String email;
  final String name;

  RegisterResponse({required this.id, required this.email, required this.name});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'].toString(),
      email: json['email'],
      name: json['name'],
    );
  }
}
