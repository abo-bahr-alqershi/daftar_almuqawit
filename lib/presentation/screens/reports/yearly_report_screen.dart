import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../blocs/statistics/reports_bloc.dart';
import '../../blocs/statistics/reports_event.dart';
import '../../blocs/statistics/reports_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import 'widgets/profit_card.dart';
import 'widgets/chart_widget.dart';
import 'widgets/export_options.dart';

class YearlyReportScreen extends StatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  State<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends State<YearlyReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
      GenerateYearlyReportEvent(_selectedYear),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildModernAppBar(topPadding),
                SliverToBoxAdapter(
                  child: BlocConsumer<ReportsBloc, ReportsState>(
                    listener: (context, state) {
                      if (state is ReportsSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      } else if (state is ReportsError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is ReportsLoading) {
                        return _buildShimmerLoading();
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildYearPicker(),
                            const SizedBox(height: 24),
                            _buildProfitCard(state.reportData),
                            const SizedBox(height: 24),
                            _buildDetailedStats(state.reportData),
                            const SizedBox(height: 24),
                            _buildMonthlySalesChart(state.reportData),
                            const SizedBox(height: 24),
                            _buildMonthlyComparison(state.reportData),
                            const SizedBox(height: 32),
                          ],
                        );
                      }

                      return _buildShimmerLoading();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 400,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.success.withOpacity(0.08),
              AppColors.info.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(double topPadding) {
    final opacity = (_scrollOffset / 140).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background.withOpacity(opacity),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      actions: [
        BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            if (state is ReportsLoaded) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded,
                        color: AppColors.success, size: 20),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _handleExport(ExportType.share, state.reportData);
                    },
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 16, top: topPadding),
        title: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'التقرير السنوي',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        background: Container(
          padding: EdgeInsets.only(top: topPadding + 60, right: 20, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: 1 - opacity,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'التقرير السنوي',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearPicker() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
        ),
      ),
      child: InkWell(
        onTap: _selectYear,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.1),
                      AppColors.info.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.success,
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
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_selectedYear',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

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

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ProfitCard(
          totalProfit: netProfit,
          grossProfit: grossProfit,
          netProfit: netProfit,
          profitMargin: profitMargin,
          period: 'سنة $_selectedYear',
        ),
      ),
    );
  }

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

    if (monthlyStats.isNotEmpty) {
      cashBalance = (monthlyStats.last['cashBalance'] as num?)?.toDouble() ?? 0.0;
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإحصائيات التفصيلية',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'المبيعات',
                    value: Formatters.formatCurrency(totalSales),
                    icon: Icons.trending_up_rounded,
                    color: AppColors.sales,
                    delay: 400,
                    controller: _animationController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'المشتريات',
                    value: Formatters.formatCurrency(totalPurchases),
                    icon: Icons.shopping_cart_rounded,
                    color: AppColors.purchases,
                    delay: 450,
                    controller: _animationController,
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
                    value: Formatters.formatCurrency(totalExpenses),
                    icon: Icons.payment_rounded,
                    color: AppColors.expense,
                    delay: 500,
                    controller: _animationController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'الرصيد النقدي',
                    value: Formatters.formatCurrency(cashBalance),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.info,
                    delay: 550,
                    controller: _animationController,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySalesChart(Map<String, dynamic> data) {
    final monthlyStats = data['monthlyStatistics'] as List<dynamic>? ?? [];

    if (monthlyStats.isEmpty) return const SizedBox.shrink();

    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final chartData = <ChartDataPoint>[];

    for (int i = 0; i < monthlyStats.length && i < 12; i++) {
      final month = monthlyStats[i];
      final sales = (month['totalSales'] as num?)?.toDouble() ?? 0.0;
      chartData.add(
        ChartDataPoint(
          label: months[i],
          value: sales,
          color: AppColors.success,
        ),
      );
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المبيعات الشهرية',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            SimpleTrendChart(
              title: 'مبيعات كل شهر',
              data: chartData,
              primaryColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparison(Map<String, dynamic> data) {
    final monthlyStats = data['monthlyStatistics'] as List<dynamic>? ?? [];

    if (monthlyStats.isEmpty) return const SizedBox.shrink();

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

    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مقارنة الأشهر',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ComparisonCard(
                    title: 'أفضل شهر',
                    month: months[bestMonth],
                    value: Formatters.formatCurrency(maxSales),
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ComparisonCard(
                    title: 'أضعف شهر',
                    month: months[worstMonth],
                    value: Formatters.formatCurrency(minSales),
                    icon: Icons.trending_down_rounded,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectYear() async {
    await showDialog(
      context: context,
      builder: (context) => _YearPickerDialog(
        initialYear: _selectedYear,
        onConfirm: (year) {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedYear = year;
          });
          _loadReport();
        },
      ),
    );
  }

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
          SnackBar(
            content: const Text('هذه الميزة قيد التطوير'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;
  final AnimationController controller;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            (delay / 1200).clamp(0.0, 1.0),
            ((delay + 300) / 1200).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ريال',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            month,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

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
      textDirection: ui.TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'اختر السنة',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
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
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                      )
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
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
            child: Text(
              'إلغاء',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onConfirm(_selectedYear);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'تأكيد',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
