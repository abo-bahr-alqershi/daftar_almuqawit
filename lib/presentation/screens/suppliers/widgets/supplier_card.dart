import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/supplier.dart';

class SupplierCard extends StatefulWidget {
  final Supplier supplier;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends State<SupplierCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
              // Debt indicator
              if (widget.supplier.totalDebtToHim > 0)
                Container(height: 3, color: const Color(0xFFDC2626)),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header row
                    _buildHeader(),

                    const SizedBox(height: 16),

                    // Financial info
                    _buildFinancialSection(),

                    // Contact info
                    if (widget.supplier.phone != null) ...[
                      const SizedBox(height: 12),
                      _buildContactRow(),
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

  Widget _buildHeader() {
    final trustColor = _getTrustColor(widget.supplier.trustLevel);
    final ratingColor = _getRatingColor(widget.supplier.qualityRating);

    return Row(
      children: [
        // Avatar
        Hero(
          tag: 'supplier-icon-${widget.supplier.id}',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: trustColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: trustColor,
              size: 22,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Name and area
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.supplier.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.supplier.area != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.supplier.area!,
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

        // Rating badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ratingColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 14, color: ratingColor),
              const SizedBox(width: 4),
              Text(
                widget.supplier.qualityRating.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: ratingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSection() {
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
              'المشتريات',
              widget.supplier.totalPurchases,
              const Color(0xFF6366F1),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _buildFinancialItem(
              'الدين له',
              widget.supplier.totalDebtToHim,
              widget.supplier.totalDebtToHim > 0
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)} ر.ي',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow() {
    return Row(
      children: [
        const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Text(
          widget.supplier.phone!,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTrustColor(widget.supplier.trustLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.supplier.trustLevel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _getTrustColor(widget.supplier.trustLevel),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return const Color(0xFF16A34A);
    if (rating >= 3) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  Color _getTrustColor(String trustLevel) {
    switch (trustLevel) {
      case 'ممتاز':
        return const Color(0xFF16A34A);
      case 'جيد':
        return const Color(0xFF0EA5E9);
      case 'متوسط':
        return const Color(0xFFF59E0B);
      case 'ضعيف':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
