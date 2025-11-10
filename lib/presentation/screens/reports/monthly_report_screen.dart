/// شاشة التقرير الشهري
/// تعرض تقرير مفصل عن شهر محدد

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

/// شاشة التقرير الشهري
class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'ar');

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
      GenerateMonthlyReportEvent(_selectedYear, _selectedMonth),
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
            'التقرير الشهري',
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
                      // منتقي الشهر
                      _buildMonthPicker(),
                      
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
                      
                      // أداء المبيعات الشهري
                      _buildMonthlyPerformance(state.reportData),
                      
                      const SizedBox(height: 24),
                      
                      // الأكثر مبيعاً والأكثر شراءً
                      _buildTopItems(state.reportData),
                      
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

  /// بناء منتقي الشهر
  Widget _buildMonthPicker() {
    return InkWell(
      onTap: _selectMonth,
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
                Icons.calendar_month,
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
                    'الشهر المحدد',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _monthFormat.format(DateTime(_selectedYear, _selectedMonth)),
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
    
    final statistics = data['statistics'] as List<dynamic>? ?? [];
    
    for (var stat in statistics) {
      totalSales += (stat['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (stat['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (stat['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }
    
    final grossProfit = totalSales - totalPurchases;
    final netProfit = grossProfit - totalExpenses;
    final profitMargin = totalSales > 0 ? (netProfit / totalSales * 100) : 0.0;
    
    return ProfitCard(
      totalProfit: netProfit,
      grossProfit: grossProfit,
      netProfit: netProfit,
      profitMargin: profitMargin,
      period: _monthFormat.format(DateTime(_selectedYear, _selectedMonth)),
      showDetails: true,
    );
  }

  /// بناء الإحصائيات التفصيلية
  Widget _buildDetailedStats(Map<String, dynamic> data) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;
    double cashBalance = 0.0;
    
    final statistics = data['statistics'] as List<dynamic>? ?? [];
    
    for (var stat in statistics) {
      totalSales += (stat['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (stat['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (stat['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }
    
    // آخر رصيد في الشهر
    if (statistics.isNotEmpty) {
      cashBalance = (statistics.last['cashBalance'] as num?)?.toDouble() ?? 0.0;
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

  /// بناء المخططات البيانية
  Widget _buildCharts(Map<String, dynamic> data) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;
    
    final statistics = data['statistics'] as List<dynamic>? ?? [];
    
    for (var stat in statistics) {
      totalSales += (stat['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (stat['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (stat['totalExpenses'] as num?)?.toDouble() ?? 0.0;
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
    
    return ChartWidget(
      title: 'نظرة عامة على المعاملات',
      chartType: ChartType.pie,
      data: chartData,
      height: 250,
    );
  }

  /// بناء أداء المبيعات الشهري
  Widget _buildMonthlyPerformance(Map<String, dynamic> data) {
    final statistics = data['statistics'] as List<dynamic>? ?? [];
    
    if (statistics.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final chartData = <ChartDataPoint>[];
    
    for (var stat in statistics) {
      final date = stat['date'] as String? ?? '';
      final sales = (stat['totalSales'] as num?)?.toDouble() ?? 0.0;
      
      if (date.isNotEmpty) {
        final day = DateTime.parse(date).day.toString();
        chartData.add(ChartDataPoint(
          label: day,
          value: sales,
          color: AppColors.primary,
        ));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أداء المبيعات اليومي',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ChartWidget(
          title: 'المبيعات حسب اليوم',
          chartType: ChartType.line,
          data: chartData,
          height: 250,
        ),
      ],
    );
  }

  /// بناء الأكثر مبيعاً والأكثر شراءً
  Widget _buildTopItems(Map<String, dynamic> data) {
    final topSelling = data['topSellingItems'] as List<dynamic>? ?? [];
    final topPurchasing = data['topPurchasingItems'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأصناف الأكثر مبيعاً وشراءً',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (topSelling.isNotEmpty)
          _TopItemsCard(
            title: 'الأكثر مبيعاً',
            items: topSelling,
            icon: Icons.star,
            color: AppColors.sales,
          ),
        
        if (topSelling.isNotEmpty && topPurchasing.isNotEmpty)
          const SizedBox(height: 12),
        
        if (topPurchasing.isNotEmpty)
          _TopItemsCard(
            title: 'الأكثر شراءً',
            items: topPurchasing,
            icon: Icons.shopping_bag,
            color: AppColors.purchases,
          ),
        
        if (topSelling.isEmpty && topPurchasing.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                'لا توجد بيانات متاحة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// اختيار شهر
  Future<void> _selectMonth() async {
    await showDialog(
      context: context,
      builder: (context) {
        return _MonthPickerDialog(
          initialYear: _selectedYear,
          initialMonth: _selectedMonth,
          onConfirm: (year, month) {
            setState(() {
              _selectedYear = year;
              _selectedMonth = month;
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
          PrintReportEvent('monthly', data),
        );
        break;
      case ExportType.share:
        context.read<ReportsBloc>().add(
          ShareReportEvent('monthly', data),
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

/// بطاقة الأصناف الأكثر
class _TopItemsCard extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final IconData icon;
  final Color color;

  const _TopItemsCard({
    required this.title,
    required this.items,
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
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(5).map((item) {
            final name = item['name'] as String? ?? 'غير محدد';
            final quantity = item['quantity'] as num? ?? 0;
            final total = (item['total'] as num?)?.toDouble() ?? 0.0;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$quantity',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${total.toStringAsFixed(2)} ريال',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// حوار اختيار الشهر
class _MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final Function(int year, int month) onConfirm;

  const _MonthPickerDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.onConfirm,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  final List<String> _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('اختر الشهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // اختيار السنة
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  onPressed: () {
                    setState(() {
                      _selectedYear--;
                    });
                  },
                ),
                Text(
                  '$_selectedYear',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () {
                    if (_selectedYear < DateTime.now().year) {
                      setState(() {
                        _selectedYear++;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // شبكة الأشهر
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _selectedMonth && _selectedYear == widget.initialYear;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMonth = month;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _monthNames[index],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onConfirm(_selectedYear, _selectedMonth);
              Navigator.pop(context);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
