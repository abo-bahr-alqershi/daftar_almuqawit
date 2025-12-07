import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/purchase.dart';
import '../../../../domain/entities/supplier.dart';
import '../../../../domain/repositories/supplier_repository.dart';
import '../../../../domain/usecases/purchases/get_purchases_by_supplier.dart';

/// بطاقة عرض المشترى - تصميم راقي ونظيف
class PurchaseItemCard extends StatefulWidget {
  final Purchase purchase;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;
  final bool showActions;

  const PurchaseItemCard({
    super.key,
    required this.purchase,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCancel,
    this.showActions = true,
  });

  @override
  State<PurchaseItemCard> createState() => _PurchaseItemCardState();
}

class _PurchaseItemCardState extends State<PurchaseItemCard> {
  bool _isPressed = false;
  Supplier? _supplierSummary;
  double? _supplierTotalPurchases;
  double? _supplierTotalDebt;
  bool _isSummaryLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSupplierSummary();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.04),
              blurRadius: _isPressed ? 4 : 8,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Status indicator
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.6)],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(statusColor),
                    const SizedBox(height: 14),
                    _buildQuantityPriceRow(),
                    const SizedBox(height: 12),
                    _buildTotalSection(statusColor),
                    if (_supplierSummary != null) ...[
                      const SizedBox(height: 12),
                      _buildSupplierSummary(),
                    ],
                    const SizedBox(height: 12),
                    _buildFooter(),
                    if (widget.showActions) ...[
                      const SizedBox(height: 12),
                      _buildActions(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Row(
      children: [
        Hero(
          tag: 'purchase-avatar-${widget.purchase.id}',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: statusColor,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.purchase.qatTypeName ?? 'قات',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.purchase.supplierName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.purchase.supplierName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        _buildStatusBadge(statusColor),
      ],
    );
  }

  Widget _buildStatusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            widget.purchase.paymentStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityPriceRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              icon: Icons.inventory_2_outlined,
              label: 'الكمية',
              value:
                  '${widget.purchase.quantity.toStringAsFixed(0)} ${widget.purchase.unit}',
              color: const Color(0xFF0EA5E9),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _buildInfoItem(
              icon: Icons.attach_money,
              label: 'سعر الوحدة',
              value: '${widget.purchase.unitPrice.toStringAsFixed(0)} ر.ي',
              color: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTotalSection(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.purchase.totalAmount.toStringAsFixed(0)} ر.ي',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          if (widget.purchase.remainingAmount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'متبقي',
                    style: TextStyle(fontSize: 10, color: Color(0xFFDC2626)),
                  ),
                  Text(
                    '${widget.purchase.remainingAmount.toStringAsFixed(0)} ر.ي',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

  Widget _buildSupplierSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.shopping_bag_outlined,
              label: 'إجمالي مشترياتنا',
              value: '${(_supplierTotalPurchases ?? 0).toStringAsFixed(0)} ر.ي',
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'الدين للمورد',
              value: '${(_supplierTotalDebt ?? 0).toStringAsFixed(0)} ر.ي',
              color: const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
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
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
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
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 12, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(
          widget.purchase.date,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.access_time, size: 12, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(
          widget.purchase.time,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const Spacer(),
        if (widget.purchase.invoiceNumber != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 10,
                  color: Color(0xFF0EA5E9),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.purchase.invoiceNumber!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0EA5E9),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.onCancel != null)
            _buildActionButton(
              icon: Icons.block,
              label: 'إلغاء',
              color: const Color(0xFFF59E0B),
              onPressed: widget.onCancel!,
            ),
          if (widget.onEdit != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.edit_outlined,
              label: 'تعديل',
              color: const Color(0xFF0EA5E9),
              onPressed: widget.onEdit!,
            ),
          ],
          if (widget.onDelete != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.autorenew,
              label: 'استرداد',
              color: const Color(0xFFDC2626),
              onPressed: widget.onDelete!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.purchase.paymentStatus) {
      case 'مدفوع':
        return const Color(0xFF16A34A);
      case 'غير مدفوع':
        return const Color(0xFFDC2626);
      case 'مدفوع جزئياً':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon() {
    switch (widget.purchase.paymentStatus) {
      case 'مدفوع':
        return Icons.check_circle;
      case 'غير مدفوع':
        return Icons.cancel;
      case 'مدفوع جزئياً':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _loadSupplierSummary() async {
    if (widget.purchase.supplierId == null) return;

    setState(() => _isSummaryLoading = true);

    try {
      final supplierRepo = getIt<SupplierRepository>();
      final purchasesUseCase = getIt<GetPurchasesBySupplier>();

      final supplier = await supplierRepo.getById(widget.purchase.supplierId!);
      final purchases = await purchasesUseCase(widget.purchase.supplierId!);

      final totalPurchases = purchases.fold<double>(
        0,
        (sum, p) => sum + p.totalAmount,
      );

      if (!mounted) return;
      setState(() {
        _supplierSummary = supplier;
        _supplierTotalPurchases = totalPurchases;
        _supplierTotalDebt = supplier?.totalDebtToHim;
        _isSummaryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSummaryLoading = false);
    }
  }
}
