import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/sales/get_sales.dart';
import '../../../domain/usecases/customers/get_customers.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/customer.dart';
import 'widgets/customer_ranking_widget.dart';
import '../../widgets/common/loading_widget.dart';

class CustomersReportScreen extends StatefulWidget {
  const CustomersReportScreen({super.key});

  @override
  State<CustomersReportScreen> createState() => _CustomersReportScreenState();
}

class _CustomersReportScreenState extends State<CustomersReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 89));
  DateTime _endDate = DateTime.now();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('d MMMM yyyy', 'ar');

  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerRankingItem> _topCustomers = [];
  int _totalActiveCustomers = 0;
  double _totalPurchases = 0.0;
  double _totalDebt = 0.0;
  int _blockedCustomers = 0;

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
      final getSales = sl<GetSales>();
      final getCustomers = sl<GetCustomers>();

      final List<Sale> allSales = await getSales(NoParams());
      final List<Customer> allCustomers = await getCustomers(NoParams());

      final from = _dateFormat.format(_startDate);
      final to = _dateFormat.format(_endDate);

      final filteredSales = allSales.where((s) {
        final d = s.date;
        return d.compareTo(from) >= 0 && d.compareTo(to) <= 0;
      });

      final Map<int?, ({double total, int count})> agg = {};
      for (final sale in filteredSales) {
        final id = sale.customerId;
        if (id == null) continue;
        final current = agg[id] ?? (total: 0.0, count: 0);
        agg[id] = (
          total: current.total + sale.totalAmount,
          count: current.count + 1,
        );
      }

      final customersById = {for (final c in allCustomers) c.id: c};

      final items = <CustomerRankingItem>[];
      double totalPurchases = 0.0;
      double totalDebt = 0.0;
      int blocked = 0;

      var rank = 1;
      final entries = agg.entries.toList()
        ..sort((a, b) => b.value.total.compareTo(a.value.total));

      for (final entry in entries.take(20)) {
        final customer = customersById[entry.key];
        if (customer == null) continue;

        final total = entry.value.total;
        final count = entry.value.count;

        totalPurchases += total;
        totalDebt += customer.currentDebt;
        if (customer.isBlocked) blocked++;

        items.add(
          CustomerRankingItem(
            name: customer.name,
            phone: customer.phone,
            totalPurchases: total,
            transactionCount: count,
            balance: customer.currentDebt,
            rank: rank++,
            isBlocked: customer.isBlocked,
          ),
        );
      }

      setState(() {
        _topCustomers = items;
        _totalActiveCustomers = customersById.values
            .where((c) => !c.isBlocked)
            .length;
        _totalPurchases = totalPurchases;
        _totalDebt = totalDebt;
        _blockedCustomers = blocked;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل تقرير العملاء: ${e.toString()}';
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
            primary: AppColors.debt,
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
            'تقرير العملاء',
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
                  if (_topCustomers.isEmpty)
                    _buildEmptyState()
                  else
                    CustomerRankingWidget(
                      customers: _topCustomers,
                      title: 'أفضل العملاء حسب المشتريات',
                      maxItems: _topCustomers.length,
                      rankingType: RankingType.topBuyers,
                    ),
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
                color: AppColors.debt.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.people_rounded, color: AppColors.debt),
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
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'عدد العملاء النشطين',
            value: '$_totalActiveCustomers',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            label: 'إجمالي المشتريات',
            value: Formatters.formatCurrency(_totalPurchases),
            color: AppColors.sales,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            label: 'إجمالي الديون',
            value: Formatters.formatCurrency(_totalDebt),
            color: AppColors.debt,
          ),
        ),
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
          'لا توجد بيانات عملاء في هذه الفترة.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
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
