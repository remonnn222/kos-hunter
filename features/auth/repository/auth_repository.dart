// Path: lib/features/auth/repository/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kos_app/models/user_model.dart';
import 'package:kos_app/services/api/api_client.dart'; // Import dioProvider & sharedPreferencesProvider

// Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthRepository(this._dio, this._prefs);

  // Endpoint: /api/v1/auth/login
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Asumsi respons berhasil memiliki struktur: {'user': {...}, 'token': '...'}
      final userData = response.data['user'];
      final token = response.data['token'] as String;
      
      // Gabungkan data user dan token
      final userModel = UserModel.fromJson({...userData, 'token': token});

      // Simpan token untuk permintaan berikutnya
      await _prefs.setString('auth_token', token);
      
      return userModel;

    } on DioException catch (e) {
      // DioException bisa berupa 400, 404, 500, dll.
      String errorMessage = e.response?.data['message'] ?? 'Login gagal. Periksa kredensial Anda.';
      throw Exception(errorMessage);
    }
  }

  // Endpoint: /api/v1/auth/register
  Future<UserModel> register({
    required String name, 
    required String email, 
    required String password,
    required String phone,
    required String role, // 'owner' atau 'society'
  }) async {
    // Logika mirip dengan login, hanya beda endpoint dan data
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        },
      );
      
      final userData = response.data['user'];
      final token = response.data['token'] as String;
      
      final userModel = UserModel.fromJson({...userData, 'token': token});

      await _prefs.setString('auth_token', token);

      return userModel;

    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'Registrasi gagal. Coba lagi.';
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    // Hapus token lokal dan data user
    await _prefs.remove('auth_token');
    await _prefs.remove('user_data');
    // Anda bisa memanggil endpoint logout API jika diperlukan
    // await _dio.post('/auth/logout');
  }
}