/// شاشة التقرير المخصص
/// تعرض تقرير مخصص حسب فترة زمنية وفلاتر محددة
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

/// شاشة التقرير المخصص
class CustomReportScreen extends StatefulWidget {
  const CustomReportScreen({super.key});

  @override
  State<CustomReportScreen> createState() => _CustomReportScreenState();
}

class _CustomReportScreenState extends State<CustomReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('d MMMM yyyy', 'ar');

  // الفلاتر
  bool _showSales = true;
  bool _showPurchases = true;
  bool _showExpenses = true;
  String _sortBy = 'date'; // date, amount
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
      GenerateCustomReportEvent(
        startDate: _dateFormat.format(_startDate),
        endDate: _dateFormat.format(_endDate),
      ),
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
          'التقرير المخصص',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
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
                    // منتقي الفترة
                    _buildDateRangePicker(),

                    const SizedBox(height: 24),

                    // بطاقة الربح
                    _buildProfitCard(state.reportData),

                    const SizedBox(height: 24),

                    // الإحصائيات التفصيلية
                    _buildDetailedStats(state.reportData),

                    const SizedBox(height: 24),

                    // الفلاتر النشطة
                    _buildActiveFilters(),

                    const SizedBox(height: 24),

                    // المخططات البيانية
                    _buildCharts(state.reportData),

                    const SizedBox(height: 24),

                    // قائمة المعاملات
                    _buildTransactionsList(state.reportData),

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

  /// بناء منتقي الفترة
  Widget _buildDateRangePicker() => InkWell(
    onTap: _selectDateRange,
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
                  '${_displayFormat.format(_startDate)} - ${_displayFormat.format(_endDate)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'المدة: ${_endDate.difference(_startDate).inDays + 1} يوم',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
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
    var totalSales = 0.0;
    var totalPurchases = 0.0;
    var totalExpenses = 0.0;

    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];

    for (final day in dailyStats) {
      if (_showSales) {
        totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      }
      if (_showPurchases) {
        totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      }
      if (_showExpenses) {
        totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
      }
    }

    final grossProfit = totalSales - totalPurchases;
    final netProfit = grossProfit - totalExpenses;
    final profitMargin = totalSales > 0 ? (netProfit / totalSales * 100) : 0.0;

    return ProfitCard(
      totalProfit: netProfit,
      grossProfit: grossProfit,
      netProfit: netProfit,
      profitMargin: profitMargin,
      period:
          '${_displayFormat.format(_startDate)} - ${_displayFormat.format(_endDate)}',
    );
  }

  /// بناء الإحصائيات التفصيلية
  Widget _buildDetailedStats(Map<String, dynamic> data) {
    var totalSales = 0.0;
    var totalPurchases = 0.0;
    var totalExpenses = 0.0;
    var cashBalance = 0.0;

    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];

    for (final day in dailyStats) {
      if (_showSales) {
        totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      }
      if (_showPurchases) {
        totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      }
      if (_showExpenses) {
        totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
      }
    }

    // آخر رصيد في الفترة
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
            if (_showSales)
              Expanded(
                child: _StatCard(
                  title: 'المبيعات',
                  value: totalSales.toStringAsFixed(2),
                  subtitle: 'ريال',
                  icon: Icons.trending_up,
                  color: AppColors.sales,
                ),
              ),
            if (_showSales && _showPurchases) const SizedBox(width: 12),
            if (_showPurchases)
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

        if (_showExpenses) const SizedBox(height: 12),

        if (_showExpenses)
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

  /// بناء الفلاتر النشطة
  Widget _buildActiveFilters() => Container(
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
            const Icon(Icons.tune, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'الفلاتر النشطة',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_showSales)
              _FilterChip(
                label: 'المبيعات',
                color: AppColors.sales,
                onRemove: () {
                  setState(() {
                    _showSales = false;
                  });
                },
              ),
            if (_showPurchases)
              _FilterChip(
                label: 'المشتريات',
                color: AppColors.purchases,
                onRemove: () {
                  setState(() {
                    _showPurchases = false;
                  });
                },
              ),
            if (_showExpenses)
              _FilterChip(
                label: 'المصروفات',
                color: AppColors.expense,
                onRemove: () {
                  setState(() {
                    _showExpenses = false;
                  });
                },
              ),
            _FilterChip(
              label: 'الترتيب: ${_sortBy == "date" ? "التاريخ" : "المبلغ"}',
              color: AppColors.info,
              icon: _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
          ],
        ),
      ],
    ),
  );

  /// بناء المخططات البيانية
  Widget _buildCharts(Map<String, dynamic> data) {
    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];

    if (dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final chartData = <ChartDataPoint>[];

    if (_showSales) {
      var totalSales = 0.0;
      for (final day in dailyStats) {
        totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      }
      chartData.add(
        ChartDataPoint(
          label: 'المبيعات',
          value: totalSales,
          color: AppColors.sales,
        ),
      );
    }

    if (_showPurchases) {
      var totalPurchases = 0.0;
      for (final day in dailyStats) {
        totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      }
      chartData.add(
        ChartDataPoint(
          label: 'المشتريات',
          value: totalPurchases,
          color: AppColors.purchases,
        ),
      );
    }

    if (_showExpenses) {
      var totalExpenses = 0.0;
      for (final day in dailyStats) {
        totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
      }
      chartData.add(
        ChartDataPoint(
          label: 'المصروفات',
          value: totalExpenses,
          color: AppColors.expense,
        ),
      );
    }

    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التوزيع المالي',
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
        ),
      ],
    );
  }

  /// بناء قائمة المعاملات
  Widget _buildTransactionsList(Map<String, dynamic> data) {
    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];

    if (dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    // تطبيق الترتيب
    final sortedStats = List<Map<String, dynamic>>.from(
      dailyStats.map((e) => Map<String, dynamic>.from(e as Map)),
    );

    if (_sortBy == 'date') {
      sortedStats.sort((a, b) {
        final dateA = DateTime.parse(a['date'] as String);
        final dateB = DateTime.parse(b['date'] as String);
        return _sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    } else {
      sortedStats.sort((a, b) {
        final totalA = (a['totalSales'] as num?)?.toDouble() ?? 0.0;
        final totalB = (b['totalSales'] as num?)?.toDouble() ?? 0.0;
        return _sortAscending
            ? totalA.compareTo(totalB)
            : totalB.compareTo(totalA);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل المعاملات',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        ...sortedStats.map((day) {
          final date = DateTime.parse(day['date'] as String);
          final sales = (day['totalSales'] as num?)?.toDouble() ?? 0.0;
          final purchases = (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
          final expenses = (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;

          return _TransactionCard(
            date: date,
            sales: sales,
            purchases: purchases,
            expenses: expenses,
            showSales: _showSales,
            showPurchases: _showPurchases,
            showExpenses: _showExpenses,
          );
        }),
      ],
    );
  }

  /// اختيار نطاق التاريخ
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
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

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReport();
    }
  }

  /// عرض حوار الفلتر
  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        showSales: _showSales,
        showPurchases: _showPurchases,
        showExpenses: _showExpenses,
        sortBy: _sortBy,
        sortAscending: _sortAscending,
        onApply:
            (showSales, showPurchases, showExpenses, sortBy, sortAscending) {
              setState(() {
                _showSales = showSales;
                _showPurchases = showPurchases;
                _showExpenses = showExpenses;
                _sortBy = sortBy;
                _sortAscending = sortAscending;
              });
            },
      ),
    );
  }

  /// معالجة التصدير
  void _handleExport(ExportType type, Map<String, dynamic> data) {
    switch (type) {
      case ExportType.print:
        context.read<ReportsBloc>().add(PrintReportEvent('custom', data));
        break;
      case ExportType.share:
        context.read<ReportsBloc>().add(ShareReportEvent('custom', data));
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

/// رقاقة الفلتر
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    this.icon,
    this.onRemove,
  });
  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onRemove != null) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: color),
          ),
        ],
      ],
    ),
  );
}

/// بطاقة المعاملة
class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.date,
    required this.sales,
    required this.purchases,
    required this.expenses,
    required this.showSales,
    required this.showPurchases,
    required this.showExpenses,
  });
  final DateTime date;
  final double sales;
  final double purchases;
  final double expenses;
  final bool showSales;
  final bool showPurchases;
  final bool showExpenses;

  @override
  Widget build(BuildContext context) {
    final displayFormat = DateFormat('EEEE، d MMMM yyyy', 'ar');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayFormat.format(date),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (showSales)
            _TransactionRow(
              label: 'المبيعات',
              value: sales.toStringAsFixed(2),
              color: AppColors.sales,
            ),

          if (showSales && (showPurchases || showExpenses))
            const SizedBox(height: 8),

          if (showPurchases)
            _TransactionRow(
              label: 'المشتريات',
              value: purchases.toStringAsFixed(2),
              color: AppColors.purchases,
            ),

          if (showPurchases && showExpenses) const SizedBox(height: 8),

          if (showExpenses)
            _TransactionRow(
              label: 'المصروفات',
              value: expenses.toStringAsFixed(2),
              color: AppColors.expense,
            ),
        ],
      ),
    );
  }
}

/// صف المعاملة
class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      Text(
        '$value ريال',
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

/// حوار الفلتر
class _FilterDialog extends StatefulWidget {
  const _FilterDialog({
    required this.showSales,
    required this.showPurchases,
    required this.showExpenses,
    required this.sortBy,
    required this.sortAscending,
    required this.onApply,
  });
  final bool showSales;
  final bool showPurchases;
  final bool showExpenses;
  final String sortBy;
  final bool sortAscending;
  final Function(bool, bool, bool, String, bool) onApply;

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late bool _showSales;
  late bool _showPurchases;
  late bool _showExpenses;
  late String _sortBy;
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    _showSales = widget.showSales;
    _showPurchases = widget.showPurchases;
    _showExpenses = widget.showExpenses;
    _sortBy = widget.sortBy;
    _sortAscending = widget.sortAscending;
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: ui.TextDirection.rtl,
    child: AlertDialog(
      title: const Text('فلترة وترتيب التقرير'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'عرض البيانات',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            CheckboxListTile(
              title: const Text('المبيعات'),
              value: _showSales,
              onChanged: (value) {
                setState(() {
                  _showSales = value ?? false;
                });
              },
            ),

            CheckboxListTile(
              title: const Text('المشتريات'),
              value: _showPurchases,
              onChanged: (value) {
                setState(() {
                  _showPurchases = value ?? false;
                });
              },
            ),

            CheckboxListTile(
              title: const Text('المصروفات'),
              value: _showExpenses,
              onChanged: (value) {
                setState(() {
                  _showExpenses = value ?? false;
                });
              },
            ),

            const Divider(),

            Text(
              'الترتيب',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            RadioListTile<String>(
              title: const Text('حسب التاريخ'),
              value: 'date',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value ?? 'date';
                });
              },
            ),

            RadioListTile<String>(
              title: const Text('حسب المبلغ'),
              value: 'amount',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value ?? 'date';
                });
              },
            ),

            const Divider(),

            SwitchListTile(
              title: const Text('ترتيب تصاعدي'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(
              _showSales,
              _showPurchases,
              _showExpenses,
              _sortBy,
              _sortAscending,
            );
            Navigator.pop(context);
          },
          child: const Text('تطبيق'),
        ),
      ],
    ),
  );
}
