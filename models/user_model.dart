// Path: lib/models/user_model.dart

// Enum untuk role pengguna, sangat penting untuk navigasi
enum UserRole {
  owner,
  society,
  unknown;

  // Helper untuk konversi dari string API
  static UserRole fromString(String role) {
    if (role.toLowerCase() == 'owner') return owner;
    if (role.toLowerCase() == 'society') return society;
    return unknown;
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String token; // Tambahkan token untuk di-cache setelah login

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
  });

  // Factory constructor untuk mapping dari respons JSON API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.fromString(json['role'] as String),
      token: json['token'] as String, // Asumsi API mengembalikan token
    );
  }

  // Method toMap untuk penyimpanan lokal (shared_preferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'token': token,
    };
  }
}