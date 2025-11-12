// ... (Import yang sudah ada)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... dan semua import lokal Anda

// Tambahkan import screen
import 'features/auth/state/auth_state_notifier.dart';
import 'features/owner/presentation/owner_dashboard_screen.dart'; // Placeholder
import 'features/society/presentation/society_home_screen.dart'; // Placeholder
import 'features/auth/presentation/login_screen.dart';

// Variabel global untuk SharedPreferences (akan diisi di main)
late final SharedPreferences sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // WAJIB: Inisialisasi SharedPreferences sebelum runApp
  sharedPreferences = await SharedPreferences.getInstance(); 

  runApp(
    ProviderScope(
      overrides: [
        // Timpa provider agar menggunakan instance yang sudah diinisialisasi
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

// ... (Kelas MyApp dan _buildAppTheme tetap sama)

// Tambahkan Widget Router utama yang menonton state autentikasi
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Belum Logged In
          return const LoginScreen();
        } 
        
        // Sudah Logged In: Arahkan ke Dashboard sesuai Role
        if (user.role == UserRole.owner) {
          return const OwnerDashboardScreen();
        } else if (user.role == UserRole.society) {
          return const SocietyHomeScreen();
        }
        
        // Default, jika role tidak dikenal (seharusnya tidak terjadi)
        return const LoginScreen(); 
      },
      loading: () => const Scaffold(
        body: Center(
          // Loading screen yang elegan
          child: CircularProgressIndicator(color: Color(0xFF303F9F)), 
        ),
      ),
      error: (e, s) {
        // Handle error saat fetch user awal (misal token invalid)
        return Scaffold(
          body: Center(
            child: Text('Terjadi Error: ${e.toString()}'),
          ),
        );
      },
    );
  }
}