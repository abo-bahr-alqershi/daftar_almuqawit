import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/usecases/sales/get_sales_by_customer.dart';

/// شاشة تفاصيل عملية البيع - تصميم راقي واحترافي
class SaleDetailsScreen extends StatefulWidget {
  final Sale sale;

  const SaleDetailsScreen({super.key, required this.sale});

  @override
  State<SaleDetailsScreen> createState() => _SaleDetailsScreenState();
}

class _SaleDetailsScreenState extends State<SaleDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  Customer? _customerSummary;
  bool _isCustomerSummaryLoading = false;
  String? _customerSummaryError;
  double? _customerTotalPurchases;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    _loadCustomerSummary();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerSummary() async {
    if (widget.sale.customerId == null) return;

    setState(() {
      _isCustomerSummaryLoading = true;
      _customerSummaryError = null;
    });

    try {
      final customerRepo = getIt<CustomerRepository>();
      final salesUseCase = getIt<GetSalesByCustomer>();

      final customer = await customerRepo.getById(widget.sale.customerId!);
      final sales = await salesUseCase(widget.sale.customerId!);

      final totalPurchases = sales.fold<double>(
        0,
        (sum, s) => sum + s.totalAmount,
      );

      if (!mounted) return;
      setState(() {
        _customerSummary = customer;
        _customerTotalPurchases = totalPurchases;
        _isCustomerSummaryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCustomerSummaryLoading = false;
        _customerSummaryError = 'تعذر تحميل إجماليات العميل';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animationController.value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - _animationController.value)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildMainSummaryCard(),
                      const SizedBox(height: 16),
                      if (widget.sale.customerName != null)
                        _buildCustomerInfoCard(),
                      if (widget.sale.customerId != null)
                        _buildCustomerSummaryCard(),
                      _buildProductDetailsCard(),
                      const SizedBox(height: 16),
                      _buildPaymentInfoCard(),
                      const SizedBox(height: 16),
                      if (widget.sale.notes?.isNotEmpty == true)
                        _buildNotesCard(),
                      _buildStatisticsCard(),
                      const SizedBox(height: 16),
                      _buildActionsSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(opacity),
      actions: [
        _buildAppBarAction(Icons.edit_rounded, _editSale, opacity),
        _buildAppBarAction(Icons.share_rounded, _shareSale, opacity),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildHeaderContent()),
    );
  }

  Widget _buildBackButton(double opacity) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: opacity < 0.5 ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: opacity < 0.5
                    ? const Color(0xFFE5E7EB)
                    : Colors.transparent,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onTap, double opacity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: opacity < 0.5 ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: opacity < 0.5
                    ? const Color(0xFFE5E7EB)
                    : Colors.transparent,
              ),
            ),
            child: Icon(icon, color: const Color(0xFF1A1A2E), size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FA), Color(0xFFF8F9FA)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
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
                        const Text(
                          'تفاصيل الفاتورة',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${widget.sale.invoiceNumber ?? widget.sale.id}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
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
    );
  }

  Widget _buildMainSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملخص الفاتورة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Total Amount
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.1),
                  const Color(0xFF10B981).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المبلغ الإجمالي',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.sale.totalAmount.toStringAsFixed(0)} ر.ي',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor().withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.sale.status == 'ملغي'
                        ? 'ملغي'
                        : widget.sale.paymentStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Date & Time
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  Icons.calendar_today_rounded,
                  'التاريخ',
                  widget.sale.date,
                  const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  Icons.access_time_rounded,
                  'الوقت',
                  widget.sale.time,
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Financial Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAmountColumn(
                  'المدفوع',
                  widget.sale.paidAmount,
                  const Color(0xFF10B981),
                  Icons.check_circle_rounded,
                ),
                Container(width: 1, height: 50, color: const Color(0xFFE5E7EB)),
                _buildAmountColumn(
                  'المتبقي',
                  widget.sale.remainingAmount,
                  const Color(0xFFF59E0B),
                  Icons.schedule_rounded,
                ),
                Container(width: 1, height: 50, color: const Color(0xFFE5E7EB)),
                _buildAmountColumn(
                  'الربح',
                  widget.sale.profit,
                  const Color(0xFF3B82F6),
                  Icons.trending_up_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountColumn(
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF6366F1),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'العميل',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.sale.customerName ?? 'عميل عام',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          if (widget.sale.customerId != null)
            GestureDetector(
              onTap: _viewCustomerDetails,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF6366F1),
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerSummaryCard() {
    if (_isCustomerSummaryLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_customerSummary == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'إجماليات العميل',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  'إجمالي المشتريات',
                  '${(_customerTotalPurchases ?? 0).toStringAsFixed(0)} ر.ي',
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  'الدين الحالي',
                  '${_customerSummary!.currentDebt.toStringAsFixed(0)} ر.ي',
                  const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تفاصيل المنتج',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.grass_rounded,
            'نوع القات',
            widget.sale.qatTypeName ?? 'غير محدد',
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            Icons.shopping_basket_rounded,
            'الكمية',
            '${widget.sale.quantity} ${widget.sale.unit}',
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            Icons.attach_money_rounded,
            'سعر الوحدة',
            '${widget.sale.unitPrice.toStringAsFixed(0)} ر.ي',
          ),
          if (widget.sale.discount > 0) ...[
            const SizedBox(height: 14),
            _buildDetailRow(
              Icons.discount_rounded,
              'الخصم',
              '${widget.sale.discount.toStringAsFixed(0)} ر.ي',
              valueColor: const Color(0xFFDC2626),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  size: 20,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات الدفع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            _getPaymentIcon(widget.sale.paymentMethod),
            'طريقة الدفع',
            widget.sale.paymentMethod,
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            Icons.receipt_rounded,
            'الإجمالي',
            '${widget.sale.totalAmount.toStringAsFixed(0)} ر.ي',
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            Icons.check_circle_rounded,
            'المدفوع',
            '${widget.sale.paidAmount.toStringAsFixed(0)} ر.ي',
            valueColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            Icons.schedule_rounded,
            'المتبقي',
            '${widget.sale.remainingAmount.toStringAsFixed(0)} ر.ي',
            valueColor: widget.sale.remainingAmount > 0
                ? const Color(0xFFF59E0B)
                : const Color(0xFF10B981),
          ),
          const SizedBox(height: 20),

          // Payment Status Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _getStatusColor().withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getStatusIcon(), color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'حالة الدفع',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.sale.status == 'ملغي'
                            ? 'ملغي'
                            : widget.sale.paymentStatus,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (widget.sale.dueDate != null) ...[
            const SizedBox(height: 14),
            _buildDetailRow(
              Icons.event_rounded,
              'تاريخ الاستحقاق',
              widget.sale.dueDate!,
              valueColor: const Color(0xFFF59E0B),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.note_rounded,
                  size: 20,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملاحظات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.sale.notes!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final profitPercentage = widget.sale.totalAmount > 0
        ? (widget.sale.profit / widget.sale.totalAmount) * 100
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '${profitPercentage.toStringAsFixed(1)}%',
            'معدل الربح',
            Icons.trending_up_rounded,
            const Color(0xFF10B981),
          ),
          Container(width: 1, height: 50, color: const Color(0xFFE5E7EB)),
          _buildStatItem(
            widget.sale.isQuickSale ? 'سريع' : 'عادي',
            'نوع البيع',
            Icons.flash_on_rounded,
            const Color(0xFFF59E0B),
          ),
          Container(width: 1, height: 50, color: const Color(0xFFE5E7EB)),
          _buildStatItem(
            '#${widget.sale.id}',
            'رقم المرجع',
            Icons.tag_rounded,
            const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'طباعة',
            Icons.print_rounded,
            const Color(0xFF6366F1),
            _printReceipt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'مشاركة',
            Icons.share_rounded,
            const Color(0xFF3B82F6),
            _shareSale,
          ),
        ),
        const SizedBox(width: 12),
        _buildIconActionButton(
          Icons.delete_rounded,
          const Color(0xFFDC2626),
          _deleteSale,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconActionButton(
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (widget.sale.status == 'ملغي') return const Color(0xFFDC2626);
    switch (widget.sale.paymentStatus) {
      case 'مدفوع':
        return const Color(0xFF10B981);
      case 'غير مدفوع':
        return const Color(0xFFDC2626);
      case 'مدفوع جزئياً':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon() {
    switch (widget.sale.paymentStatus) {
      case 'مدفوع':
        return Icons.check_circle_rounded;
      case 'غير مدفوع':
        return Icons.cancel_rounded;
      case 'مدفوع جزئياً':
        return Icons.pending_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'نقد':
      case 'نقدي':
        return Icons.payments_rounded;
      case 'آجل':
        return Icons.schedule_rounded;
      case 'بطاقة':
        return Icons.credit_card_rounded;
      case 'تحويل':
        return Icons.account_balance_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  void _editSale() {
    Navigator.pushNamed(context, '/edit-sale', arguments: widget.sale);
  }

  void _printReceipt() {
    // TODO: Implement print
  }

  void _shareSale() {
    // TODO: Implement share
  }

  void _deleteSale() {
    // TODO: Implement delete
  }

  void _viewCustomerDetails() {
    // TODO: Navigate to customer details
  }
}
