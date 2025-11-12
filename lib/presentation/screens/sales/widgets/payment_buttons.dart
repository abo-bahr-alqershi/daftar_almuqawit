import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// أزرار الدفع - تصميم راقي هادئ
class PaymentButtons extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onPayCash;
  final VoidCallback onPayLater;
  final VoidCallback onPayPartial;
  final bool isProcessing;

  const PaymentButtons({
    super.key,
    required this.totalAmount,
    required this.onPayCash,
    required this.onPayLater,
    required this.onPayPartial,
    this.isProcessing = false,
  });

  @override
  State<PaymentButtons> createState() => _PaymentButtonsState();
}

class _PaymentButtonsState extends State<PaymentButtons> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTotalAmountCard(),
        const SizedBox(height: 16),
        _buildPaymentButton(
          title: 'دفع نقدي',
          subtitle: 'دفع كامل المبلغ نقداً',
          icon: Icons.payments_rounded,
          color: AppColors.success,
          onTap: widget.onPayCash,
          method: 'cash',
        ),
        const SizedBox(height: 12),
        _buildPaymentButton(
          title: 'دفع آجل',
          subtitle: 'تسجيل دين على العميل',
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
          onTap: widget.onPayLater,
          method: 'later',
        ),
        const SizedBox(height: 12),
        _buildPaymentButton(
          title: 'دفع جزئي',
          subtitle: 'دفع جزء من المبلغ',
          icon: Icons.pie_chart_rounded,
          color: AppColors.info,
          onTap: widget.onPayPartial,
          method: 'partial',
        ),
      ],
    );
  }

  Widget _buildTotalAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'المجموع الكلي',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'ريال سعودي',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String method,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: widget.isProcessing
          ? null
          : () {
              HapticFeedback.mediumImpact();
              setState(() => _selectedMethod = method);
              Future.delayed(const Duration(milliseconds: 150), onTap);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.4) : AppColors.border.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.05 : 0.02),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      )
                    : null,
                color: isSelected ? null : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: widget.isProcessing && isSelected
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: isSelected ? Colors.white : color,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isSelected ? color : AppColors.textHint,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
