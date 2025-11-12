import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date;

class CustomerDebtCard extends StatefulWidget {
  final Debt debt;
  final VoidCallback? onTap;
  final VoidCallback? onPay;

  const CustomerDebtCard({
    super.key,
    required this.debt,
    this.onTap,
    this.onPay,
  });

  @override
  State<CustomerDebtCard> createState() => _CustomerDebtCardState();
}

class _CustomerDebtCardState extends State<CustomerDebtCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
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

    _progressAnimation = Tween<double>(
      begin: 0,
      end: _calculateProgressPercentage() / 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final progressPercentage = _calculateProgressPercentage();
    final isOverdue = _isOverdue();

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
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isPressed
                    ? statusColor.withOpacity(0.4)
                    : statusColor.withOpacity(0.2),
                width: _isPressed ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(_isPressed ? 0.2 : 0.1),
                  blurRadius: _isPressed ? 24 : 16,
                  offset: Offset(0, _isPressed ? 8 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  if (isOverdue)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 3,
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: 'debt-icon-${widget.debt.id}',
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      statusColor.withOpacity(0.2),
                                      statusColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: statusColor,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'المبلغ المتبقي',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    CurrencyUtils.format(widget.debt.remainingAmount),
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: statusColor,
                                      letterSpacing: -0.5,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _getStatusIcon(),
                                    size: 20,
                                    color: statusColor,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.debt.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progressPercentage / 100),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_rounded,
                                          size: 14,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'تم السداد: ${CurrencyUtils.format(widget.debt.paidAmount)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          statusColor.withOpacity(0.2),
                                          statusColor.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(value * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: statusColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.border.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Stack(
                                    children: [
                                      FractionallySizedBox(
                                        widthFactor: value,
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                statusColor,
                                                statusColor.withOpacity(0.7),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: statusColor.withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: BackdropFilter(
                                            filter: ui.ImageFilter.blur(
                                              sigmaX: 2,
                                              sigmaY: 2,
                                            ),
                                            child: Container(
                                              color: Colors.white.withOpacity(0.05),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.03),
                                AppColors.info.withOpacity(0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                icon: Icons.payments_rounded,
                                label: 'المبلغ الأصلي',
                                value: CurrencyUtils.format(widget.debt.originalAmount),
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.border.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                icon: Icons.calendar_today_rounded,
                                label: 'تاريخ الدين',
                                value: app_date.DateUtils.formatDate(widget.debt.date),
                                color: AppColors.textSecondary,
                              ),
                              if (widget.debt.dueDate != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.border.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailRow(
                                  icon: Icons.event_rounded,
                                  label: 'تاريخ الاستحقاق',
                                  value: app_date.DateUtils.formatDate(
                                    widget.debt.dueDate!,
                                  ),
                                  color: isOverdue
                                      ? AppColors.danger
                                      : AppColors.textSecondary,
                                  showWarning: isOverdue,
                                ),
                              ],
                              if (widget.debt.lastPaymentDate != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.border.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailRow(
                                  icon: Icons.payment_rounded,
                                  label: 'آخر دفعة',
                                  value: app_date.DateUtils.formatDate(
                                    widget.debt.lastPaymentDate!,
                                  ),
                                  color: AppColors.success,
                                ),
                              ],
                            ],
                          ),
                        ),

                        if (widget.debt.notes != null &&
                            widget.debt.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.info.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.note_rounded,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.debt.notes!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (widget.onPay != null &&
                            widget.debt.remainingAmount > 0) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                widget.onPay!();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: AppColors.primary.withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.payment_rounded,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'تسديد دفعة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
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
                          borderRadius: BorderRadius.circular(24),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool showWarning = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (showWarning)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 12,
                  color: AppColors.danger,
                ),
                SizedBox(width: 4),
                Text(
                  'متأخر',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (widget.debt.status) {
      case 'مسدد':
        return AppColors.success;
      case 'مسدد جزئي':
        return AppColors.warning;
      case 'غير مسدد':
        return AppColors.debt;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.debt.status) {
      case 'مسدد':
        return Icons.check_circle_rounded;
      case 'مسدد جزئي':
        return Icons.timelapse_rounded;
      case 'غير مسدد':
        return Icons.pending_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  double _calculateProgressPercentage() {
    if (widget.debt.originalAmount == 0) return 0;
    return (widget.debt.paidAmount / widget.debt.originalAmount) * 100;
  }

  bool get isOverdue {
    if (widget.debt.dueDate == null) return false;
    try {
      final dueDate = DateTime.parse(widget.debt.dueDate!);
      return dueDate.isBefore(DateTime.now()) &&
          widget.debt.remainingAmount > 0;
    } catch (e) {
      return false;
    }
  }

  bool _isOverdue() => isOverdue;
}
