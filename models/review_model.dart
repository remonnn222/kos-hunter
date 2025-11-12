// Path: lib/models/review_model.dart
import 'package:kos_app/models/user_model.dart'; // Import UserModel

class ReviewModel {
  final int id;
  final int kosId;
  final int userId; // Society yang memberikan ulasan
  final String comment;
  final String userName; // Nama Society (Asumsi API join tabel user)
  final String userRole; // Role user (hanya untuk tampilan)

  ReviewModel({
    required this.id,
    required this.kosId,
    required this.userId,
    required this.comment,
    required this.userName,
    required this.userRole,
  });

  // Factory constructor untuk mapping dari respons JSON API
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Asumsi API mengembalikan data user (atau nama) di dalam review
    final userJson = json['user'] as Map<String, dynamic>?; 
    
    return ReviewModel(
      id: json['id'] as int,
      kosId: json['kos_id'] as int,
      userId: json['user_id'] as int,
      comment: json['comment'] as String,
      // Jika data user tersedia, ambil nama dan role. Jika tidak, pakai placeholder.
      userName: userJson?['name'] as String? ?? 'Pengguna',
      userRole: userJson?['role'] as String? ?? 'Society',
    );
  }
}