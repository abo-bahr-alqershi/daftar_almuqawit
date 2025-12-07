import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CustomerDebtCardState extends State<CustomerDebtCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final progressPercentage = _calculateProgressPercentage();
    final isOverdue = _isOverdue();

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
              // Overdue indicator
              if (isOverdue)
                Container(height: 3, color: const Color(0xFFDC2626)),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(statusColor),

                    const SizedBox(height: 16),

                    // Progress section
                    _buildProgressSection(statusColor, progressPercentage),

                    const SizedBox(height: 16),

                    // Details section
                    _buildDetailsSection(isOverdue),

                    // Notes
                    if (widget.debt.notes != null &&
                        widget.debt.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildNotesSection(),
                    ],

                    // Pay button
                    if (widget.onPay != null &&
                        widget.debt.remainingAmount > 0) ...[
                      const SizedBox(height: 16),
                      _buildPayButton(),
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
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            color: statusColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المبلغ المتبقي',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyUtils.format(widget.debt.remainingAmount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getStatusIcon(), size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                widget.debt.status,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(Color statusColor, double progressPercentage) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outlined,
                    size: 14,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'تم السداد: ${CurrencyUtils.format(widget.debt.paidAmount)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${progressPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (progressPercentage / 100).clamp(0.0, 1.0),
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(bool isOverdue) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.payments_outlined,
            'المبلغ الأصلي',
            CurrencyUtils.format(widget.debt.originalAmount),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 10),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'تاريخ الدين',
            app_date.DateUtils.formatDate(widget.debt.date),
          ),
          if (widget.debt.dueDate != null) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.event_outlined,
              'تاريخ الاستحقاق',
              app_date.DateUtils.formatDate(widget.debt.dueDate!),
              isWarning: isOverdue,
            ),
          ],
          if (widget.debt.lastPaymentDate != null) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.payment_outlined,
              'آخر دفعة',
              app_date.DateUtils.formatDate(widget.debt.lastPaymentDate!),
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
    bool isWarning = false,
  }) {
    final color = isWarning ? const Color(0xFFDC2626) : const Color(0xFF6B7280);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 12, color: color)),
        ),
        if (isWarning)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'متأخر',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isWarning
                ? const Color(0xFFDC2626)
                : const Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notes_outlined, size: 16, color: Color(0xFF0EA5E9)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.debt.notes!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Material(
      color: const Color(0xFF6366F1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onPay!();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment_outlined, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'تسديد دفعة',
                style: TextStyle(
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

  Color _getStatusColor() {
    switch (widget.debt.status) {
      case 'مسدد':
        return const Color(0xFF16A34A);
      case 'مسدد جزئي':
        return const Color(0xFFF59E0B);
      case 'غير مسدد':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon() {
    switch (widget.debt.status) {
      case 'مسدد':
        return Icons.check_circle_outlined;
      case 'مسدد جزئي':
        return Icons.timelapse_outlined;
      case 'غير مسدد':
        return Icons.pending_outlined;
      default:
        return Icons.help_outline;
    }
  }

  double _calculateProgressPercentage() {
    if (widget.debt.originalAmount == 0) return 0;
    return (widget.debt.paidAmount / widget.debt.originalAmount) * 100;
  }

  bool _isOverdue() {
    if (widget.debt.dueDate == null) return false;
    try {
      final dueDate = DateTime.parse(widget.debt.dueDate!);
      return dueDate.isBefore(DateTime.now()) &&
          widget.debt.remainingAmount > 0;
    } catch (e) {
      return false;
    }
  }
}
