// Path: lib/features/society/state/kos_search_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kos_app/features/kos/repository/kos_repository.dart';
import 'package:kos_app/models/kos_model.dart';

// 1. State untuk menyimpan parameter filter/pencarian
class KosFilterState {
  final String gender; // 'male', 'female', 'all'
  final String keyword;

  KosFilterState({this.gender = 'all', this.keyword = ''});
  
  // Method copyWith untuk membuat instance baru (immutability)
  KosFilterState copyWith({String? gender, String? keyword}) {
    return KosFilterState(
      gender: gender ?? this.gender,
      keyword: keyword ?? this.keyword,
    );
  }
}

// 2. Notifier utama untuk mengelola daftar Kos Society
// State: AsyncValue<List<KosModel>>
final societyKosListNotifierProvider = 
    AsyncNotifierProvider<SocietyKosListNotifier, List<KosModel>>(() {
  return SocietyKosListNotifier();
});

class SocietyKosListNotifier extends AsyncNotifier<List<KosModel>> {
  late final KosRepository _repository;
  // State filter yang akan diobservasi oleh notifier ini
  KosFilterState _currentFilter = KosFilterState(); 

  @override
  Future<List<KosModel>> build() async {
    _repository = ref.watch(kosRepositoryProvider);
    // Muat data awal tanpa filter
    return _fetchKos();
  }
  
  // Metode internal untuk mengambil data berdasarkan filter saat ini
  Future<List<KosModel>> _fetchKos() {
    return _repository.getPublicKosList(
      genderFilter: _currentFilter.gender,
      searchKeyword: _currentFilter.keyword,
    );
  }

  // Aksi: Mengubah filter (dipanggil dari UI)
  Future<void> setFilter({String? gender, String? keyword, bool refresh = true}) async {
    // Update state filter
    _currentFilter = _currentFilter.copyWith(
      gender: gender, 
      keyword: keyword
    );
    
    // Muat ulang data jika refresh=true
    if (refresh) {
      state = const AsyncValue.loading();
      // Menggunakan AsyncValue.guard untuk menangani error dan loading secara otomatis
      state = await AsyncValue.guard(() => _fetchKos());
    }
  }
  
  // Getter untuk mendapatkan filter saat ini (untuk UI filter chip)
  KosFilterState get currentFilter => _currentFilter;
}