import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CustomerCardState extends State<CustomerCard> {
  bool _isPressed = false;

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
              // Debt/Warning indicator
              if (widget.customer.currentDebt > 0 ||
                  widget.customer.hasExceededCreditLimit)
                Container(
                  height: 3,
                  color: widget.customer.hasExceededCreditLimit
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFDC2626),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header row
                    _buildHeader(statusColor),

                    const SizedBox(height: 16),

                    // Financial info
                    _buildFinancialSection(),

                    // Contact info
                    if (widget.customer.phone != null) ...[
                      const SizedBox(height: 12),
                      _buildContactRow(),
                    ],

                    // Actions
                    if (widget.showActions) ...[
                      const SizedBox(height: 12),
                      _buildActionsRow(),
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
        // Avatar
        Hero(
          tag: 'customer-icon-${widget.customer.id}',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.person_outlined, color: statusColor, size: 22),
          ),
        ),

        const SizedBox(width: 12),

        // Name and nickname
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customer.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.customer.nickname != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.customer.nickname!,
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

        // Status badge
        _buildStatusBadge(statusColor),
      ],
    );
  }

  Widget _buildStatusBadge(Color statusColor) {
    final status = widget.customer.getCustomerStatus();
    IconData icon;

    if (widget.customer.isBlocked) {
      icon = Icons.block;
    } else if (widget.customer.hasExceededCreditLimit) {
      icon = Icons.warning_rounded;
    } else if (widget.customer.currentDebt > 0) {
      icon = Icons.trending_up_rounded;
    } else {
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
              'الدين الحالي',
              widget.customer.currentDebt,
              widget.customer.currentDebt > 0
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF16A34A),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _buildFinancialItem(
              'المشتريات',
              widget.customer.totalPurchases,
              const Color(0xFF6366F1),
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
          widget.customer.phone!,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const Spacer(),
        if (widget.customer.customerType != 'عادي')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCustomerTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.customer.customerType == 'VIP'
                      ? Icons.star_rounded
                      : Icons.new_releases_outlined,
                  size: 12,
                  color: _getCustomerTypeColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.customer.customerType,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _getCustomerTypeColor(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onToggleBlock != null)
          _buildActionButton(
            icon: widget.customer.isBlocked
                ? Icons.lock_open_outlined
                : Icons.lock_outline,
            label: widget.customer.isBlocked ? 'إلغاء الحظر' : 'حظر',
            color: widget.customer.isBlocked
                ? const Color(0xFF16A34A)
                : const Color(0xFFF59E0B),
            onPressed: widget.onToggleBlock!,
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
            icon: Icons.delete_outline,
            label: 'حذف',
            color: const Color(0xFFDC2626),
            onPressed: widget.onDelete!,
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (widget.customer.isBlocked) return const Color(0xFFDC2626);
    if (widget.customer.hasExceededCreditLimit) return const Color(0xFFF59E0B);
    if (widget.customer.currentDebt > 0) return const Color(0xFF3B82F6);
    return const Color(0xFF16A34A);
  }

  Color _getCustomerTypeColor() {
    switch (widget.customer.customerType) {
      case 'VIP':
        return const Color(0xFFF59E0B);
      case 'جديد':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
