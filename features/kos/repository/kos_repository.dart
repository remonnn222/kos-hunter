// ... (Kelas KosRepository yang sudah ada)

class KosRepository {
  final Dio _dio;
  KosRepository(this._dio);

  final String _endpoint = '/kos'; // Endpoint: /api/v1/kos

  // ... (getOwnerKosList, createKos, updateKos, deleteKos, addFacility tetap sama)

  // --- 5. READ ALL (List Kos untuk Society dengan Filtering) ---
  Future<List<KosModel>> getPublicKosList({
    String? genderFilter, // male, female, all
    String? searchKeyword,
  }) async {
    try {
      final queryParams = {
        if (genderFilter != null && genderFilter != 'all') 'gender': genderFilter,
        if (searchKeyword != null && searchKeyword.isNotEmpty) 'search': searchKeyword,
      };

      // Endpoint umum untuk semua kos
      final response = await _dio.get(_endpoint, queryParameters: queryParams); 
      
      final List data = response.data['data'] as List;
      return data.map((e) => KosModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat daftar Kos.');
    }
  }

  // --- 6. READ Detail Kos (Untuk halaman detail) ---
  Future<KosModel> getKosDetail(int kosId) async {
    try {
      final response = await _dio.get('$_endpoint/$kosId');
      return KosModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat detail Kos.');
    }
  }
}