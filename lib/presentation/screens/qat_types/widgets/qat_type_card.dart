import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/qat_type.dart';

/// بطاقة نوع القات - تصميم احترافي راقي
class QatTypeCard extends StatefulWidget {
  final QatType qatType;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const QatTypeCard({
    super.key,
    required this.qatType,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  State<QatTypeCard> createState() => _QatTypeCardState();
}

class _QatTypeCardState extends State<QatTypeCard> {
  bool _isPressed = false;

  Color _getQualityColor() {
    switch (widget.qatType.qualityGrade?.toLowerCase()) {
      case 'ممتاز':
        return const Color(0xFF16A34A);
      case 'جيد جداً':
        return const Color(0xFF0EA5E9);
      case 'جيد':
        return const Color(0xFF6366F1);
      case 'متوسط':
      case 'عادي':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qualityColor = _getQualityColor();
    final profitMargin =
        (widget.qatType.defaultSellPrice ?? 0) -
        (widget.qatType.defaultBuyPrice ?? 0);

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
              // Top color indicator
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [qualityColor, qualityColor.withOpacity(0.6)],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(qualityColor),
                    const SizedBox(height: 14),

                    // Financial section
                    _buildFinancialSection(qualityColor),

                    // Profit margin
                    if (profitMargin > 0) ...[
                      const SizedBox(height: 12),
                      _buildProfitBadge(profitMargin),
                    ],

                    // Units
                    if (widget.qatType.availableUnits?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      _buildUnits(),
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

  Widget _buildHeader(Color qualityColor) {
    return Row(
      children: [
        Hero(
          tag: 'qat-type-icon-${widget.qatType.id}',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: qualityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                widget.qatType.icon ?? '🌿',
                style: const TextStyle(fontSize: 24),
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
                widget.qatType.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.qatType.qualityGrade != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: qualityColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.qatType.qualityGrade!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.showActions) _buildPopupMenu(qualityColor),
      ],
    );
  }

  Widget _buildPopupMenu(Color qualityColor) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF), size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        if (value == 'edit') widget.onEdit?.call();
        if (value == 'delete') widget.onDelete?.call();
      },
      itemBuilder: (context) => [
        if (widget.onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF0EA5E9),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('تعديل'),
              ],
            ),
          ),
        if (widget.onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('حذف', style: TextStyle(color: Color(0xFFDC2626))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFinancialSection(Color qualityColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFinancialItem(
              'سعر الشراء',
              widget.qatType.defaultBuyPrice,
              const Color(0xFFDC2626),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _buildFinancialItem(
              'سعر البيع',
              widget.qatType.defaultSellPrice,
              const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, double? value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 4),
        Text(
          value != null ? '${value.toStringAsFixed(0)} ر.ي' : '-',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value != null ? color : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildProfitBadge(double profit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 14, color: Color(0xFF16A34A)),
              const SizedBox(width: 6),
              const Text(
                'هامش الربح',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          Text(
            '${profit.toStringAsFixed(0)} ر.ي',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnits() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.qatType.availableUnits!.take(3).map((unit) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 12,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
