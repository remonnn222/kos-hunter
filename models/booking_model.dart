// Path: lib/models/booking_model.dart
class BookingModel {
  final int id;
  final int kosId;
  final int userId; // FK ke Society
  final DateTime startDate;
  final DateTime endDate;
  final String status; // pending/accept/reject
  // Tambahkan data kos atau user jika diperlukan di model ini (opsional)

  BookingModel({
    required this.id,
    required this.kosId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      kosId: json['kos_id'] as int,
      userId: json['user_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
    );
  }
}