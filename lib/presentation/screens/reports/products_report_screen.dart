import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/statistics/get_best_sellers.dart';
import '../../../domain/usecases/qat_types/get_qat_types.dart';
import '../../../domain/entities/qat_type.dart';
import 'widgets/chart_widget.dart';
import '../../widgets/common/loading_widget.dart';

class ProductsReportScreen extends StatefulWidget {
  const ProductsReportScreen({super.key});

  @override
  State<ProductsReportScreen> createState() => _ProductsReportScreenState();
}

class _ProductsReportScreenState extends State<ProductsReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 89));
  DateTime _endDate = DateTime.now();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('d MMMM yyyy', 'ar');

  bool _isLoading = false;
  String? _errorMessage;

  List<_ProductItem> _bestSellers = [];
  double _totalQuantity = 0.0;
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getBestSellers = sl<GetBestSellers>();
      final getQatTypes = sl<GetQatTypes>();

      final from = _dateFormat.format(_startDate);
      final to = _dateFormat.format(_endDate);

      final best = await getBestSellers((from: from, to: to, topN: 30));
      final qatTypes = await getQatTypes(NoParams());

      final qatById = {for (final q in qatTypes) q.id: q};

      final items = <_ProductItem>[];
      double totalQty = 0.0;
      double totalAmt = 0.0;
      var rank = 1;

      for (final b in best) {
        final qat = qatById[b.qatTypeId];
        final name = qat?.name ?? 'منتج غير محدد';

        if (b.totalQuantity <= 0 && b.totalAmount <= 0) continue;

        items.add(
          _ProductItem(
            name: name,
            totalQuantity: b.totalQuantity,
            totalAmount: b.totalAmount,
            rank: rank++,
          ),
        );

        totalQty += b.totalQuantity;
        totalAmt += b.totalAmount;
      }

      setState(() {
        _bestSellers = items;
        _totalQuantity = totalQty;
        _totalRevenue = totalAmt;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل تقرير انواع القات: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            primary: AppColors.expense,
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
      await _loadData();
    }
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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          title: Text(
            'تقرير انواع القات',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRangeCard(),
                const SizedBox(height: 20),
                _buildSummaryRow(),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: LoadingWidget())
                else if (_errorMessage != null)
                  _buildError()
                else ...[
                  if (_bestSellers.isEmpty)
                    _buildEmptyState()
                  else ...[
                    _buildRevenueChart(),
                    const SizedBox(height: 24),
                    _buildBestList(),
                    const SizedBox(height: 24),
                    _buildWorstList(),
                  ],
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    final duration = _endDate.difference(_startDate).inDays + 1;

    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.expense.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: AppColors.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الفترة الزمنية',
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'المدة: $duration يوم',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final productsCount = _bestSellers.length;

    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'عدد المنتجات المباعة',
            value: '$productsCount',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            label: 'إجمالي الكمية المباعة',
            value: _totalQuantity.toStringAsFixed(0),
            color: AppColors.sales,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            label: 'إجمالي قيمة المبيعات',
            value: Formatters.formatCurrency(_totalRevenue),
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    final topForChart = _bestSellers.take(8).toList();
    if (topForChart.isEmpty) return const SizedBox.shrink();

    final data = topForChart
        .map(
          (p) => ChartDataPoint(
            label: p.name,
            value: p.totalAmount,
            color: AppColors.sales,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أكثر المنتجات مبيعاً (بالقيمة)',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        SimpleTrendChart(
          title: 'قيمة المبيعات حسب المنتج',
          data: data,
          primaryColor: AppColors.sales,
        ),
      ],
    );
  }

  Widget _buildBestList() {
    final best = _bestSellers.take(10).toList();
    if (best.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أفضل 10 منتجات مبيعاً',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...best.map((p) => _ProductTile(item: p)),
      ],
    );
  }

  Widget _buildWorstList() {
    if (_bestSellers.length <= 3) return const SizedBox.shrink();

    final sortedByAmount = [..._bestSellers]
      ..sort((a, b) => a.totalAmount.compareTo(b.totalAmount));

    final worst = sortedByAmount
        .take(10)
        .where((p) => p.totalAmount > 0)
        .toList();
    if (worst.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أقل 10 منتجات مبيعاً',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...worst.map((p) => _ProductTile(item: p)),
      ],
    );
  }

  Widget _buildError() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.danger.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حدث خطأ',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.danger,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _errorMessage ?? 'تعذر تحميل بيانات التقرير.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة'),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border.withOpacity(0.15)),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AppColors.textHint,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          'لا توجد بيانات منتجات في هذه الفترة.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _ProductItem {
  const _ProductItem({
    required this.name,
    required this.totalQuantity,
    required this.totalAmount,
    required this.rank,
  });

  final String name;
  final double totalQuantity;
  final double totalAmount;
  final int rank;
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.item});

  final _ProductItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.expense.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${item.rank}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.expense,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'الكمية: ${item.totalQuantity.toStringAsFixed(0)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'القيمة: ${Formatters.formatCurrency(item.totalAmount)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
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
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
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
