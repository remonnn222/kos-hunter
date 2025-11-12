// Path: lib/features/society/repository/booking_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/models/booking_model.dart';
import 'package:kos_app/services/api/api_client.dart'; // dioProvider

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(dioProvider));
});

class BookingRepository {
  final Dio _dio;
  BookingRepository(this._dio);

  final String _endpoint = '/books'; // Endpoint: /api/v1/books

  // --- 1. Pemesanan Kamar (Society) ---
  Future<BookingModel> createBooking({
    required int kosId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.post(
        _endpoint,
        data: {
          'kos_id': kosId,
          // API biasanya butuh format string YYYY-MM-DD
          'start_date': startDate.toIso8601String().substring(0, 10), 
          'end_date': endDate.toIso8601String().substring(0, 10),
        },
      );
      return BookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal melakukan pemesanan.');
    }
  }

  // --- 2. Riwayat Pemesanan (Society) ---
  Future<List<BookingModel>> getMyBookings() async {
    try {
      // Asumsi: Endpoint ini memfilter berdasarkan user yang sedang login (dari token)
      final response = await _dio.get('$_endpoint/my-bookings'); 
      final List data = response.data['data'] as List;
      return data.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat riwayat pemesanan.');
    }
  }
}