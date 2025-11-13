import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/models/review_model.dart';
import 'package:kos_app/services/api/api_client.dart'; // dioProvider

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(dioProvider));
});

class ReviewRepository {
  final Dio _dio;
  ReviewRepository(this._dio);

  final String _endpoint = '/reviews'; // Endpoint: /api/v1/reviews

  // --- 1. GET Ulasan per Kos ---
  Future<List<ReviewModel>> getReviewsByKosId(int kosId) async {
    try {
      // Asumsi: API memiliki endpoint untuk filter berdasarkan kos_id
      final response = await _dio.get('$_endpoint/kos/$kosId');
      
      final List data = response.data['data'] as List;
      return data.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat ulasan.');
    }
  }

  // --- 2. Tambah Ulasan Baru ---
  Future<ReviewModel> addReview({
    required int kosId,
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        _endpoint,
        data: {
          'kos_id': kosId,
          'comment': comment,
        },
      );
      // Asumsi API mengembalikan data review yang baru dibuat, termasuk data user
      return ReviewModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambahkan ulasan.');
    }
  }
}
