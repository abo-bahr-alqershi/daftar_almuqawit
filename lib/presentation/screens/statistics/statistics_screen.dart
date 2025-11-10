import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/daily_statistics.dart';
import '../../blocs/statistics/statistics_bloc.dart';
import '../../blocs/statistics/statistics_event.dart';
import '../../blocs/statistics/statistics_state.dart';
import '../../blocs/statistics/reports_bloc.dart';
import '../../blocs/statistics/reports_event.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import '../../widgets/common/empty_widget.dart';
import '../../widgets/charts/pie_chart_widget.dart';
import '../../widgets/charts/bar_chart_widget.dart';
import '../../widgets/charts/line_chart_widget.dart';

/// شاشة الإحصائيات الرئيسية
/// تعرض إحصائيات المبيعات والمشتريات والأرباح والديون
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  /// الفترة الزمنية المحددة
  TimePeriod _selectedPeriod = TimePeriod.today;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  /// تحميل الإحصائيات حسب الفترة المحددة
  void _loadStatistics() {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case TimePeriod.today:
        final today = _formatDate(now);
        context.read<StatisticsBloc>().add(LoadTodayStatistics(today));
        break;
      
      case TimePeriod.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = now;
        context.read<StatisticsBloc>().add(
          LoadPeriodStatistics(_formatDate(weekStart), _formatDate(weekEnd))
        );
        break;
      
      case TimePeriod.month:
        context.read<StatisticsBloc>().add(
          LoadMonthStatistics(now.year, now.month)
        );
        break;
      
      case TimePeriod.year:
        context.read<StatisticsBloc>().add(LoadYearStatistics(now.year));
        break;
    }
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return date.toString().split(' ')[0];
  }

  /// تغيير الفترة الزمنية
  void _changePeriod(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadStatistics();
  }

  /// طباعة التقرير
  void _printReport(Map<String, dynamic> data) {
    context.read<ReportsBloc>().add(PrintReportEvent('daily', data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري طباعة التقرير...')),
    );
  }

  /// مشاركة التقرير
  void _shareReport(Map<String, dynamic> data) {
    context.read<ReportsBloc>().add(ShareReportEvent('daily', data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري مشاركة التقرير...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('الإحصائيات', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadStatistics,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return const LoadingWidget(message: 'جاري تحميل الإحصائيات...');
            }

            if (state is StatisticsError) {
              return app_error.ErrorWidget(
                message: state.message,
                onRetry: _loadStatistics,
              );
            }

            if (state is StatisticsLoaded) {
              if (state.stats.isEmpty) {
                return EmptyWidget(
                  title: 'لا توجد بيانات',
                  message: 'لا توجد إحصائيات متاحة لهذه الفترة',
                  icon: Icons.analytics_outlined,
                  actionLabel: 'تحديث',
                  onAction: _loadStatistics,
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadStatistics(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // رأس الشاشة - اختيار الفترة الزمنية
                      _buildPeriodSelector(),

                      // بطاقات الإحصائيات السريعة
                      _buildQuickStatsCards(state.stats),

                      // رسم بياني خطي للمبيعات والمشتريات
                      _buildSalesChart(state.stats),

                      // رسم دائري لتوزيع المبيعات
                      _buildSalesDistributionChart(state.stats),

                      // أفضل 5 عملاء
                      _buildTopCustomers(),

                      // أفضل 5 منتجات
                      _buildTopProducts(),

                      const SizedBox(height: AppDimensions.spaceXL),
                    ],
                  ),
                ),
              );
            }

            return const EmptyWidget(
              title: 'لا يوجد بيانات',
              message: 'لم يتم تحميل الإحصائيات',
              icon: Icons.analytics_outlined,
            );
          },
        ),
      ),
    );
  }

  /// بناء محدد الفترة الزمنية
  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton(
              'اليوم',
              TimePeriod.today,
              Icons.today,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: _buildPeriodButton(
              'الأسبوع',
              TimePeriod.week,
              Icons.date_range,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: _buildPeriodButton(
              'الشهر',
              TimePeriod.month,
              Icons.calendar_month,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: _buildPeriodButton(
              'السنة',
              TimePeriod.year,
              Icons.calendar_today,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء زر الفترة الزمنية
  Widget _buildPeriodButton(String label, TimePeriod period, IconData icon) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () => _changePeriod(period),
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingM,
          horizontal: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقات الإحصائيات السريعة
  Widget _buildQuickStatsCards(List<DailyStatistics> stats) {
    // حساب الإجماليات
    final totalSales = stats.fold(0.0, (sum, s) => sum + s.totalSales);
    final totalPurchases = stats.fold(0.0, (sum, s) => sum + s.totalPurchases);
    final totalProfit = stats.fold(0.0, (sum, s) => sum + s.netProfit);
    final totalDebts = stats.fold(0.0, (sum, s) => sum + s.newDebts);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المبيعات',
                  totalSales,
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: _buildStatCard(
                  'المشتريات',
                  totalPurchases,
                  Icons.shopping_cart,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'الأرباح',
                  totalProfit,
                  Icons.attach_money,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: _buildStatCard(
                  'الديون',
                  totalDebts,
                  Icons.account_balance_wallet,
                  AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة إحصائية
  Widget _buildStatCard(
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_upward,
                color: AppColors.success,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            '${value.toStringAsFixed(2)} ر.س',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء رسم بياني للمبيعات والمشتريات
  Widget _buildSalesChart(List<DailyStatistics> stats) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المبيعات والمشتريات',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceL),
          SizedBox(
            height: 200,
            child: LineChartWidget(
              dataSets: _prepareChartData(stats),
              showGrid: true,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء مفتاح الرسم البياني
  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('المبيعات', AppColors.primary),
        const SizedBox(width: AppDimensions.spaceM),
        _buildLegendItem('المشتريات', AppColors.info),
      ],
    );
  }

  /// بناء عنصر مفتاح
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// تجهيز بيانات الرسم البياني
  List<LineChartDataSet> _prepareChartData(List<DailyStatistics> stats) {
    return [
      LineChartDataSet(
        label: 'المبيعات',
        data: stats.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalSales)).toList(),
        color: AppColors.primary,
      ),
      LineChartDataSet(
        label: 'المشتريات',
        data: stats.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalPurchases)).toList(),
        color: AppColors.info,
      ),
    ];
  }

  /// الحصول على تسميات المحور X
  List<String> _getXLabels(List<DailyStatistics> stats) {
    if (stats.isEmpty) return [];
    
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return ['اليوم'];
      case TimePeriod.week:
        return ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
      case TimePeriod.month:
        return List.generate(stats.length, (i) => '${i + 1}');
      case TimePeriod.year:
        return ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    }
  }

  /// بناء رسم دائري لتوزيع المبيعات
  Widget _buildSalesDistributionChart(List<DailyStatistics> stats) {
    final totalCashSales = stats.fold(0.0, (sum, s) => sum + s.cashSales);
    final totalCreditSales = stats.fold(0.0, (sum, s) => sum + s.creditSales);

    if (totalCashSales == 0 && totalCreditSales == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزيع المبيعات',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          SizedBox(
            height: 200,
            child: PieChartWidget(
              data: [
                AppPieChartData(
                  label: 'مبيعات نقدية',
                  value: totalCashSales,
                  color: AppColors.success,
                ),
                AppPieChartData(
                  label: 'مبيعات آجلة',
                  value: totalCreditSales,
                  color: AppColors.warning,
                ),
              ],
              showLegend: true,
              showPercentages: true,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قائمة أفضل العملاء
  Widget _buildTopCustomers() {
    // بيانات وهمية - يجب استبدالها ببيانات حقيقية
    final topCustomers = [
      {'name': 'أحمد محمد', 'total': 15000.0, 'count': 25},
      {'name': 'فاطمة علي', 'total': 12500.0, 'count': 18},
      {'name': 'محمد حسن', 'total': 10000.0, 'count': 15},
      {'name': 'سارة خالد', 'total': 8500.0, 'count': 12},
      {'name': 'عبدالله سعيد', 'total': 7000.0, 'count': 10},
    ];

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أفضل 5 عملاء',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.emoji_events,
                color: AppColors.warning,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceL),
          ...topCustomers.asMap().entries.map((entry) {
            final index = entry.key;
            final customer = entry.value;
            return _buildCustomerItem(
              index + 1,
              customer['name'] as String,
              customer['total'] as double,
              customer['count'] as int,
            );
          }).toList(),
        ],
      ),
    );
  }

  /// بناء عنصر عميل
  Widget _buildCustomerItem(int rank, String name, double total, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count عملية شراء',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ر.س',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قائمة أفضل المنتجات
  Widget _buildTopProducts() {
    // بيانات وهمية - يجب استبدالها ببيانات حقيقية
    final topProducts = [
      {'name': 'منتج A', 'quantity': 150, 'total': 22500.0},
      {'name': 'منتج B', 'quantity': 120, 'total': 18000.0},
      {'name': 'منتج C', 'quantity': 100, 'total': 15000.0},
      {'name': 'منتج D', 'quantity': 85, 'total': 12750.0},
      {'name': 'منتج E', 'quantity': 70, 'total': 10500.0},
    ];

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أفضل 5 منتجات',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: AppColors.success,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceL),
          ...topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return _buildProductItem(
              index + 1,
              product['name'] as String,
              product['quantity'] as int,
              product['total'] as double,
            );
          }).toList(),
        ],
      ),
    );
  }

  /// بناء عنصر منتج
  Widget _buildProductItem(int rank, String name, int quantity, double total) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'تم بيع $quantity قطعة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ر.س',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// الحصول على لون الترتيب
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.warning; // ذهبي
      case 2:
        return AppColors.textSecondary; // فضي
      case 3:
        return const Color(0xFFCD7F32); // برونزي
      default:
        return AppColors.primary;
    }
  }
}

/// تعداد للفترات الزمنية
enum TimePeriod {
  today,
  week,
  month,
  year,
}
