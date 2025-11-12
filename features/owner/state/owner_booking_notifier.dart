// Path: lib/features/owner/state/owner_booking_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/features/owner/repository/owner_repository.dart';
import 'package:kos_app/models/booking_model.dart';

// State: AsyncValue<List<BookingModel>>
final ownerBookingsNotifierProvider = 
    AsyncNotifierProvider<OwnerBookingsNotifier, List<BookingModel>>(() {
  return OwnerBookingsNotifier();
});

class OwnerBookingsNotifier extends AsyncNotifier<List<BookingModel>> {
  late final OwnerRepository _repository;

  @override
  Future<List<BookingModel>> build() async {
    _repository = ref.watch(ownerRepositoryProvider);
    return _repository.getAllOwnerBookings();
  }
  
  Future<void> refreshBookings() async {
    state = await AsyncValue.guard(() => _repository.getAllOwnerBookings());
  }

  // --- Aksi: Update Status Booking ---
  Future<void> updateBookingStatus(int bookingId, String newStatus) async {
    final oldState = state;
    // Set loading hanya untuk item tersebut (UI lokal) atau global
    
    try {
      final updatedBooking = await _repository.updateBookingStatus(
        bookingId: bookingId, 
        status: newStatus
      );

      // Optimistic UI Update: Ganti item lama dengan yang baru
      final updatedList = [
        for (final booking in oldState.value!)
          if (booking.id == bookingId) updatedBooking else booking,
      ];
      state = AsyncValue.data(updatedList);
    } catch (e, stack) {
      // Jika gagal, kembalikan state lama
      state = oldState; 
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}