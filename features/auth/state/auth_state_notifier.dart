// Path: lib/features/auth/state/auth_state_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/features/auth/repository/auth_repository.dart';
import 'package:kos_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State: AsyncValue<UserModel?>. 
// Data adalah UserModel jika logged in, null jika logged out.
// AsyncValue menangani loading dan error.
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthRepository _authRepository;
  late final SharedPreferences _prefs;

  @override
  Future<UserModel?> build() async {
    _authRepository = ref.watch(authRepositoryProvider);
    _prefs = ref.watch(sharedPreferencesProvider);
    
    // 1. Cek apakah ada data pengguna yang tersimpan saat aplikasi pertama kali dibuka
    return await _getStoredUser();
  }

  Future<UserModel?> _getStoredUser() async {
    final token = _prefs.getString('auth_token');
    // Di sini Anda bisa menambahkan logika untuk memverifikasi token ke API
    // Untuk saat ini, kita hanya mengandalkan token lokal
    if (token != null) {
      // TODO: Ambil data user dari lokal storage jika ada, atau panggil /auth/me
      // Untuk demo, kita asumsikan jika token ada, user valid (atau akan dicek di API call pertama)
      debugPrint('Token ditemukan. User dianggap logged in.');
      // State awal bisa null, atau fetch data user jika diperlukan
      return null; 
    }
    return null;
  }

  // --- Metode Login ---
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading(); // Set state menjadi loading
    try {
      final user = await _authRepository.login(
        email: email, 
        password: password
      );
      state = AsyncValue.data(user); // Set state dengan data pengguna
    } catch (e, stack) {
      state = AsyncValue.error(e, stack); // Set state dengan error
      // Re-throw untuk ditangkap oleh UI (contoh: snackbar)
      rethrow; 
    }
  }
  
  // --- Metode Logout ---
  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authRepository.logout();
    state = const AsyncValue.data(null); // Kembali ke state logged out
  }
}
  