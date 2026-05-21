class User {
  final String id;
  final String name;
  final String email;
  final String role; // PASSENGER, DRIVER, ADMIN
  final String? imageUrl;
  final String? city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.imageUrl,
    this.city,
  });

  bool get isDriver => role == 'DRIVER' || role == 'ADMIN';
  bool get isAdmin => role == 'ADMIN';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'PASSENGER',
      imageUrl: json['imageUrl'],
      city: json['city'],
    );
  }
}
