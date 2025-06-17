import 'package:damd_trabalho_1/models/enum/UserType.dart';

class User {
  final int? id;
  final UserType type;
  final String name;
  final String email;
  final String? password;
  final String? token;
  
  User({
    this.id,
    required this.type,
    required this.name,
    required this.email,
    this.password,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      type: _getUserTypeFromString(json['type']),
      name: json['name'],
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last, // Convert enum to string
      'name': name,
      'email': email,
      'password': password ?? '',
      'token': token,
    };
  }
  
  // Helper method to convert string to UserType
  static UserType _getUserTypeFromString(dynamic typeValue) {
    if (typeValue is int) {
      return UserType.values[typeValue];
    }
    
    if (typeValue is String) {
      switch (typeValue) {
        case 'driver':
          return UserType.driver;
        case 'customer':
        default:
          return UserType.customer;
      }
    }
    
    return UserType.customer; // Default
  }
}
