import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/sale.dart';
import '../../../../domain/entities/debt_payment.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date;

class CustomerHistoryTab extends StatefulWidget {
  final List<Sale>? sales;
  final List<DebtPayment>? payments;
  final bool isLoading;
  final String? errorMessage;

  const CustomerHistoryTab({
    super.key,
    this.sales,
    this.payments,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<CustomerHistoryTab> createState() => _CustomerHistoryTabState();
}

class _CustomerHistoryTabState extends State<CustomerHistoryTab>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.errorMessage != null) {
      return _buildErrorState();
    }

    final hasData = (widget.sales?.isNotEmpty ?? false) ||
        (widget.payments?.isNotEmpty ?? false);

    if (!hasData) {
      return _buildEmptyState();
    }

    final allItems = _buildHistoryItems();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final item = allItems[index];

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + (index * 50)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scale: value.clamp(0.0, 1.0),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: item.type == _HistoryItemType.sale
                      ? _SaleHistoryCard(sale: item.sale!)
                      : _PaymentHistoryCard(payment: item.payment!),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) => Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(value * 0.3),
                  AppColors.accent.withOpacity(value * 0.2),
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'جاري تحميل السجل...',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorState() => Center(
    child: Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.bounceOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.danger.withOpacity(0.1),
                      AppColors.danger.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'حدث خطأ',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            widget.errorMessage ?? 'فشل تحميل البيانات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.05),
                      AppColors.accent.withOpacity(0.03),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 70,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا يوجد سجل نشاط',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Text(
            'لم يتم تسجيل أي عمليات بعد',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
          ),
        ],
      ),
    ),
  );

  List<_HistoryItem> _buildHistoryItems() {
    final allItems = <_HistoryItem>[];

    if (widget.sales != null) {
      for (var sale in widget.sales!) {
        allItems.add(_HistoryItem(
          type: _HistoryItemType.sale,
          date: sale.date,
          sale: sale,
        ));
      }
    }

    if (widget.payments != null) {
      for (var payment in widget.payments!) {
        allItems.add(_HistoryItem(
          type: _HistoryItemType.payment,
          date: payment.paymentDate,
          payment: payment,
        ));
      }
    }

    allItems.sort((a, b) => b.date.compareTo(a.date));

    return allItems;
  }
}

class _SaleHistoryCard extends StatefulWidget {
  final Sale sale;

  const _SaleHistoryCard({required this.sale});

  @override
  State<_SaleHistoryCard> createState() => _SaleHistoryCardState();
}

class _SaleHistoryCardState extends State<_SaleHistoryCard>
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
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        HapticFeedback.lightImpact();
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
                    ? AppColors.sales.withOpacity(0.3)
                    : AppColors.sales.withOpacity(0.15),
                width: _isPressed ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sales.withOpacity(_isPressed ? 0.15 : 0.08),
                  blurRadius: _isPressed ? 20 : 12,
                  offset: Offset(0, _isPressed ? 6 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.sales,
                            AppColors.sales.withOpacity(0.5),
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
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.sales.withOpacity(0.15),
                                    AppColors.sales.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_rounded,
                                color: AppColors.sales,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'عملية بيع',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: AppColors.textHint,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        app_date.DateUtils.formatDate(
                                          widget.sale.date,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyUtils.format(widget.sale.totalAmount)
                                      .split(' ')[0],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.sales,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  CurrencyUtils.format(widget.sale.totalAmount)
                                      .split(' ')
                                      .last,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.sales.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.sales.withOpacity(0.03),
                                AppColors.success.withOpacity(0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                label: 'الكمية',
                                value: widget.sale.quantity.toString(),
                                icon: Icons.inventory_2_rounded,
                              ),
                              const SizedBox(height: 10),
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
                              const SizedBox(height: 10),
                              _buildDetailRow(
                                label: 'السعر',
                                value: CurrencyUtils.format(widget.sale.unitPrice),
                                icon: Icons.attach_money_rounded,
                              ),
                              if (widget.sale.discount > 0) ...[
                                const SizedBox(height: 10),
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
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                  label: 'الخصم',
                                  value: CurrencyUtils.format(widget.sale.discount),
                                  icon: Icons.discount_rounded,
                                ),
                              ],
                            ],
                          ),
                        ),

                        if (widget.sale.notes != null &&
                            widget.sale.notes!.isNotEmpty) ...[
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
                                    widget.sale.notes!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
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
                          color: AppColors.sales.withOpacity(0.05),
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
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _PaymentHistoryCard extends StatefulWidget {
  final DebtPayment payment;

  const _PaymentHistoryCard({required this.payment});

  @override
  State<_PaymentHistoryCard> createState() => _PaymentHistoryCardState();
}

class _PaymentHistoryCardState extends State<_PaymentHistoryCard>
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
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        HapticFeedback.lightImpact();
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
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.15),
                width: _isPressed ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(_isPressed ? 0.15 : 0.08),
                  blurRadius: _isPressed ? 20 : 12,
                  offset: Offset(0, _isPressed ? 6 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success,
                            AppColors.success.withOpacity(0.5),
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
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.success.withOpacity(0.15),
                                    AppColors.success.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.payment_rounded,
                                color: AppColors.success,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'تسديد دفعة',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: AppColors.textHint,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        app_date.DateUtils.formatDate(
                                          widget.payment.paymentDate,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyUtils.format(widget.payment.amount)
                                      .split(' ')[0],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  CurrencyUtils.format(widget.payment.amount)
                                      .split(' ')
                                      .last,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success.withOpacity(0.03),
                                AppColors.primary.withOpacity(0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.credit_card_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'طريقة الدفع',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                widget.payment.paymentMethod,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (widget.payment.notes != null &&
                            widget.payment.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.note_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.payment.notes!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
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
                          color: AppColors.success.withOpacity(0.05),
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
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum _HistoryItemType { sale, payment }

class _HistoryItem {
  final _HistoryItemType type;
  final String date;
  final Sale? sale;
  final DebtPayment? payment;

  _HistoryItem({
    required this.type,
    required this.date,
    this.sale,
    this.payment,
  });
}
