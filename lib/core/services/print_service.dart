// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:printing/printing.dart';

class PrintService {
  Future<void> printPdf(String path) async {
    final file = File(path);
    if (!await file.exists()) return;
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }
}
