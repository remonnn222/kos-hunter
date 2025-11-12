// Path: lib/features/kos/state/kos_list_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/features/kos/repository/kos_repository.dart';
import 'package:kos_app/models/kos_model.dart';

// State: AsyncValue<List<KosModel>>
final ownerKosListNotifierProvider = 
    AsyncNotifierProvider<OwnerKosListNotifier, List<KosModel>>(() {
  return OwnerKosListNotifier();
});

class OwnerKosListNotifier extends AsyncNotifier<List<KosModel>> {
  late final KosRepository _repository;

  @override
  Future<List<KosModel>> build() async {
    _repository = ref.watch(kosRepositoryProvider);
    // Secara default, muat semua Kos milik Owner saat pertama kali dibuat
    return _repository.getOwnerKosList();
  }
  
  // --- READ (Reload) ---
  Future<void> refreshKosList() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getOwnerKosList());
  }

  // --- CREATE ---
  Future<void> addKos(Map<String, dynamic> kosData) async {
    final oldState = state; // Simpan state lama jika terjadi error
    
    // Set state ke loading (opsional) atau update secara optimistis
    state = const AsyncValue.loading(); 

    try {
      final newKos = await _repository.createKos(kosData);

      // Optimistic UI Update: Tambahkan Kos baru ke daftar lokal
      final updatedList = [...oldState.value!, newKos];
      state = AsyncValue.data(updatedList);
    } catch (e, stack) {
      // Jika gagal, kembalikan state ke nilai sebelumnya dan tampilkan error
      state = oldState; 
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  // --- UPDATE ---
  Future<void> updateKos(int kosId, Map<String, dynamic> kosData) async {
    final oldState = state;

    try {
      final updatedKos = await _repository.updateKos(kosId, kosData);
      
      // Update data Kos di list lokal
      final updatedList = [
        for (final kos in oldState.value!)
          if (kos.id == kosId) updatedKos else kos,
      ];
      state = AsyncValue.data(updatedList);
    } catch (e, stack) {
      state = oldState;
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  // --- DELETE ---
  Future<void> deleteKos(int kosId) async {
    final oldState = state;
    
    // Optimistic UI Delete: Hapus dari list sebelum konfirmasi API
    final listBeforeDelete = oldState.value!;
    final updatedList = listBeforeDelete.where((kos) => kos.id != kosId).toList();
    state = AsyncValue.data(updatedList);
    
    try {
      await _repository.deleteKos(kosId);
      // Sukses, state sudah terupdate
    } catch (e, stack) {
      // Jika gagal, kembalikan Kos yang terhapus
      state = oldState;
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}