/// خدمة تصدير البيانات
/// تصدر البيانات إلى Excel و PDF و CSV ومشاركة الملفات

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// خدمة تصدير البيانات
class ExportService {
  /// تصدير إلى Excel
  Future<String> exportToExcel({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // إضافة العنوان
    sheet.appendRow([title]);
    sheet.appendRow(['تاريخ التصدير: ${DateTime.now().toString().split('.')[0]}']);
    sheet.appendRow([]);

    // إضافة الرؤوس
    sheet.appendRow(headers);

    // إضافة البيانات
    for (final row in data) {
      sheet.appendRow(row);
    }

    // حفظ الملف
    final bytes = excel.encode()!;
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(
      dir.path,
      fileName ?? 'export_$timestamp.xlsx',
    );
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    
    return filePath;
  }

  /// تصدير إلى PDF
  Future<String> exportToPDF({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
    String? fileName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // العنوان
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('تاريخ التصدير: ${DateTime.now().toString().split('.')[0]}'),
              pw.SizedBox(height: 20),
              
              // الجدول
              pw.Table.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.center,
              ),
            ],
          );
        },
      ),
    );

    // حفظ الملف
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(
      dir.path,
      fileName ?? 'export_$timestamp.pdf',
    );
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return filePath;
  }

  /// تصدير إلى CSV
  Future<String> exportToCSV({
    required List<String> headers,
    required List<List<dynamic>> data,
    String? fileName,
  }) async {
    final buffer = StringBuffer();
    
    // إضافة الرؤوس
    buffer.writeln(headers.join(','));
    
    // إضافة البيانات
    for (final row in data) {
      buffer.writeln(row.map((cell) => _escapeCsvValue(cell.toString())).join(','));
    }

    // حفظ الملف
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(
      dir.path,
      fileName ?? 'export_$timestamp.csv',
    );
    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    
    return filePath;
  }

  /// مشاركة ملف
  Future<void> shareFile(String filePath, {String? subject}) async {
    final file = XFile(filePath);
    await Share.shareXFiles(
      [file],
      subject: subject ?? 'تصدير البيانات',
    );
  }

  /// تنظيف قيمة CSV
  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
