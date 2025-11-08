// lib/models/user.dart
class User {
  final int id;
  final String username;
  final String email;
  final String userType;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      userType: json['user_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'user_type': userType,
    };
  }
}
