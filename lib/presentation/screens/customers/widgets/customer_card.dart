import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/customer.dart';

class CustomerCard extends StatefulWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleBlock;
  final bool showActions;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleBlock,
    this.showActions = true,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard>
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
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

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
                    ? statusColor.withOpacity(0.3)
                    : statusColor.withOpacity(0.15),
                width: _isPressed ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(_isPressed ? 0.15 : 0.08),
                  blurRadius: _isPressed ? 20 : 12,
                  offset: Offset(0, _isPressed ? 6 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  if (widget.customer.hasExceededCreditLimit)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.warning,
                              AppColors.warning.withOpacity(0.5),
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
                              tag: 'customer-icon-${widget.customer.id}',
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      statusColor.withOpacity(0.15),
                                      statusColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: statusColor,
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
                                    widget.customer.name,
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
                                  if (widget.customer.nickname != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.badge_rounded,
                                          size: 14,
                                          color: AppColors.textHint,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            widget.customer.nickname!,
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
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.customer.getCustomerStatus(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (widget.customer.customerType != 'عادي')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getCustomerTypeColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _getCustomerTypeColor().withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.customer.customerType == 'VIP'
                                      ? Icons.star_rounded
                                      : Icons.new_releases_rounded,
                                  size: 14,
                                  color: _getCustomerTypeColor(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.customer.customerType,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getCustomerTypeColor(),
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
                                AppColors.accent.withOpacity(0.03),
                                AppColors.primary.withOpacity(0.02),
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
                                  icon: Icons.account_balance_wallet_rounded,
                                  label: 'الدين الحالي',
                                  value: widget.customer.currentDebt,
                                  color: widget.customer.currentDebt > 0
                                      ? AppColors.debt
                                      : AppColors.success,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 44,
                                color: AppColors.border.withOpacity(0.2),
                              ),
                              Expanded(
                                child: _buildFinancialItem(
                                  icon: Icons.shopping_cart_rounded,
                                  label: 'إجمالي المشتريات',
                                  value: widget.customer.totalPurchases,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (widget.customer.phone != null) ...[
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
                                widget.customer.phone!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (widget.showActions) ...[
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.border.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.onToggleBlock != null)
                                _buildActionButton(
                                  icon: widget.customer.isBlocked
                                      ? Icons.check_circle_rounded
                                      : Icons.block_rounded,
                                  label: widget.customer.isBlocked
                                      ? 'إلغاء الحظر'
                                      : 'حظر',
                                  color: widget.customer.isBlocked
                                      ? AppColors.success
                                      : AppColors.warning,
                                  onPressed: widget.onToggleBlock!,
                                ),
                              if (widget.onEdit != null) ...[
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.edit_rounded,
                                  label: 'تعديل',
                                  color: AppColors.info,
                                  onPressed: widget.onEdit!,
                                ),
                              ],
                              if (widget.onDelete != null) ...[
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.delete_rounded,
                                  label: 'حذف',
                                  color: AppColors.danger,
                                  onPressed: widget.onDelete!,
                                ),
                              ],
                            ],
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
                          color: statusColor.withOpacity(0.05),
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
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (widget.customer.isBlocked) return AppColors.danger;
    if (widget.customer.hasExceededCreditLimit) return AppColors.warning;
    if (widget.customer.currentDebt > 0) return AppColors.debt;
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (widget.customer.isBlocked) return Icons.block_rounded;
    if (widget.customer.hasExceededCreditLimit) return Icons.warning_rounded;
    if (widget.customer.currentDebt > 0) return Icons.trending_up_rounded;
    return Icons.check_circle_rounded;
  }

  Color _getCustomerTypeColor() {
    switch (widget.customer.customerType) {
      case 'VIP':
        return const Color(0xFFFFD700);
      case 'جديد':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}
