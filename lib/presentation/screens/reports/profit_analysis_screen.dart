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
import 'widgets/chart_widget.dart';

class ProfitAnalysisScreen extends StatefulWidget {
  const ProfitAnalysisScreen({super.key});

  @override
  State<ProfitAnalysisScreen> createState() => _ProfitAnalysisScreenState();
}

class _ProfitAnalysisScreenState extends State<ProfitAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 29));
  DateTime _endDate = DateTime.now();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('d MMMM yyyy', 'ar');

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
          GenerateCustomReportEvent(
            startDate: _dateFormat.format(_startDate),
            endDate: _dateFormat.format(_endDate),
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
                      if (state is ReportsError) {
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
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: LoadingWidget(),
                        );
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
                        final data = state.reportData;
                        final dailyStats =
                            data['dailyStatistics'] as List<dynamic>? ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildDateRangePicker(),
                            const SizedBox(height: 24),
                            _buildSummaryCard(dailyStats),
                            const SizedBox(height: 24),
                            _buildKeyInsights(dailyStats),
                            const SizedBox(height: 24),
                            _buildProfitTrendChart(dailyStats),
                            const SizedBox(height: 32),
                          ],
                        );
                      }

                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: LoadingWidget(),
                      );
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
              AppColors.sales.withOpacity(0.08),
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
      actions: const [SizedBox(width: 8)],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 16, top: topPadding),
        title: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'تحليل الربح',
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
                  'تحليل الربح',
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

  Widget _buildDateRangePicker() {
    final duration = _endDate.difference(_startDate).inDays + 1;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
        ),
      ),
      child: InkWell(
        onTap: _selectDateRange,
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
                      AppColors.sales.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: AppColors.sales,
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
                      '${_displayFormat.format(_startDate)} - ${_displayFormat.format(_endDate)}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المدة: $duration يوم',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                        fontSize: 11,
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

  Widget _buildSummaryCard(List<dynamic> dailyStats) {
    double totalSales = 0.0;
    double totalPurchases = 0.0;
    double totalExpenses = 0.0;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withOpacity(0.15)),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.sales, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صافي الربح للفترة',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(netProfit),
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: profitMargin >= 0
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.danger.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profitMargin >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 16,
                          color: profitMargin >= 0
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${profitMargin.toStringAsFixed(1)}%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: profitMargin >= 0
                                ? AppColors.success
                                : AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: 'المبيعات',
                      value: Formatters.formatCurrency(totalSales),
                      color: AppColors.sales,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryItem(
                      label: 'المشتريات',
                      value: Formatters.formatCurrency(totalPurchases),
                      color: AppColors.purchases,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: 'المصروفات',
                      value: Formatters.formatCurrency(totalExpenses),
                      color: AppColors.expense,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryItem(
                      label: 'الربح الإجمالي',
                      value: Formatters.formatCurrency(grossProfit),
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyInsights(List<dynamic> dailyStats) {
    if (dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxProfit = -double.infinity;
    double minProfit = double.infinity;
    Map<String, dynamic>? bestDay;
    Map<String, dynamic>? worstDay;

    double totalNetProfit = 0.0;

    for (final day in dailyStats) {
      final net = (day['netProfit'] as num?)?.toDouble() ?? 0.0;
      totalNetProfit += net;

      if (net > maxProfit) {
        maxProfit = net;
        bestDay = day as Map<String, dynamic>;
      }
      if (net < minProfit) {
        minProfit = net;
        worstDay = day as Map<String, dynamic>;
      }
    }

    final avgProfit = dailyStats.isNotEmpty
        ? totalNetProfit / dailyStats.length
        : 0.0;

    String formatDay(Map<String, dynamic>? day) {
      if (day == null) return '-';
      final dateStr = day['date'] as String? ?? '';
      if (dateStr.isEmpty) return '-';
      try {
        final date = DateTime.parse(dateStr);
        return _displayFormat.format(date);
      } catch (_) {
        return dateStr;
      }
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
              'أهم الملاحظات',
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
                  child: _InsightCard(
                    title: 'أفضل يوم ربحاً',
                    subtitle: formatDay(bestDay),
                    value: Formatters.formatCurrency(maxProfit.isFinite ? maxProfit : 0),
                    icon: Icons.thumb_up_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightCard(
                    title: 'أضعف يوم ربحاً',
                    subtitle: formatDay(worstDay),
                    value: Formatters.formatCurrency(minProfit.isFinite ? minProfit : 0),
                    icon: Icons.thumb_down_rounded,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InsightCard(
              title: 'متوسط الربح اليومي',
              subtitle: '${dailyStats.length} يوم',
              value: Formatters.formatCurrency(avgProfit.isFinite ? avgProfit : 0),
              icon: Icons.show_chart_rounded,
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitTrendChart(List<dynamic> dailyStats) {
    if (dailyStats.isEmpty) return const SizedBox.shrink();

    final chartData = <ChartDataPoint>[];

    for (final day in dailyStats) {
      final date = day['date'] as String? ?? '';
      final net = (day['netProfit'] as num?)?.toDouble() ?? 0.0;

      if (date.isNotEmpty) {
        try {
          final dayLabel = DateFormat('d/M').format(DateTime.parse(date));
          chartData.add(
            ChartDataPoint(
              label: dayLabel,
              value: net,
              color: net >= 0 ? AppColors.success : AppColors.danger,
            ),
          );
        } catch (_) {
          // تجاهل أخطاء التاريخ
        }
      }
    }

    if (chartData.isEmpty) return const SizedBox.shrink();

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
              'اتجاه صافي الربح اليومي',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            SimpleTrendChart(
              title: 'صافي الربح لكل يوم',
              data: chartData,
              primaryColor: AppColors.sales,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.sales,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReport();
    }
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
