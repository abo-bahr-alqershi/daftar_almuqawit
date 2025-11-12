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

class _SupplierCardState extends State<SupplierCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trustColor = _getTrustLevelColor(widget.supplier.trustLevel);
    final ratingColor = _getRatingColor(widget.supplier.qualityRating);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isPressed
                    ? trustColor.withOpacity(0.3)
                    : trustColor.withOpacity(0.15),
                width: _isPressed ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: trustColor.withOpacity(_isPressed ? 0.15 : 0.08),
                  blurRadius: _isPressed ? 20 : 12,
                  offset: Offset(0, _isPressed ? 6 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  if (widget.supplier.totalDebtToHim > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.danger,
                              AppColors.danger.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: 'supplier-icon-${widget.supplier.id}',
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      trustColor.withOpacity(0.15),
                                      trustColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.local_shipping_rounded,
                                  color: trustColor,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.supplier.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  if (widget.supplier.area != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 14,
                                          color: AppColors.textHint,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            widget.supplier.area!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textHint,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ratingColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: ratingColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.supplier.qualityRating.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ratingColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: trustColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: trustColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTrustIcon(widget.supplier.trustLevel),
                                size: 14,
                                color: trustColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.supplier.trustLevel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: trustColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.03),
                                AppColors.info.withOpacity(0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildFinancialItem(
                                  icon: Icons.shopping_cart_rounded,
                                  label: 'إجمالي المشتريات',
                                  value: widget.supplier.totalPurchases,
                                  color: AppColors.purchases,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 44,
                                color: AppColors.border.withOpacity(0.2),
                              ),
                              Expanded(
                                child: _buildFinancialItem(
                                  icon: Icons.account_balance_wallet_rounded,
                                  label: 'الدين له',
                                  value: widget.supplier.totalDebtToHim,
                                  color: widget.supplier.totalDebtToHim > 0
                                      ? AppColors.danger
                                      : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (widget.supplier.phone != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.supplier.phone!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (widget.supplier.notes != null &&
                            widget.supplier.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.info.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.note_rounded,
                                  size: 14,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.supplier.notes!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (_isPressed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: trustColor.withOpacity(0.05),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialItem({
    required IconData icon,
    required String label,
    required double value,
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
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${value.toStringAsFixed(0)} ر.ي',
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return const Color(0xFFFFD700);
    if (rating >= 2) return AppColors.warning;
    return AppColors.danger;
  }

  Color _getTrustLevelColor(String trustLevel) {
    switch (trustLevel) {
      case 'ممتاز':
        return AppColors.success;
      case 'جيد':
        return const Color(0xFF10B981);
      case 'متوسط':
        return AppColors.warning;
      case 'ضعيف':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  IconData _getTrustIcon(String trustLevel) {
    switch (trustLevel) {
      case 'ممتاز':
        return Icons.verified_rounded;
      case 'جيد':
        return Icons.check_circle_rounded;
      case 'متوسط':
        return Icons.warning_rounded;
      case 'ضعيف':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
