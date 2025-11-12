// Path: lib/features/society/presentation/kos_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/features/kos/repository/kos_repository.dart';
import 'package:kos_app/features/society/repository/booking_repository.dart';
import 'package:kos_app/features/society/repository/review_repository.dart';
import 'package:kos_app/models/kos_model.dart';
import 'package:kos_app/models/review_model.dart';
import 'package:kos_app/utils/pdf_generator.dart'; // Import PDF Utility

// Provider untuk data detail kos (agar bisa di-refresh/diakses di detail)
final kosDetailProvider = FutureProvider.family<KosModel, int>((ref, kosId) {
  return ref.watch(kosRepositoryProvider).getKosDetail(kosId);
});

// Provider untuk daftar ulasan kos
final reviewsProvider = FutureProvider.family<List<ReviewModel>, int>((ref, kosId) {
  return ref.watch(reviewRepositoryProvider).getReviewsByKosId(kosId);
});

class KosDetailScreen extends ConsumerWidget {
  final int kosId;
  const KosDetailScreen({super.key, required this.kosId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kosDetailAsync = ref.watch(kosDetailProvider(kosId));
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: kosDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Gagal memuat detail: $e')),
        data: (kos) => Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Bagian Gambar (Header) ---
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.network(
                      kos.images.isNotEmpty ? kos.images.first.fileUrl : 'https://via.placeholder.com/600x300.png?text=Kos+Image',
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // --- Detail Kos ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kos.name, style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 8),
                        Text(kos.address, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        const Divider(height: 30),
                        
                        // Harga dan Gender (Re-use component dari Step 4)
                        _buildPriceAndGenderRow(context, kos),
                        const Divider(height: 30),

                        // --- Fasilitas ---
                        Text('Fasilitas Unggulan', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: kos.facilities.map((f) => Chip(label: Text(f.facility))).toList(),
                        ),
                        const Divider(height: 30),
                        
                        // --- Ulasan/Review ---
                        ReviewSection(kosId: kos.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // --- Floating Bottom Bar untuk Booking ---
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomBookingBar(kos: kos),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper untuk baris Harga dan Gender
  Widget _buildPriceAndGenderRow(BuildContext context, KosModel kos) {
    String formatCurrency(double amount) => 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/bln';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Harga Per Bulan', style: TextStyle(color: Colors.grey[600])),
            Text(
              formatCurrency(kos.pricePerMonth),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Untuk ${kos.gender.toUpperCase()}',
            style: TextStyle(
              color: Theme.of(context).primaryColor, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }
}

// --- Komponen: Review Section ---
class ReviewSection extends ConsumerWidget {
  final int kosId;
  const ReviewSection({super.key, required this.kosId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(kosId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ulasan Pengguna', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Tambah Ulasan'),
              onPressed: () => _showAddReviewDialog(context, ref, kosId),
            ),
          ],
        ),
        reviewsAsync.when(
          loading: () => const Center(child: Text('Memuat ulasan...')),
          error: (e, s) => Center(child: Text('Gagal: $e')),
          data: (reviews) {
            if (reviews.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Belum ada ulasan. Jadilah yang pertama!'),
              ));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Text(review.userName[0]),
                    ),
                    title: Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(review.comment),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
  
  // Dialog untuk menambahkan ulasan baru
  void _showAddReviewDialog(BuildContext context, WidgetRef ref, int kosId) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Berikan Ulasan Anda'),
        content: TextField(
          controller: commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tuliskan pengalaman Anda di sini...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (commentController.text.isEmpty) return;
              try {
                // Panggil API untuk menambahkan review
                await ref.read(reviewRepositoryProvider).addReview(
                  kosId: kosId, 
                  comment: commentController.text,
                );
                // Refresh daftar ulasan setelah berhasil
                ref.invalidate(reviewsProvider(kosId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ulasan berhasil ditambahkan!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: ${e.toString()}')),
                );
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }
}

// --- Komponen: Bottom Booking Bar ---
class BottomBookingBar extends ConsumerWidget {
  final KosModel kos;
  const BottomBookingBar({super.key, required this.kos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Harga dibulatkan ke atas untuk display
    final priceDisplay = 'Rp ${kos.pricePerMonth.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total (Estimasi 1 Bulan)', style: TextStyle(color: Colors.grey)),
              Text(
                priceDisplay,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _handleBooking(context, ref, kos),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }

  // --- Logic Pemesanan dan Cetak Nota ---
  void _handleBooking(BuildContext context, WidgetRef ref, KosModel kos) async {
    // Logika tanggal sederhana (hari ini sampai bulan depan)
    final startDate = DateTime.now();
    final endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
    
    // Asumsi user sedang login, kita perlu data user dari AuthNotifier
    // UserModel? currentUser = ref.read(authNotifierProvider).value; 
    // if (currentUser == null) { /* Handle error / re-login */ return; }

    try {
      // 1. Panggil API Pemesanan
      final booking = await ref.read(bookingRepositoryProvider).createBooking(
        kosId: kos.id, 
        startDate: startDate, 
        endDate: endDate,
      );

      // 2. Beri Feedback Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemesanan berhasil diajukan! Status: Pending')),
      );

      // 3. Tampilkan opsi Cetak Nota
      final bool? confirmPrint = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pemesanan Berhasil'),
          content: const Text('Apakah Anda ingin mencetak atau membagikan nota pemesanan sekarang?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Nanti')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cetak Nota')),
          ],
        ),
      );

      if (confirmPrint == true) {
        // Asumsi nama society dari user yang sedang login
        final String societyName = 'Nama Society Mock'; // Ganti dengan currentUser!.name
        
        // Buat data nota
        final notaData = NotaData(
          bookingId: booking.id.toString(),
          kosName: kos.name,
          kosAddress: kos.address,
          societyName: societyName,
          startDate: booking.startDate,
          endDate: booking.endDate,
          pricePerMonth: kos.pricePerMonth,
          status: booking.status,
        );
        
        // Panggil PDF Generator
        await PdfGenerator.generateAndPrintNota(notaData);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pemesanan Gagal: ${e.toString()}')),
      );
    }
  }
}