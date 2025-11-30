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

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  DateTime _selectedWeekStart = DateTime.now();
  DateTime _selectedWeekEnd = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('d MMMM', 'ar');

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

    _calculateWeekRange();
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

  void _calculateWeekRange() {
    final now = DateTime.now();
    // نجعل الأسبوع عبارة عن 7 أيام متتالية تنتهي باليوم الحالي
    final endOfWeek = DateTime(now.year, now.month, now.day);
    final startOfWeek = endOfWeek.subtract(const Duration(days: 6));

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
                            _buildWeekPicker(),
                            const SizedBox(height: 24),
                            _buildProfitCard(state.reportData),
                            const SizedBox(height: 24),
                            _buildDetailedStats(state.reportData),
                            const SizedBox(height: 24),
                            _buildDailyComparison(state.reportData),
                            const SizedBox(height: 24),
                            _buildCharts(state.reportData),
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
              AppColors.info.withOpacity(0.08),
              AppColors.primary.withOpacity(0.05),
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
                        color: AppColors.info, size: 20),
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
            'التقرير الأسبوعي',
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
                  'التقرير الأسبوعي',
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

  Widget _buildWeekPicker() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
        ),
      ),
      child: InkWell(
        onTap: _selectWeek,
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
                      AppColors.info.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: AppColors.info,
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
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_displayFormat.format(_selectedWeekStart)} - ${_displayFormat.format(_selectedWeekEnd)}',
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

    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];

    for (final day in dailyStats) {
      totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
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
          period: '${_displayFormat.format(_selectedWeekStart)} - ${_displayFormat.format(_selectedWeekEnd)}',
        ),
      ),
    );
  }

  Widget _buildDetailedStats(Map<String, dynamic> data) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;
    double cashBalance = 0.0;

    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];

    for (final day in dailyStats) {
      totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }

    if (dailyStats.isNotEmpty) {
      cashBalance = (dailyStats.last['cashBalance'] as num?)?.toDouble() ?? 0.0;
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

  Widget _buildDailyComparison(Map<String, dynamic> data) {
    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];

    if (dailyStats.isEmpty) return const SizedBox.shrink();

    final days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    final chartData = <ChartDataPoint>[];

    for (var i = 0; i < dailyStats.length && i < 7; i++) {
      final day = dailyStats[i];
      final sales = (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      chartData.add(
        ChartDataPoint(
          label: days[i],
          value: sales,
          color: AppColors.info,
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
              'مقارنة المبيعات اليومية',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            ChartWidget(
              title: 'المبيعات حسب اليوم',
              chartType: ChartType.bar,
              data: chartData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(Map<String, dynamic> data) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;

    final dailyStats = data['dailyStatistics'] as List<dynamic>? ?? [];

    for (final day in dailyStats) {
      totalSales += (day['totalSales'] as num?)?.toDouble() ?? 0.0;
      totalPurchases += (day['totalPurchases'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += (day['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    }

    final chartData = [
      ChartDataPoint(label: 'المبيعات', value: totalSales, color: AppColors.sales),
      ChartDataPoint(label: 'المشتريات', value: totalPurchases, color: AppColors.purchases),
      ChartDataPoint(label: 'المصروفات', value: totalExpenses, color: AppColors.expense),
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
              'التوزيع الإجمالي',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            ChartWidget(
              title: 'نظرة عامة على المعاملات',
              chartType: ChartType.bar,
              data: chartData,
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

  Future<void> _selectWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedWeekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.info,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      HapticFeedback.lightImpact();
      // نحدد الفترة لتكون 7 أيام تنتهي في اليوم المختار
      final endOfWeek = DateTime(picked.year, picked.month, picked.day);
      final startOfWeek = endOfWeek.subtract(const Duration(days: 6));

      setState(() {
        _selectedWeekStart = startOfWeek;
        _selectedWeekEnd = endOfWeek;
      });
      _loadReport();
    }
  }

  void _handleExport(ExportType type, Map<String, dynamic> data) {
    final startDateString = _dateFormat.format(_selectedWeekStart);
    final endDateString = _dateFormat.format(_selectedWeekEnd);

    switch (type) {
      case ExportType.print:
        context.read<ReportsBloc>().add(
          PrintReportEvent(
            'weekly',
            data,
            startDate: startDateString,
            endDate: endDateString,
            customData: data,
          ),
        );
        break;
      case ExportType.share:
        context.read<ReportsBloc>().add(
          ShareReportEvent(
            'weekly',
            data,
            startDate: startDateString,
            endDate: endDateString,
            customData: data,
          ),
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
