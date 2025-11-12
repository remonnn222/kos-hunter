// Path: lib/features/owner/presentation/owner_dashboard_screen.dart (Revisi)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/features/kos/state/kos_list_notifier.dart';
import 'package:kos_app/features/owner/presentation/owner_profile_screen.dart'; // Import Baru
import 'package:kos_app/features/owner/presentation/owner_booking_manager_screen.dart'; // Import Baru
import 'package:kos_app/features/owner/presentation/history_screen.dart'; // Import Baru
import 'package:kos_app/features/auth/state/auth_state_notifier.dart'; // Untuk Logout

// ... (Kelas OwnerDashboardScreen & KosListManager tetap dipertahankan)

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4, // Kos, Booking, Review, Histori
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Owner Panel', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerProfileScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout(); 
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFC5CAE9), // Light Indigo
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.home_work), text: "Manajemen Kos"),
              Tab(icon: Icon(Icons.book_online), text: "Pemesanan"),
              Tab(icon: Icon(Icons.reviews), text: "Ulasan"),
              Tab(icon: Icon(Icons.history), text: "Histori Transaksi"),
            ],
          ),
        ),
        
        body: TabBarView(
          children: [
            const KosListManager(), // Dari Langkah 3
            const OwnerBookingManagerScreen(), // BARU: Manajemen Pemesanan
            const OwnerReviewManagerScreen(), // BARU: Manajemen Ulasan
            const OwnerHistoryScreen(), // BARU: Histori Transaksi
          ],
        ),
        
        // Floating Action Button hanya untuk Tab Kos
        floatingActionButton: ref.watch(tabIndexProvider) == 0 ? FloatingActionButton.extended(
          onPressed: () { /* TODO: Navigate ke Add Kos Screen */ },
          label: const Text('Tambah Kos'),
          icon: const Icon(Icons.add_home_work_rounded),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
        ) : null,
      ),
    );
  }
}

// Provider sederhana untuk melacak index tab (untuk FAB)
final tabIndexProvider = StateProvider<int>((ref) => 0); 

// Kita perlu Wrap OwnerDashboardScreen dengan Widget yang mengupdate tabIndexProvider
// Misalnya, dalam main.dart atau di atas MaterialApp.

// --- OwnerBookingManagerScreen (BARU) ---
class OwnerBookingManagerScreen extends ConsumerWidget {
  const OwnerBookingManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(ownerBookingsNotifierProvider);
    
    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Gagal memuat booking: ${e.toString()}')),
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Center(child: Text('Tidak ada permintaan pemesanan masuk.'));
        }
        return ListView.builder(
          itemCount: bookings.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Kos ID: ${booking.kosId} | User ID: ${booking.userId}'),
                subtitle: Text('Status: ${booking.status.toUpperCase()} | Mulai: ${booking.startDate.day}/${booking.startDate.month}'),
                trailing: booking.status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () async {
                              await ref.read(ownerBookingsNotifierProvider.notifier).updateBookingStatus(booking.id, 'accept');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              await ref.read(ownerBookingsNotifierProvider.notifier).updateBookingStatus(booking.id, 'reject');
                            },
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

// --- OwnerReviewManagerScreen (BARU) ---
class OwnerReviewManagerScreen extends ConsumerWidget {
  const OwnerReviewManagerScreen({super.key});

  // Asumsi ada provider untuk list review Owner (mirip ownerBookingsNotifierProvider)
  final reviewsForOwnerProvider = FutureProvider((ref) => ref.watch(ownerRepositoryProvider).getReviewsForOwnerKos());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsForOwnerProvider);
    
    return reviewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Gagal memuat ulasan: ${e.toString()}')),
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(child: Text('Belum ada ulasan untuk Kos Anda.'));
        }
        return ListView.builder(
          itemCount: reviews.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.comment),
                title: Text('Ulasan dari ${review.userName} (Kos ID: ${review.kosId})'),
                subtitle: Text(review.comment, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: TextButton(
                  onPressed: () {
                    // TODO: Tampilkan dialog untuk Balas Ulasan
                  },
                  child: const Text('Balas'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


// --- OwnerProfileScreen (BARU) ---
class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state user yang sedang login
    final userAsync = ref.watch(authNotifierProvider);
    final user = userAsync.value;

    if (user == null) return const Center(child: Text('Data pengguna tidak tersedia.'));

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    
    void updateProfile() async {
      try {
        final Map<String, dynamic> data = {
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
        };
        // Logika update profile harus di implementasikan di AuthNotifier
        // await ref.read(authNotifierProvider.notifier).updateProfile(data);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui (Mock)!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Owner', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Update Data Profil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
            const SizedBox(height: 16),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', enabled: false), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telepon'), keyboardType: TextInputType.phone),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: userAsync.isLoading ? null : updateProfile,
              child: userAsync.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}