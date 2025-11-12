// Path: lib/utils/pdf_generator.dart
import 'package:flutter/material.dart' hide BoxDecoration, Padding;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // Tambahkan intl di pubspec jika belum

// Model data yang dibutuhkan untuk nota
class NotaData {
  final String bookingId;
  final String kosName;
  final String kosAddress;
  final String societyName;
  final DateTime startDate;
  final DateTime endDate;
  final double pricePerMonth;
  final String status;

  NotaData({
    required this.bookingId,
    required this.kosName,
    required this.kosAddress,
    required this.societyName,
    required this.startDate,
    required this.endDate,
    required this.pricePerMonth,
    required this.status,
  });
}

class PdfGenerator {
  // Utility untuk format mata uang
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );
    return formatter.format(amount);
  }
  
  // Fungsi utama untuk membuat dan menampilkan PDF
  static Future<void> generateAndPrintNota(NotaData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Nota Pemesanan Kos Premium',
                style: pw.TextStyle(
                  fontSize: 24, 
                  fontWeight: pw.FontWeight.bold, 
                  color: PdfColor.fromInt(0xFF303F9F) // Deep Indigo
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Bukti Transaksi No: #${data.bookingId}', style: const pw.TextStyle(fontSize: 12)),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Detail Society
              pw.Text('Detail Pemesan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _buildDetailRow(label: 'Nama', value: data.societyName),
              pw.SizedBox(height: 10),

              // Detail Kos
              pw.Text('Detail Kos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _buildDetailRow(label: 'Nama Kos', value: data.kosName),
              _buildDetailRow(label: 'Alamat', value: data.kosAddress),
              pw.SizedBox(height: 10),

              // Detail Pemesanan
              pw.Text('Detail Pemesanan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _buildDetailRow(label: 'Mulai Huni', value: DateFormat('dd MMMM yyyy', 'id_ID').format(data.startDate)),
              _buildDetailRow(label: 'Selesai Huni', value: DateFormat('dd MMMM yyyy', 'id_ID').format(data.endDate)),
              _buildDetailRow(label: 'Harga/Bulan', value: formatCurrency(data.pricePerMonth)),
              _buildDetailRow(label: 'Status', value: data.status.toUpperCase(), isStatus: true),
              
              pw.SizedBox(height: 30),
              
              // Total (Asumsi hanya 1 bulan untuk nota ini)
              pw.Text(
                'TOTAL PEMBAYARAN: ${formatCurrency(data.pricePerMonth)}',
                style: pw.TextStyle(
                  fontSize: 16, 
                  fontWeight: pw.FontWeight.extraBold,
                  color: PdfColor.fromInt(0xFF303F9F)
                ),
              ),

              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Terima kasih telah melakukan pemesanan melalui aplikasi Kos-Kosan Premium.', 
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)
                ),
              ),
            ]
          );
        },
      ),
    );

    // Tampilkan pratinjau PDF dan opsi cetak/share
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Nota_Kos_${data.bookingId}.pdf');
  }

  static pw.Widget _buildDetailRow({required String label, required String value, bool isStatus = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          if (isStatus)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: value == 'ACCEPT' ? PdfColors.green300 : PdfColors.orange300,
                borderRadius: pw.BorderRadius.circular(5)
              ),
              child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            )
          else
            pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}