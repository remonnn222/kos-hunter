// Path: lib/features/owner/repository/owner_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/models/booking_model.dart';
import 'package:kos_app/models/review_model.dart';
import 'package:kos_app/models/user_model.dart';
import 'package:kos_app/services/api/api_client.dart'; // dioProvider

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) {
  return OwnerRepository(ref.watch(dioProvider));
});

class OwnerRepository {
  final Dio _dio;
  OwnerRepository(this._dio);

  // --- A. Manajemen Booking (Owner) ---
  
  // 1. GET Semua Permintaan Booking untuk Kos milik Owner
  Future<List<BookingModel>> getAllOwnerBookings() async {
    try {
      // Asumsi API: /books/owner mengembalikan semua booking terkait kos milik Owner
      final response = await _dio.get('/books/owner');
      final List data = response.data['data'] as List;
      return data.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat daftar pemesanan Owner.');
    }
  }

  // 2. UPDATE Status Booking (Accept/Reject)
  Future<BookingModel> updateBookingStatus({
    required int bookingId,
    required String status, // 'accept' atau 'reject'
  }) async {
    try {
      final response = await _dio.put(
        '/books/$bookingId/status',
        data: {'status': status},
      );
      return BookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui status pemesanan.');
    }
  }

  // --- B. Manajemen Review (Owner) ---

  // 3. GET Review yang masuk ke Kos milik Owner (termasuk yang belum dibalas)
  Future<List<ReviewModel>> getReviewsForOwnerKos() async {
    try {
      // Asumsi API: /reviews/owner mengembalikan semua review untuk Kos milik Owner
      final response = await _dio.get('/reviews/owner');
      final List data = response.data['data'] as List;
      // Note: ReviewModel harus diperluas untuk menyimpan balasan Owner jika fitur ini ada.
      return data.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat ulasan.');
    }
  }
  
  // 4. Balas Ulasan (Asumsi API: /reviews/{reviewId}/reply)
  Future<void> replyToReview(int reviewId, String replyComment) async {
    try {
      await _dio.post(
        '/reviews/$reviewId/reply',
        data: {'reply': replyComment},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal membalas ulasan.');
    }
  }
  
  // --- C. Owner Profile Update ---
  
  // 5. UPDATE Data Profil Owner (name, email, phone)
  Future<UserModel> updateOwnerProfile(Map<String, dynamic> profileData) async {
    try {
      // Asumsi API: /users/profile update profil user yang sedang login
      final response = await _dio.put('/users/profile', data: profileData);
      
      // Catatan: Token dari response ini mungkin tidak selalu ada, 
      // kita perlu model yang lebih fleksibel, tapi untuk saat ini:
      final userData = response.data['user'];
      // Jika API tidak mengembalikan token, kita harus ambil dari local storage
      // Kita asumsikan token dimasukkan kembali untuk konsistensi model
      final currentToken = response.data['token'] ?? 'MOCK_TOKEN'; 
      
      return UserModel.fromJson({...userData, 'token': currentToken});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui profil.');
    }
  }
}