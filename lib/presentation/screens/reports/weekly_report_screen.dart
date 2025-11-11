/// شاشة التقرير الأسبوعي
/// تعرض تقرير مفصل عن أسبوع محدد

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

/// شاشة التقرير الأسبوعي
class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  DateTime _selectedWeekStart = DateTime.now();
  DateTime _selectedWeekEnd = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('d MMMM', 'ar');

  @override
  void initState() {
    super.initState();
    _calculateWeekRange();
    _loadReport();
  }

  /// حساب نطاق الأسبوع
  void _calculateWeekRange() {
    final now = DateTime.now();
    final weekday = now.weekday;
    // السبت هو أول يوم في الأسبوع (6 في DateTime)
    final startOfWeek = now.subtract(Duration(days: (weekday == 7 ? 0 : weekday + 1)));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    setState(() {
      _selectedWeekStart = startOfWeek;
      _selectedWeekEnd = endOfWeek;
    });
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
      GenerateWeeklyReportEvent(
        startDate: _dateFormat.format(_selectedWeekStart),
        endDate: _dateFormat.format(_selectedWeekEnd),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            'التقرير الأسبوعي',
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
                      // منتقي الأسبوع
                      _buildWeekPicker(),
                      
                      const SizedBox(height: 24),
                      
                      // بطاقة الربح
                      _buildProfitCard(state.reportData),
                      
                      const SizedBox(height: 24),
                      
                      // الإحصائيات التفصيلية
                      _buildDetailedStats(state.reportData),
                      
                      const SizedBox(height: 24),
                      
                      // مقارنة الأيام
                      _buildDailyComparison(state.reportData),
                      
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
  }

  /// بناء منتقي الأسبوع
  Widget _buildWeekPicker() {
    return InkWell(
      onTap: _selectWeek,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.date_range,
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
                    'الفترة المحددة',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_displayFormat.format(_selectedWeekStart)} - ${_displayFormat.format(_selectedWeekEnd)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة الربح
  Widget _buildProfitCard(Map<String, dynamic> data) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;
    
    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];
    
    for (var day in dailyStats) {
      totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }
    
    final grossProfit = totalSales - totalPurchases;
    final netProfit = grossProfit - totalExpenses;
    final profitMargin = totalSales > 0 ? (netProfit / totalSales * 100) : 0.0;
    
    return ProfitCard(
      totalProfit: netProfit,
      grossProfit: grossProfit,
      netProfit: netProfit,
      profitMargin: profitMargin,
      period: '${_displayFormat.format(_selectedWeekStart)} - ${_displayFormat.format(_selectedWeekEnd)}',
      showDetails: true,
    );
  }

  /// بناء الإحصائيات التفصيلية
  Widget _buildDetailedStats(Map<String, dynamic> data) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;
    double cashBalance = 0.0;
    
    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];
    
    for (var day in dailyStats) {
      totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }
    
    // آخر رصيد في الأسبوع
    if (dailyStats.isNotEmpty) {
      cashBalance = (dailyStats.last['cashBalance'] as num?)?.toDouble() ?? 0.0;
    }
    
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
                value: totalSales.toStringAsFixed(2),
                subtitle: 'ريال',
                icon: Icons.trending_up,
                color: AppColors.sales,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'المشتريات',
                value: totalPurchases.toStringAsFixed(2),
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
                value: totalExpenses.toStringAsFixed(2),
                subtitle: 'ريال',
                icon: Icons.payment,
                color: AppColors.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'الرصيد النقدي',
                value: cashBalance.toStringAsFixed(2),
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

  /// بناء مقارنة الأيام
  Widget _buildDailyComparison(Map<String, dynamic> data) {
    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];
    
    if (dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    final chartData = <ChartDataPoint>[];
    
    for (int i = 0; i < dailyStats.length && i < 7; i++) {
      final day = dailyStats[i];
      final sales = (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      chartData.add(ChartDataPoint(
        label: days[i],
        value: sales,
        color: AppColors.primary,
      ));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مقارنة المبيعات اليومية',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ChartWidget(
          title: 'المبيعات حسب اليوم',
          chartType: ChartType.bar,
          data: chartData,
          height: 250,
        ),
      ],
    );
  }

  /// بناء المخططات البيانية
  Widget _buildCharts(Map<String, dynamic> data) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;
    
    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];
    
    for (var day in dailyStats) {
      totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }
    
    final chartData = [
      ChartDataPoint(
        label: 'المبيعات',
        value: totalSales,
        color: AppColors.sales,
      ),
      ChartDataPoint(
        label: 'المشتريات',
        value: totalPurchases,
        color: AppColors.purchases,
      ),
      ChartDataPoint(
        label: 'المصروفات',
        value: totalExpenses,
        color: AppColors.expense,
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التوزيع الإجمالي',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ChartWidget(
          title: 'نظرة عامة على المعاملات',
          chartType: ChartType.pie,
          data: chartData,
          height: 250,
        ),
      ],
    );
  }

  /// اختيار أسبوع
  Future<void> _selectWeek() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedWeekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnDark,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final weekday = picked.weekday;
      final startOfWeek = picked.subtract(Duration(days: (weekday == 7 ? 0 : weekday + 1)));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      setState(() {
        _selectedWeekStart = startOfWeek;
        _selectedWeekEnd = endOfWeek;
      });
      _loadReport();
    }
  }

  /// معالجة التصدير
  void _handleExport(ExportType type, Map<String, dynamic> data) {
    switch (type) {
      case ExportType.print:
        context.read<ReportsBloc>().add(
          PrintReportEvent('weekly', data),
        );
        break;
      case ExportType.share:
        context.read<ReportsBloc>().add(
          ShareReportEvent('weekly', data),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذه الميزة قيد التطوير'),
          ),
        );
    }
  }
}

/// بطاقة إحصائية
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  color: color.withOpacity(0.1),
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
}
