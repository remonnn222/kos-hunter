// Path: lib/features/owner/presentation/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/features/owner/state/owner_booking_notifier.dart';

class OwnerHistoryScreen extends ConsumerWidget {
  const OwnerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookingsAsync = ref.watch(ownerBookingsNotifierProvider);
    
    // --- State Lokal untuk Filtering Tanggal/Bulan ---
    // final filterMonth = useState(DateTime.now().month);
    // final filterYear = useState(DateTime.now().year);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histori Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // TODO: Tambahkan Dropdown Filter Bulan & Tahun
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter: November 2025', style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.filter_list),
              ],
            ),
          ),
          
          Expanded(
            child: allBookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Gagal: ${e.toString()}')),
              data: (bookings) {
                // Filter berdasarkan bulan/tahun (logika sederhana)
                final filteredBookings = bookings.where((b) => b.status == 'accept').toList(); 
                
                if (filteredBookings.isEmpty) {
                  return const Center(child: Text('Tidak ada transaksi yang berhasil di bulan ini.'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    // Tampilkan ringkasan transaksi
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text('Booking #${booking.id} - Diterima'),
                        subtitle: Text('ID Kos: ${booking.kosId} | Mulai: ${booking.startDate.day}/${booking.startDate.month}'),
                        trailing: const Text('Lihat Detail', style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}