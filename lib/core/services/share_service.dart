/// خدمة المشاركة
/// تدير مشاركة النصوص والملفات عبر التطبيقات الأخرى

import 'package:share_plus/share_plus.dart';

/// خدمة المشاركة
class ShareService {
  /// مشاركة نص
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(
      text,
      subject: subject,
    );
  }

  /// مشاركة ملف واحد
  Future<void> shareFile(String filePath, {String? subject, String? text}) async {
    final file = XFile(filePath);
    await Share.shareXFiles(
      [file],
      subject: subject,
      text: text,
    );
  }

  /// مشاركة عدة ملفات
  Future<void> shareFiles(List<String> filePaths, {String? subject, String? text}) async {
    final files = filePaths.map((path) => XFile(path)).toList();
    await Share.shareXFiles(
      files,
      subject: subject,
      text: text,
    );
  }
}
