// Path: lib/services/api/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider untuk Shared Preferences (untuk menyimpan token)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Dalam real apps, ini harus diinisialisasi di main.dart
  throw UnimplementedError(); 
});

// Provider untuk Dio Client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // Ganti dengan Base URL API dari sekolah
      baseUrl: 'c:\Users\SMK TELKOM 005\OneDrive\Documents\rpl\RPL KELAS 12\Kos hunter ukk kls12\kostq\lib\services\api_service.dart', 
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Interceptor untuk menambahkan Token Otentikasi
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final prefs = ref.read(sharedPreferencesProvider);
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    // Tambahkan error handling (misalnya, auto-logout jika 401 Unauthorized)
    onError: (DioException e, handler) async {
      if (e.response?.statusCode == 401) {
        // TODO: Implement logout logic di sini
        debugPrint('Token Expired or Invalid. Logging out...');
      }
      return handler.next(e);
    }
  ));

  return dio;
});