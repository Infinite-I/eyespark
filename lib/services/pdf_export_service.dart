// lib/services/pdf_export_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/obstacle_data.dart';

class PDFExportService {
  static final PDFExportService _instance = PDFExportService._internal();
  factory PDFExportService() => _instance;
  PDFExportService._internal();

  Future<File> generateStatisticsPDF({
    required List<ObstacleData> history,
    required int totalDetections,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    int highUrgency = history.where((o) => o.urgency == 'high').length;
    int mediumUrgency = history.where((o) => o.urgency == 'medium').length;
    int lowUrgency = history.where((o) => o.urgency == 'low').length;

    double avgDistance = history.isEmpty
        ? 0
        : history.map((e) => e.distanceCm).reduce((a,b) => a+b) / history.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Navigation Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildStatRow('Period', '${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}'),
                            _buildStatRow('Total detections', '$totalDetections'),
                            _buildStatRow('Average distance', '${avgDistance.toStringAsFixed(1)} cm'),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildStatRow('High urgency', '$highUrgency'),
                            _buildStatRow('Medium urgency', '$mediumUrgency'),
                            _buildStatRow('Low urgency', '$lowUrgency'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              'Last 10 detections',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            // CORRECTION: Utilisation de TableHelper au lieu de Table
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Time', 'Distance', 'Direction', 'Urgency'],
              data: history.reversed.take(10).map((o) {
                return [
                  '${o.getDateTime().day}/${o.getDateTime().month}',
                  '${o.getDateTime().hour}:${o.getDateTime().minute.toString().padLeft(2, '0')}',
                  '${o.distanceCm} cm',
                  o.direction,
                  o.urgency,
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: pw.EdgeInsets.all(8),
            ),

            pw.SizedBox(height: 20),

            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Navigation Aid Pro - Automatically generated report',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/navigation_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildStatRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> openPDF(File file) async {
    debugPrint('📄 PDF generated at: ${file.path}');
  }
}