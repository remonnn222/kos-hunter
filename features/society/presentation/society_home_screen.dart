import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/features/kos/state/kos_list_notifier.dart';
import 'package:kos_app/features/society/presentation/kos_detail_screen.dart';
import 'package:kos_app/features/auth/state/auth_state_notifier.dart';
import 'package:kos_app/models/kos_model.dart';

class SocietyHomeScreen extends ConsumerWidget {
  const SocietyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Kos Premium'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout(); 
            },
          ),
          // TODO: Tambahkan tombol Profil/Booking History Society
        ],
      ),
      body: const KosListWidget(),
    );
  }
}

// Widget untuk menampilkan daftar Kos (Re-use dari langkah sebelumnya)
class KosListWidget extends ConsumerWidget {
  const KosListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider yang akan otomatis memuat data
    final kosListAsync = ref.watch(kosListNotifierProvider);
    
    // Tampilkan data sesuai status AsyncValue
    return kosListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Gagal memuat kos: ${e.toString()}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => ref.invalidate(kosListNotifierProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
      data: (kosList) {
        if (kosList.isEmpty) {
          return const Center(child: Text('Belum ada data kos tersedia.'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            // Memaksa refresh data
            ref.invalidate(kosListNotifierProvider);
            await ref.read(kosListNotifierProvider.future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: kosList.length,
            itemBuilder: (context, index) {
              final kos = kosList[index];
              return KosListItem(kos: kos);
            },
          ),
        );
      },
    );
  }
}

// Komponen Card untuk setiap item Kos
class KosListItem extends StatelessWidget {
  final KosModel kos;
  const KosListItem({super.key, required this.kos});

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/bln';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => KosDetailScreen(kosId: kos.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Kos
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                kos.images.isNotEmpty ? kos.images.first.fileUrl : 'https://via.placeholder.com/600x300.png?text=Kos+Image',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 40)),
                ),
              ),
            ),
            
            // Detail Teks
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Kos & Gender
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kos.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kos.gender.toLowerCase() == 'pria' ? Colors.blue.shade100 : Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          kos.gender.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kos.gender.toLowerCase() == 'pria' ? Colors.blue.shade800 : Colors.pink.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Alamat
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          kos.address,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Harga
                  Text(
                    _formatCurrency(kos.pricePerMonth),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
