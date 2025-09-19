class User {
  final String id;
  final String name;
  final String email;
//  final String imageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
   // required this.imageUrl
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
  //    imageUrl: json['ímageUrl']
    );
  }
}