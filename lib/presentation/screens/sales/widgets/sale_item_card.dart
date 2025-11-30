import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/sale.dart';
import '../../../../domain/repositories/customer_repository.dart';
import '../../../../domain/usecases/sales/get_sales_by_customer.dart';

/// بطاقة عرض عملية بيع - تصميم راقي هادئ
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
  double? _customerTotalPurchases;
  double? _customerCurrentDebt;
  bool _isCustomerSummaryLoading = false;
  String? _customerSummaryError;

  @override
  void initState() {
    super.initState();
    _loadCustomerSummary();
  }

  Color _getStatusColor() {
    if (widget.sale.status == 'ملغي') return AppColors.danger;

    switch (widget.sale.paymentStatus) {
      case 'مدفوع':
        return AppColors.success;
      case 'غير مدفوع':
        return AppColors.danger;
      case 'مدفوع جزئياً':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
            widget.onTap?.call();
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _buildMainInfo(),
                  const SizedBox(height: 14),
                  _buildMetrics(),
                  if (_isExpanded) ...[
                    const SizedBox(height: 14),
                    _buildExpandedContent(),
                  ],
                  const SizedBox(height: 14),
                  _buildFooter(),
                  if (widget.sale.remainingAmount > 0)
                    _buildRemainingAmount(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSummarySection() {
    if (widget.sale.customerId == null) {
      return const SizedBox.shrink();
    }

    if (_isCustomerSummaryLoading) {
      return Row(
        children: const [
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            'جاري تحميل إجماليات العميل...',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    if (_customerSummaryError != null) {
      return const SizedBox.shrink();
    }

    final totalPurchases = _customerTotalPurchases ?? 0;
    final currentDebt = _customerCurrentDebt ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withOpacity(0.95),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCustomerSummaryItem(
              icon: Icons.shopping_cart_rounded,
              label: 'إجمالي مشتريات العميل',
              value: '${totalPurchases.toStringAsFixed(0)} ريال',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCustomerSummaryItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'إجمالي الدين الحالي عليه',
              value: '${currentDebt.toStringAsFixed(0)} ريال',
              color: AppColors.debt,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.primary.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.sale.invoiceNumber ?? '#${widget.sale.id ?? 0}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.sale.isQuickSale) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flash_on,
                            size: 10,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'سريع',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
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
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.sale.date,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          icon: Icon(
            _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            color: AppColors.textSecondary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoItem(
              icon: Icons.person_outline_rounded,
              label: 'العميل',
              value: widget.sale.customerName ?? 'عميل عام',
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.border.withOpacity(0.2),
          ),
          Expanded(
            child: _InfoItem(
              icon: Icons.grass_rounded,
              label: 'النوع',
              value: widget.sale.qatTypeName ?? 'غير محدد',
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
          child: _MetricCard(
            icon: Icons.inventory_2_rounded,
            label: 'الكمية',
            value: '${widget.sale.quantity}',
            unit: widget.sale.unit,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.attach_money_rounded,
            label: 'الإجمالي',
            value: '${widget.sale.totalAmount.toStringAsFixed(0)}',
            unit: 'ريال',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.trending_up_rounded,
            label: 'الربح',
            value: '${widget.sale.profit.toStringAsFixed(0)}',
            unit: 'ريال',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.price_change_rounded,
            label: 'سعر الوحدة',
            value: '${widget.sale.unitPrice.toStringAsFixed(2)} ريال',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.discount_rounded,
            label: 'الخصم',
            value: '${(widget.sale.discount ?? 0).toStringAsFixed(2)} ريال',
          ),
          if (widget.sale.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.note_rounded,
              label: 'ملاحظات',
              value: widget.sale.notes!,
            ),
          ],
          const SizedBox(height: 10),
          _buildCustomerSummarySection(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getPaymentIcon(), size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                widget.sale.paymentMethod,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (widget.onCancel != null)
          _ActionButton(
            icon: Icons.cancel_rounded,
            color: AppColors.warning,
            onPressed: widget.onCancel!,
          ),
        if (widget.onDelete != null) ...[
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.delete_rounded,
            color: AppColors.danger,
            onPressed: widget.onDelete!,
          ),
        ],
      ],
    );
  }

  Widget _buildRemainingAmount() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المبلغ المتبقي',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.sale.remainingAmount.toStringAsFixed(2)} ريال',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (widget.sale.dueDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_rounded, size: 12, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    widget.sale.dueDate!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
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
        _customerTotalPurchases = totalPurchases;
        _customerCurrentDebt = customer?.currentDebt;
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
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
