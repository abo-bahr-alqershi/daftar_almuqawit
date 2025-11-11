/// شاشة التقرير اليومي
/// تعرض تقرير مفصل عن يوم محدد
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/statistics/reports_bloc.dart';
import '../../blocs/statistics/reports_event.dart';
import '../../blocs/statistics/reports_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import 'widgets/profit_card.dart';
import 'widgets/chart_widget.dart';
import 'widgets/export_options.dart';

/// شاشة التقرير اليومي
class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('EEEE، d MMMM yyyy', 'ar');

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
      GenerateDailyReportEvent(_dateFormat.format(_selectedDate)),
    );
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: ui.TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'التقرير اليومي',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              if (state is ReportsLoaded) {
                return ExportOptions(
                  iconsOnly: true,
                  onExport: (type) => _handleExport(type, state.reportData),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state is ReportsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ReportsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is ReportsError) {
            return Center(
              child: custom_error.AppErrorWidget(
                message: state.message,
                onRetry: _loadReport,
              ),
            );
          }

          if (state is ReportsLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _loadReport(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // منتقي التاريخ
                    _buildDatePicker(),

                    const SizedBox(height: 24),

                    // بطاقة الربح
                    _buildProfitCard(state.reportData),

                    const SizedBox(height: 24),

                    // الإحصائيات التفصيلية
                    _buildDetailedStats(state.reportData),

                    const SizedBox(height: 24),

                    // المخططات البيانية
                    _buildCharts(state.reportData),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const Center(child: LoadingWidget());
        },
      ),
    ),
  );

  /// بناء منتقي التاريخ
  Widget _buildDatePicker() => InkWell(
    onTap: _selectDate,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التاريخ المحدد',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayFormat.format(_selectedDate),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textHint),
        ],
      ),
    ),
  );

  /// بناء بطاقة الربح
  Widget _buildProfitCard(Map<String, dynamic> data) {
    final stats = data['statistics'] as Map<String, dynamic>;
    final grossProfit = (stats['grossProfit'] as num?)?.toDouble() ?? 0.0;
    final netProfit = (stats['netProfit'] as num?)?.toDouble() ?? 0.0;
    final totalSales = (stats['totalSales'] as num?)?.toDouble() ?? 0.0;

    final profitMargin = totalSales > 0 ? (netProfit / totalSales * 100) : 0.0;

    return ProfitCard(
      totalProfit: netProfit,
      grossProfit: grossProfit,
      netProfit: netProfit,
      profitMargin: profitMargin,
      period: _displayFormat.format(_selectedDate),
    );
  }

  /// بناء الإحصائيات التفصيلية
  Widget _buildDetailedStats(Map<String, dynamic> data) {
    final stats = data['statistics'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات التفصيلية',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'المبيعات',
                value: stats['totalSales']?.toString() ?? '0',
                subtitle: 'ريال',
                icon: Icons.trending_up,
                color: AppColors.sales,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'المشتريات',
                value: stats['totalPurchases']?.toString() ?? '0',
                subtitle: 'ريال',
                icon: Icons.shopping_cart,
                color: AppColors.purchases,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'المصروفات',
                value: stats['totalExpenses']?.toString() ?? '0',
                subtitle: 'ريال',
                icon: Icons.payment,
                color: AppColors.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'الرصيد النقدي',
                value: stats['cashBalance']?.toString() ?? '0',
                subtitle: 'ريال',
                icon: Icons.account_balance_wallet,
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// بناء المخططات البيانية
  Widget _buildCharts(Map<String, dynamic> data) {
    final stats = data['statistics'] as Map<String, dynamic>;

    final chartData = [
      ChartDataPoint(
        label: 'المبيعات',
        value: (stats['totalSales'] as num?)?.toDouble() ?? 0.0,
        color: AppColors.sales,
      ),
      ChartDataPoint(
        label: 'المشتريات',
        value: (stats['totalPurchases'] as num?)?.toDouble() ?? 0.0,
        color: AppColors.purchases,
      ),
      ChartDataPoint(
        label: 'المصروفات',
        value: (stats['totalExpenses'] as num?)?.toDouble() ?? 0.0,
        color: AppColors.expense,
      ),
    ];

    return ChartWidget(
      title: 'نظرة عامة على المعاملات',
      chartType: ChartType.bar,
      data: chartData,
    );
  }

  /// اختيار تاريخ
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReport();
    }
  }

  /// معالجة التصدير
  void _handleExport(ExportType type, Map<String, dynamic> data) {
    final dateString = _dateFormat.format(_selectedDate);
    
    switch (type) {
      case ExportType.print:
        context.read<ReportsBloc>().add(
          PrintReportEvent(
            'daily',
            data,
            startDate: dateString,
            endDate: dateString,
            customData: data,
          ),
        );
        break;
      case ExportType.share:
        context.read<ReportsBloc>().add(
          ShareReportEvent(
            'daily',
            data,
            startDate: dateString,
            endDate: dateString,
            customData: data,
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('هذه الميزة قيد التطوير')));
    }
  }
}

/// بطاقة إحصائية
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
