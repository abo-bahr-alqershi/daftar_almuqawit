import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/sale.dart';
import '../../../../domain/repositories/customer_repository.dart';
import '../../../../domain/usecases/sales/get_sales_by_customer.dart';

/// بطاقة عرض عملية بيع - تصميم راقي واحترافي
class SaleItemCard extends StatefulWidget {
  final Sale sale;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const SaleItemCard({
    super.key,
    required this.sale,
    this.onTap,
    this.onDelete,
    this.onCancel,
  });

  @override
  State<SaleItemCard> createState() => _SaleItemCardState();
}

class _SaleItemCardState extends State<SaleItemCard> {
  bool _isExpanded = false;
  bool _isPressed = false;
  double? _customerTotalPurchases;
  double? _customerCurrentDebt;
  bool _isCustomerSummaryLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerSummary();
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

  IconData _getPaymentIcon() {
    switch (widget.sale.paymentMethod) {
      case 'نقد':
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.04),
              blurRadius: _isPressed ? 4 : 10,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              // شريط الحالة
              if (widget.sale.remainingAmount > 0 ||
                  widget.sale.status == 'ملغي')
                Container(height: 3, color: _getStatusColor()),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildMainInfo(),
                    const SizedBox(height: 16),
                    _buildMetrics(),
                    if (_isExpanded) ...[
                      const SizedBox(height: 16),
                      _buildExpandedContent(),
                    ],
                    const SizedBox(height: 16),
                    _buildFooter(),
                    if (widget.sale.remainingAmount > 0)
                      _buildRemainingAmount(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Color(0xFF10B981),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.sale.invoiceNumber ?? '#${widget.sale.id ?? 0}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  if (widget.sale.isQuickSale) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.flash_on_rounded,
                            size: 12,
                            color: Color(0xFFF59E0B),
                          ),
                          SizedBox(width: 3),
                          Text(
                            'سريع',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.sale.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.sale.time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.sale.status == 'ملغي' ? 'ملغي' : widget.sale.paymentStatus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isExpanded = !_isExpanded);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'العميل',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Text(
                        widget.sale.customerName ?? 'عميل عام',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.grass_rounded,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'النوع',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Text(
                        widget.sale.qatTypeName ?? 'غير محدد',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'الكمية',
            '${widget.sale.quantity}',
            widget.sale.unit,
            Icons.inventory_2_rounded,
            const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricItem(
            'الإجمالي',
            '${widget.sale.totalAmount.toStringAsFixed(0)}',
            'ر.ي',
            Icons.attach_money_rounded,
            const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricItem(
            'الربح',
            '${widget.sale.profit.toStringAsFixed(0)}',
            'ر.ي',
            Icons.trending_up_rounded,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.price_change_rounded,
            'سعر الوحدة',
            '${widget.sale.unitPrice.toStringAsFixed(2)} ر.ي',
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            Icons.discount_rounded,
            'الخصم',
            '${(widget.sale.discount ?? 0).toStringAsFixed(2)} ر.ي',
          ),
          if (widget.sale.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            _buildDetailRow(Icons.note_rounded, 'ملاحظات', widget.sale.notes!),
          ],
          if (widget.sale.customerId != null) ...[
            const SizedBox(height: 12),
            _buildCustomerSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSummary() {
    if (_isCustomerSummaryLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.shopping_cart_rounded,
                      size: 12,
                      color: Color(0xFF6366F1),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'إجمالي مشترياته',
                      style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_customerTotalPurchases ?? 0).toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 12,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'دينه الحالي',
                      style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_customerCurrentDebt ?? 0).toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getPaymentIcon(), size: 14, color: const Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                widget.sale.paymentMethod,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (widget.onCancel != null)
          _buildActionButton(
            Icons.cancel_rounded,
            const Color(0xFFF59E0B),
            widget.onCancel!,
          ),
        if (widget.onDelete != null) ...[
          const SizedBox(width: 8),
          _buildActionButton(
            Icons.delete_rounded,
            const Color(0xFFDC2626),
            widget.onDelete!,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildRemainingAmount() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المبلغ المتبقي',
                  style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.sale.remainingAmount.toStringAsFixed(2)} ر.ي',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
          if (widget.sale.dueDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.event_rounded,
                    size: 12,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.sale.dueDate!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadCustomerSummary() async {
    if (widget.sale.customerId == null) return;

    setState(() => _isCustomerSummaryLoading = true);

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
        _customerTotalPurchases = totalPurchases;
        _customerCurrentDebt = customer?.currentDebt;
        _isCustomerSummaryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCustomerSummaryLoading = false);
    }
  }
}
