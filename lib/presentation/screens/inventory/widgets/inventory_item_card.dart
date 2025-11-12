import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/inventory.dart';

/// بطاقة عرض عنصر المخزون - تصميم راقي هادئ
class InventoryItemCard extends StatefulWidget {
  final Inventory item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAdjustQuantity;
  final bool showLowStockWarning;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onAdjustQuantity,
    this.showLowStockWarning = false,
  });

  @override
  State<InventoryItemCard> createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends State<InventoryItemCard> {
  bool _isExpanded = false;

  Color _getStatusColor() {
    if (widget.item.isEmpty) return AppColors.danger;
    if (widget.item.isLowStock) return AppColors.warning;
    if (widget.item.isOverStock) return AppColors.purchases;
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (widget.item.isEmpty) return Icons.remove_circle_rounded;
    if (widget.item.isLowStock) return Icons.warning_rounded;
    if (widget.item.isOverStock) return Icons.trending_up_rounded;
    return Icons.check_circle_rounded;
  }

  String _getStatusText() {
    if (widget.item.isEmpty) return 'نفذت الكمية';
    if (widget.item.isLowStock) return 'مخزون منخفض';
    if (widget.item.isOverStock) return 'مخزون زائد';
    return 'متوفر';
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
                  if (widget.showLowStockWarning && widget.item.isLowStock)
                    _buildLowStockWarning(),
                ],
              ),
            ),
          ),
        ),
      ),
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
                AppColors.info.withOpacity(0.15),
                AppColors.info.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: AppColors.info,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.qatTypeName ?? 'غير محدد',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.straighten_rounded,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'الوحدة: ${widget.item.unit}',
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                size: 14,
                color: _getStatusColor(),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
              icon: Icons.analytics_rounded,
              label: 'الحد الأدنى',
              value: '${widget.item.minimumQuantity.toStringAsFixed(1)}',
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.border.withOpacity(0.2),
          ),
          Expanded(
            child: _InfoItem(
              icon: Icons.trending_up_rounded,
              label: 'الحد الأقصى',
              value: widget.item.maximumQuantity != null
                  ? '${widget.item.maximumQuantity!.toStringAsFixed(1)}'
                  : 'غير محدد',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    final percentage = widget.item.maximumQuantity != null && widget.item.maximumQuantity! > 0
        ? (widget.item.currentQuantity / widget.item.maximumQuantity!).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.inventory_rounded,
                label: 'الكمية الحالية',
                value: '${widget.item.currentQuantity.toStringAsFixed(1)}',
                unit: widget.item.unit,
                color: _getStatusColor(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.check_circle_rounded,
                label: 'المتاحة',
                value: '${widget.item.availableQuantity.toStringAsFixed(1)}',
                unit: widget.item.unit,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.attach_money_rounded,
                label: 'متوسط التكلفة',
                value: widget.item.averageCost != null
                    ? '${widget.item.averageCost!.toStringAsFixed(0)}'
                    : '0',
                unit: 'ريال',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        if (widget.item.maximumQuantity != null && widget.item.maximumQuantity! > 0) ...[
          const SizedBox(height: 12),
          _buildProgressBar(percentage),
        ],
      ],
    );
  }

  Widget _buildProgressBar(double percentage) {
    Color barColor;
    if (percentage >= 0.8) {
      barColor = AppColors.danger;
    } else if (percentage >= 0.5) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.success;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نسبة الامتلاء',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: AppColors.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
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
          if (widget.item.lastPurchaseDate != null)
            _DetailRow(
              icon: Icons.shopping_cart_rounded,
              label: 'آخر شراء',
              value: widget.item.lastPurchaseDate!,
            ),
          if (widget.item.lastPurchaseDate != null && widget.item.lastSaleDate != null)
            const SizedBox(height: 10),
          if (widget.item.lastSaleDate != null)
            _DetailRow(
              icon: Icons.sell_rounded,
              label: 'آخر بيع',
              value: widget.item.lastSaleDate!,
            ),
          if (widget.item.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.note_rounded,
              label: 'ملاحظات',
              value: widget.item.notes!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLowStockWarning() {
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
            child: Text(
              'يحتاج لإعادة تموين - الكمية أقل من الحد الأدنى',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.onAdjustQuantity != null)
            _ActionButton(
              icon: Icons.add_circle_rounded,
              color: AppColors.warning,
              onPressed: widget.onAdjustQuantity!,
            ),
        ],
      ),
    );
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
            textAlign: TextAlign.center,
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
