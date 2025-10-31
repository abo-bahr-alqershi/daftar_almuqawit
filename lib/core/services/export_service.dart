// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ExportService {
  Future<String> toExcel(String dateRange) async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    sheet.appendRow(['دفتر المقاوت - تقرير إكسل']);
    sheet.appendRow(['النطاق الزمني', dateRange]);
    sheet.appendRow(['تاريخ التصدير', DateTime.now().toIso8601String()]);
    sheet.appendRow([]);
    sheet.appendRow(['ملاحظة', 'يمكن لاحقاً ملء هذا الملف ببيانات فعلية من المستودعات']);

    final bytes = excel.encode()!;
    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, 'export_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }
}
