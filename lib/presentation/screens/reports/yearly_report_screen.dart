/// شاشة التقرير السنوي
/// تعرض تقرير مفصل عن سنة محددة

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

/// شاشة التقرير السنوي
class YearlyReportScreen extends StatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  State<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends State<YearlyReportScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
      GenerateYearlyReportEvent(_selectedYear),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            'التقرير السنوي',
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
                  backgroundColor: AppColors.error,
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
                      // منتقي السنة
                      _buildYearPicker(),
                      
                      const SizedBox(height: 24),
                      
                      // بطاقة الربح
                      _buildProfitCard(state.reportData),
                      
                      const SizedBox(height: 24),
                      
                      // الإحصائيات التفصيلية
                      _buildDetailedStats(state.reportData),
                      
                      const SizedBox(height: 24),
                      
                      // مخطط المبيعات الشهري
                      _buildMonthlySalesChart(state.reportData),
                      
                      const SizedBox(height: 24),
                      
                      // مقارنة الأشهر
                      _buildMonthlyComparison(state.reportData),
                      
                      const SizedBox(height: 24),
                      
                      // ملخص سنوي
                      _buildYearlySummary(state.reportData),
                      
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

  /// بناء منتقي السنة
  Widget _buildYearPicker() {
    return InkWell(
      onTap: _selectYear,
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
                Icons.calendar_today_outlined,
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
                    'السنة المحددة',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_selectedYear',
                    style: AppTextStyles.h2.copyWith(
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
    
    final monthlyStats = data['monthlyStatistics'] as List<dynamic>? ?? [];
    
    for (var month in monthlyStats) {
      totalSales += (month['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (month['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (month['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }
    
    final grossProfit = totalSales - totalPurchases;
    final netProfit = grossProfit - totalExpenses;
    final profitMargin = totalSales > 0 ? (netProfit / totalSales * 100) : 0.0;
    
    return ProfitCard(
      totalProfit: netProfit,
      grossProfit: grossProfit,
      netProfit: netProfit,
      profitMargin: profitMargin,
      period: 'سنة $_selectedYear',
      showDetails: true,
    );
  }

  /// بناء الإحصائيات التفصيلية
  Widget _buildDetailedStats(Map<String, dynamic> data) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;
    double cashBalance = 0.0;
    
    final monthlyStats = data['monthlyStatistics'] as List<dynamic>? ?? [];
    
    for (var month in monthlyStats) {
      totalSales += (month['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (month['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (month['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }
    
    // آخر رصيد في السنة
    if (monthlyStats.isNotEmpty) {
      cashBalance = (monthlyStats.last['cashBalance'] as num?)?.toDouble() ?? 0.0;
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

  /// بناء مخطط المبيعات الشهري
  Widget _buildMonthlySalesChart(Map<String, dynamic> data) {
    final monthlyStats = data['monthlyStatistics'] as List<dynamic>? ?? [];
    
    if (monthlyStats.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final chartData = <ChartDataPoint>[];
    
    for (int i = 0; i < monthlyStats.length && i < 12; i++) {
      final month = monthlyStats[i];
      final sales = (month['totalSales'] as num?)?.toDouble() ?? 0.0;
      chartData.add(ChartDataPoint(
        label: months[i],
        value: sales,
        color: AppColors.primary,
      ));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المبيعات الشهرية',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ChartWidget(
          title: 'مبيعات كل شهر',
          chartType: ChartType.line,
          data: chartData,
          height: 250,
        ),
      ],
    );
  }

  /// بناء مقارنة الأشهر
  Widget _buildMonthlyComparison(Map<String, dynamic> data) {
    final monthlyStats = data['monthlyStatistics'] as List<dynamic>? ?? [];
    
    if (monthlyStats.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // العثور على أفضل وأسوأ شهر
    double maxSales = 0.0;
    double minSales = double.infinity;
    int bestMonth = 0;
    int worstMonth = 0;
    
    for (int i = 0; i < monthlyStats.length; i++) {
      final sales = (monthlyStats[i]['totalSales'] as num?)?.toDouble() ?? 0.0;
      if (sales > maxSales) {
        maxSales = sales;
        bestMonth = i;
      }
      if (sales < minSales) {
        minSales = sales;
        worstMonth = i;
      }
    }
    
    final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مقارنة الأشهر',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _ComparisonCard(
                title: 'أفضل شهر',
                month: months[bestMonth],
                value: maxSales.toStringAsFixed(2),
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ComparisonCard(
                title: 'أضعف شهر',
                month: months[worstMonth],
                value: minSales.toStringAsFixed(2),
                icon: Icons.trending_down,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// بناء ملخص سنوي
  Widget _buildYearlySummary(Map<String, dynamic> data) {
    final monthlyStats = data['monthlyStatistics'] as List<dynamic>? ?? [];
    
    if (monthlyStats.isEmpty) {
      return const SizedBox.shrink();
    }
    
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;
    
    for (var month in monthlyStats) {
      totalSales += (month['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (month['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (month['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }
    
    final avgMonthlySales = totalSales / monthlyStats.length;
    final avgMonthlyPurchases = totalPurchases / monthlyStats.length;
    final avgMonthlyExpenses = totalExpenses / monthlyStats.length;
    
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
              const Icon(
                Icons.insights,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'الملخص السنوي',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _SummaryRow(
            label: 'متوسط المبيعات الشهري',
            value: '${avgMonthlySales.toStringAsFixed(2)} ريال',
            color: AppColors.sales,
          ),
          
          const SizedBox(height: 8),
          
          _SummaryRow(
            label: 'متوسط المشتريات الشهري',
            value: '${avgMonthlyPurchases.toStringAsFixed(2)} ريال',
            color: AppColors.purchases,
          ),
          
          const SizedBox(height: 8),
          
          _SummaryRow(
            label: 'متوسط المصروفات الشهري',
            value: '${avgMonthlyExpenses.toStringAsFixed(2)} ريال',
            color: AppColors.expense,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم تحليل ${monthlyStats.length} شهر من سنة $_selectedYear',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// اختيار سنة
  Future<void> _selectYear() async {
    await showDialog(
      context: context,
      builder: (context) {
        return _YearPickerDialog(
          initialYear: _selectedYear,
          onConfirm: (year) {
            setState(() {
              _selectedYear = year;
            });
            _loadReport();
          },
        );
      },
    );
  }

  /// معالجة التصدير
  void _handleExport(ExportType type, Map<String, dynamic> data) {
    switch (type) {
      case ExportType.print:
        context.read<ReportsBloc>().add(
          PrintReportEvent('yearly', data),
        );
        break;
      case ExportType.share:
        context.read<ReportsBloc>().add(
          ShareReportEvent('yearly', data),
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

/// بطاقة المقارنة
class _ComparisonCard extends StatelessWidget {
  final String title;
  final String month;
  final String value;
  final IconData icon;
  final Color color;

  const _ComparisonCard({
    required this.title,
    required this.month,
    required this.value,
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
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            month,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value ريال',
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// صف الملخص
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// حوار اختيار السنة
class _YearPickerDialog extends StatefulWidget {
  final int initialYear;
  final Function(int year) onConfirm;

  const _YearPickerDialog({
    required this.initialYear,
    required this.onConfirm,
  });

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - 2020 + 1,
      (index) => 2020 + index,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('اختر السنة'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              final isSelected = year == _selectedYear;
              
              return ListTile(
                title: Text(
                  '$year',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedYear = year;
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onConfirm(_selectedYear);
              Navigator.pop(context);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
