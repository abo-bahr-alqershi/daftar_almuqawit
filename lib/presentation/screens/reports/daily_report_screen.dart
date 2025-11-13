import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'widgets/best_sellers_widget.dart';
import 'widgets/customer_ranking_widget.dart';

/// شاشة التقرير اليومي - تصميم راقي هادئ
class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('EEEE، d MMMM yyyy', 'ar');

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
      GenerateDailyReportEvent(_dateFormat.format(_selectedDate)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      BlocConsumer<ReportsBloc, ReportsState>(
                        listener: (context, state) {
                          if (state is ReportsSuccess) {
                            _showSuccessMessage(state.message);
                          } else if (state is ReportsError) {
                            _showErrorMessage(state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is ReportsLoading) {
                            return _buildShimmerLoading();
                          }
                          if (state is ReportsLoaded) {
                            return Column(
                              children: [
                                _buildDateSelector(),
                                const SizedBox(height: 24),
                                _buildStatsCard(state.reportData),
                                const SizedBox(height: 32),
                                _buildDetailedStats(state.reportData),
                                const SizedBox(height: 24),
                                _buildCharts(state.reportData),
                                const SizedBox(height: 100),
                              ],
                            );
                          }
                          return _buildEmptyState();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _buildExportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
    height: 400,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withOpacity(0.08),
          AppColors.info.withOpacity(0.05),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildModernAppBar(double topPadding) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 2,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _loadReport();
          },
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.info],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.assessment_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'التقرير اليومي',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تحليل شامل لليوم',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
              ),
            ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(20),
            child: Container(
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
                          AppColors.primary.withOpacity(0.1),
                          AppColors.info.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
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
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _displayFormat.format(_selectedDate),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> data) {
    final stats = data['statistics'] as Map<String, dynamic>? ?? {};
    final grossProfit = (stats['grossProfit'] as num?)?.toDouble() ?? 0.0;
    final netProfit = (stats['netProfit'] as num?)?.toDouble() ?? 0.0;
    final totalSales = (stats['totalSales'] as num?)?.toDouble() ?? 0.0;
    final profitMargin = totalSales > 0 ? (netProfit / totalSales * 100) : 0.0;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
              ),
            ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.info],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _StatsBackgroundPainter()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'صافي الربح',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _displayFormat.format(_selectedDate),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        // تصحيح من BoxShadow إلى BoxDecoration
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.success,
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'مكتمل',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1200),
                            tween: Tween(begin: 0, end: netProfit),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'ريال',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: profitMargin > 0
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.danger.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  profitMargin > 0
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  size: 16,
                                  color: profitMargin > 0
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${profitMargin.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: profitMargin > 0
                                        ? AppColors.success
                                        : AppColors.danger,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'هامش الربح',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.7,
                children: [
                  _buildStatItem(
                    icon: Icons.trending_up_rounded,
                    label: 'إجمالي المبيعات',
                    value: totalSales,
                    color: AppColors.sales,
                  ),
                  _buildStatItem(
                    icon: Icons.shopping_cart_rounded,
                    label: 'المشتريات',
                    value: (stats['totalPurchases'] as num?)?.toDouble() ?? 0.0,
                    color: AppColors.purchases,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0, end: value),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return Text(
                '${animValue.toStringAsFixed(0)} ر.ي',
                style: TextStyle(
                  fontSize: 17,
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(Map<String, dynamic> data) {
    final stats = data['statistics'] as Map<String, dynamic>? ?? {};

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.info.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'الإحصائيات التفصيلية',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              icon: Icons.payment_rounded,
              label: 'المصروفات',
              value: (stats['totalExpenses'] as num?)?.toDouble() ?? 0.0,
              color: AppColors.expense,
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'الرصيد النقدي',
              value: (stats['cashBalance'] as num?)?.toDouble() ?? 0.0,
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(Map<String, dynamic> data) {
    final stats = data['statistics'] as Map<String, dynamic>? ?? {};

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

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ChartWidget(
          title: 'نظرة عامة على المعاملات',
          chartType: ChartType.bar,
          data: chartData,
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    height: 200,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assessment_rounded,
              size: 60,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد بيانات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'لا توجد معاملات في هذا اليوم',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    ),
  );

  Widget _buildExportButton() => Positioned(
    bottom: 20,
    left: 20,
    child: BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoaded) {
          return FloatingActionButton.extended(
            onPressed: () => _showExportOptions(state.reportData),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: const Text(
              'تصدير',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 8,
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );

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

  void _showExportOptions(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: ExportOptions(onExport: (type) => _handleExport(type, data)),
      ),
    );
  }

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
    Navigator.pop(context);
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _StatsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 60, paint);

    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 80, paint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width * 0.3, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
