// Path: lib/models/kos_model.dart

// --- Model Gambar Kos ---
class KosImageModel {
  final int id;
  final String fileUrl;

  KosImageModel({required this.id, required this.fileUrl});

  factory KosImageModel.fromJson(Map<String, dynamic> json) {
    return KosImageModel(
      id: json['id'] as int,
      fileUrl: json['file'] as String, // Asumsi API fieldnya 'file'
    );
  }
}

// --- Model Fasilitas Kos ---
class KosFacilityModel {
  final int id;
  final String facility;

  KosFacilityModel({required this.id, required this.facility});

  factory KosFacilityModel.fromJson(Map<String, dynamic> json) {
    return KosFacilityModel(
      id: json['id'] as int,
      facility: json['facility'] as String, // Asumsi API fieldnya 'facility'
    );
  }
}

// --- Model Utama Kos ---
class KosModel {
  final int id;
  final int ownerId; // user_id
  final String name;
  final String address;
  final double pricePerMonth;
  final String gender; // male/female/all
  final List<KosImageModel> images;
  final List<KosFacilityModel> facilities;
  // Kita bisa tambahkan field ketersediaan/status jika ada di API/DB

  KosModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.pricePerMonth,
    required this.gender,
    this.images = const [],
    this.facilities = const [],
  });

  factory KosModel.fromJson(Map<String, dynamic> json) {
    // Mapping Images
    final List<KosImageModel> images = (json['kos_image'] as List?)
        ?.map((e) => KosImageModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    // Mapping Facilities
    final List<KosFacilityModel> facilities = (json['kos_facilities'] as List?)
        ?.map((e) => KosFacilityModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return KosModel(
      id: json['id'] as int,
      ownerId: json['user_id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      // Penting: Pastikan mapping ke double
      pricePerMonth: (json['price_per_month'] as num).toDouble(), 
      gender: json['gender'] as String,
      images: images,
      facilities: facilities,
    );
  }
}