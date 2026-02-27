import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/date_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

final pdfServiceProvider = Provider((ref) => PdfService());

class PdfService {
  Future<void> exportReportPdf({
    required String storeName,
    required Map<String, double> revenueData,
  }) async {
    final pdf = pw.Document();

    // Sort keys just in case
    final keys = revenueData.keys.toList()..sort();
    double totalRevenue = 0;
    for (var val in revenueData.values) {
      totalRevenue += val;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                storeName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'RINGKASAN PENDAPATAN 7 HARI',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Dicetak: ${DateFormatter.formatDateTime(DateTime.now())}',
              ),
              pw.SizedBox(height: 24),
              pw.TableHelper.fromTextArray(
                headers: ['Tanggal', 'Pendapatan'],
                data: keys
                    .map(
                      (date) => [
                        DateFormatter.formatDate(DateTime.parse(date)),
                        'Rp ${revenueData[date]!.toInt()}',
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.black,
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey),
                  ),
                ),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL PENDAPATAN',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    'Rp ${totalRevenue.toInt()}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File(
      "${output.path}/Laporan_KasirGo_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // ignore: deprecated_member_use
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Laporan Pendapatan KasirGo');
  }
}
