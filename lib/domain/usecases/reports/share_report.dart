/// حالة استخدام مشاركة التقارير
/// تصدر التقارير وتشاركها عبر التطبيقات المختلفة
library;

import '../../repositories/statistics_repository.dart';
import '../../../core/services/share_service.dart';
import '../../../core/services/export_service.dart';
import '../base/base_usecase.dart';

/// حالة استخدام مشاركة التقارير
class ShareReport implements UseCase<void, ShareReportParams> {
  ShareReport({
    required this.statsRepo,
    required this.shareService,
    required this.exportService,
  });
  final StatisticsRepository statsRepo;
  final ShareService shareService;
  final ExportService exportService;

  @override
  Future<void> call(ShareReportParams params) async {
    try {
      // جلب البيانات حسب نوع التقرير
      Map<String, dynamic> reportData;

      switch (params.reportType) {
        case 'daily':
          final stats = await statsRepo.getDaily(
            params.date ?? DateTime.now().toIso8601String().split('T')[0],
          );
          reportData = {
            'title':
                'التقرير اليومي - ${params.date ?? DateTime.now().toIso8601String().split('T')[0]}',
            'data': stats?.toJson() ?? {},
          };
          break;

        case 'monthly':
          final now = DateTime.now();
          final year = params.year ?? now.year;
          final month = params.month ?? now.month;
          final stats = await statsRepo.getMonthly(year, month);
          reportData = {
            'title': 'التقرير الشهري - $month/$year',
            'data': stats.map((s) => s.toJson()).toList(),
          };
          break;

        case 'weekly':
          reportData = {
            'title':
                'التقرير الأسبوعي - ${params.startDate} - ${params.endDate}',
            'data': params.customData ?? [],
          };
          break;

        case 'yearly':
          reportData = {
            'title': 'التقرير السنوي - ${params.year}',
            'data': params.customData ?? [],
          };
          break;

        case 'custom':
          reportData = {
            'title': 'تقرير مخصص - ${params.startDate} - ${params.endDate}',
            'data': params.customData ?? [],
          };
          break;

        case 'sales':
          reportData = {
            'title': 'تقرير المبيعات',
            'data': {}, // سيتم ملؤها من sales repository
          };
          break;

        default:
          throw ArgumentError('نوع التقرير غير مدعوم: ${params.reportType}');
      }

      // اختيار التنسيق المناسب
      String filePath;

      switch (params.format) {
        case ShareFormat.excel:
          filePath = await exportService.toExcel(
            reportData['title'],
            title: reportData['title'],
            headers: _getReportHeaders(params.reportType),
            data: _formatReportData(reportData['data']),
          );
          break;

        case ShareFormat.pdf:
          filePath = await exportService.exportToPDF(
            title: reportData['title'],
            headers: _getReportHeaders(params.reportType),
            data: _formatReportData(reportData['data']),
          );
          break;

        case ShareFormat.text:
          // مشاركة كنص
          final text = _formatAsText(reportData);
          await shareService.shareText(text, subject: reportData['title']);
          return;
      }

      // مشاركة الملف
      await shareService.shareFile(
        filePath,
        subject: reportData['title'],
        text: params.message,
      );
    } catch (e) {
      throw Exception('فشلت مشاركة التقرير: $e');
    }
  }

  List<String> _getReportHeaders(String reportType) {
    switch (reportType) {
      case 'daily':
        return ['البند', 'القيمة'];
      case 'monthly':
      case 'weekly':
      case 'yearly':
      case 'custom':
        return ['التاريخ', 'المبيعات', 'المشتريات', 'الأرباح'];
      case 'sales':
        return ['التاريخ', 'العميل', 'الصنف', 'الكمية', 'المبلغ'];
      default:
        return ['البند', 'القيمة'];
    }
  }

  List<List<dynamic>> _formatReportData(data) {
    if (data is Map) {
      return [
        ['إجمالي المبيعات', data['totalSales'] ?? 0],
        ['إجمالي المشتريات', data['totalPurchases'] ?? 0],
        ['إجمالي المصروفات', data['totalExpenses'] ?? 0],
        ['صافي الربح', data['netProfit'] ?? 0],
        ['الرصيد النقدي', data['cashBalance'] ?? 0],
      ];
    } else if (data is List) {
      return data
          .map(
            (item) => [
              item['date'] ?? '',
              item['totalSales'] ?? 0,
              item['totalPurchases'] ?? 0,
              item['netProfit'] ?? 0,
            ],
          )
          .toList();
    }
    return [];
  }

  String _formatAsText(Map<String, dynamic> reportData) {
    final buffer = StringBuffer();
    buffer.writeln('=== ${reportData['title']} ===');
    buffer.writeln();

    final data = reportData['data'];
    if (data is Map) {
      buffer.writeln('إجمالي المبيعات: ${data['totalSales'] ?? 0}');
      buffer.writeln('إجمالي المشتريات: ${data['totalPurchases'] ?? 0}');
      buffer.writeln('إجمالي المصروفات: ${data['totalExpenses'] ?? 0}');
      buffer.writeln('صافي الربح: ${data['netProfit'] ?? 0}');
      buffer.writeln('الرصيد النقدي: ${data['cashBalance'] ?? 0}');
    }

    return buffer.toString();
  }
}

/// تنسيقات المشاركة
enum ShareFormat { pdf, excel, text }

/// معاملات مشاركة التقرير
class ShareReportParams {
  const ShareReportParams({
    required this.reportType,
    required this.format,
    this.date,
    this.year,
    this.month,
    this.message,
    this.startDate,
    this.endDate,
    this.customData,
  });
  final String reportType;
  final ShareFormat format;
  final String? date;
  final int? year;
  final int? month;
  final String? message;
  final String? startDate;
  final String? endDate;
  final List<dynamic>? customData;
}
