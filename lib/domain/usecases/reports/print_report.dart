/// حالة استخدام طباعة التقارير
/// تجهز التقارير للطباعة وتستخدم PrintService
library;

import '../../repositories/statistics_repository.dart';
import '../../../core/services/print_service.dart';
import '../../../core/services/export_service.dart';
import '../base/base_usecase.dart';

/// حالة استخدام طباعة التقارير
class PrintReport implements UseCase<void, PrintReportParams> {
  PrintReport({
    required this.statsRepo,
    required this.printService,
    required this.exportService,
  });
  final StatisticsRepository statsRepo;
  final PrintService printService;
  final ExportService exportService;

  @override
  Future<void> call(PrintReportParams params) async {
    try {
      // جلب البيانات حسب نوع التقرير
      Map<String, dynamic> reportData;

      switch (params.reportType) {
        case 'daily':
          final stats = await statsRepo.getDaily(
            params.date ?? DateTime.now().toIso8601String().split('T')[0],
          );
          reportData = {
            'title': 'التقرير اليومي',
            'date':
                params.date ?? DateTime.now().toIso8601String().split('T')[0],
            'data': stats?.toJson() ?? {},
          };
          break;

        case 'monthly':
          final now = DateTime.now();
          final year = params.year ?? now.year;
          final month = params.month ?? now.month;
          final stats = await statsRepo.getMonthly(year, month);
          reportData = {
            'title': 'التقرير الشهري',
            'period': '$month/$year',
            'data': stats.map((s) => s.toJson()).toList(),
          };
          break;

        case 'weekly':
          final stats = params.customData ?? [];
          reportData = {
            'title': 'التقرير الأسبوعي',
            'period': '${params.startDate} - ${params.endDate}',
            'data': stats,
          };
          break;

        case 'yearly':
          final stats = params.customData ?? [];
          reportData = {
            'title': 'التقرير السنوي',
            'period': '${params.year}',
            'data': stats,
          };
          break;

        case 'custom':
          final stats = params.customData ?? [];
          reportData = {
            'title': 'تقرير مخصص',
            'period': '${params.startDate} - ${params.endDate}',
            'data': stats,
          };
          break;

        default:
          throw ArgumentError('نوع التقرير غير مدعوم: ${params.reportType}');
      }

      // إنشاء ملف PDF
      final pdfPath = await exportService.exportToPDF(
        title: reportData['title'],
        headers: _getReportHeaders(params.reportType),
        data: _formatReportData(reportData['data']),
      );

      // طباعة الملف
      await printService.printPdf(pdfPath);
    } catch (e) {
      throw Exception('فشلت طباعة التقرير: $e');
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
      default:
        return ['البند', 'القيمة'];
    }
  }

  List<List<dynamic>> _formatReportData(data) {
    if (data is Map) {
      // تحويل البيانات اليومية
      return [
        ['إجمالي المبيعات', data['totalSales'] ?? 0],
        ['إجمالي المشتريات', data['totalPurchases'] ?? 0],
        ['إجمالي المصروفات', data['totalExpenses'] ?? 0],
        ['صافي الربح', data['netProfit'] ?? 0],
        ['الرصيد النقدي', data['cashBalance'] ?? 0],
      ];
    } else if (data is List) {
      // تحويل البيانات الشهرية
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
}

/// معاملات طباعة التقرير
class PrintReportParams {
  const PrintReportParams({
    required this.reportType,
    this.date,
    this.year,
    this.month,
    this.startDate,
    this.endDate,
    this.customData,
  });
  final String reportType;
  final String? date;
  final int? year;
  final int? month;
  final String? startDate;
  final String? endDate;
  final List<dynamic>? customData;
}
