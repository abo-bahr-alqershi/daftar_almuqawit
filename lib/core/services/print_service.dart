/// خدمة الطباعة
/// تدير طباعة الإيصالات والتقارير مع معاينة ودعم طابعات Bluetooth

import 'dart:io';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// خدمة الطباعة
class PrintService {
  /// طباعة ملف PDF
  Future<void> printPdf(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('الملف غير موجود');
    }
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  /// طباعة إيصال
  Future<void> printReceipt({
    required String title,
    required Map<String, String> details,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // العنوان
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              
              // التفاصيل
              ...details.entries.map((entry) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(entry.key),
                  pw.Text(entry.value),
                ],
              )),
              pw.SizedBox(height: 10),
              pw.Divider(),
              
              // الأصناف
              ...items.map((item) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(item['name'] ?? ''),
                  pw.Text('${item['quantity']} x ${item['price']}'),
                  pw.Text('${item['total']}'),
                ],
              )),
              pw.Divider(),
              
              // الإجمالي
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'الإجمالي',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '$total',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  /// طباعة تقرير
  Future<void> printReport({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
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
              pw.Text('تاريخ الطباعة: ${DateTime.now().toString().split('.')[0]}'),
              pw.SizedBox(height: 20),
              
              // الجدول
              pw.TableHelper.fromTextArray(
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

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  /// معاينة قبل الطباعة
  Future<void> previewPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  /// طباعة عبر Bluetooth (يتطلب مكتبة إضافية)
  Future<void> printViaBluetooth(Uint8List data) async {
    // TODO: تطبيق الطباعة عبر Bluetooth
    // يمكن استخدام مكتبة مثل blue_thermal_printer
    throw UnimplementedError('الطباعة عبر Bluetooth غير مطبقة بعد');
  }
}
