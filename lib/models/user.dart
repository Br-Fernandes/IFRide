class User {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.city
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      imageUrl: json['ímageUrl'],
      city: json['city']
    );
  }
}