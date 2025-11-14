import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/purchases/purchases_bloc.dart';
import '../../blocs/purchases/purchases_event.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../navigation/route_names.dart';
import 'edit_purchase_screen.dart';

/// شاشة تفاصيل عملية الشراء - تصميم راقي متطور
class PurchaseDetailsScreen extends StatefulWidget {
  final Purchase purchase;

  const PurchaseDetailsScreen({
    super.key,
    required this.purchase,
  });

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final statusColor = _getPaymentStatusColor(widget.purchase.paymentStatus);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),
            
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernAppBar(topPadding, statusColor),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (widget.purchase.status != 'نشط')
                          _buildCancelledBanner(),
                        
                        const SizedBox(height: 20),
                        _buildMainInfoCard(statusColor),
                        
                        const SizedBox(height: 16),
                        _buildQuantityPriceCard(),
                        
                        const SizedBox(height: 16),
                        _buildPaymentCard(statusColor),
                        
                        if (widget.purchase.notes != null && widget.purchase.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildNotesCard(),
                        ],
                        
                        if (widget.purchase.remainingAmount > 0 && widget.purchase.status == 'نشط') ...[
                          const SizedBox(height: 24),
                          _buildPayButton(),
                        ],
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
    height: 400,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.purchases.withOpacity(0.08),
          AppColors.info.withOpacity(0.05),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildModernAppBar(double topPadding, Color statusColor) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 2,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(70, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.shopping_cart_rounded, color: statusColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل المشترى',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '#${widget.purchase.id}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        if (widget.purchase.status == 'نشط')
          _buildActionButton(Icons.edit_rounded, _editPurchase),
        _buildActionButton(Icons.print_rounded, _printInvoice),
        _buildMenuButton(),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary, size: 20),
      ),
      onSelected: (value) {
        switch (value) {
          case 'cancel':
            _cancelPurchase();
            break;
          case 'return':
            _openReturnScreen();
            break;
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        if (widget.purchase.status == 'نشط')
          const PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.cancel_rounded, color: AppColors.warning, size: 20),
                SizedBox(width: 12),
                Text('إلغاء المشترى'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'return',
          child: Row(
            children: [
              Icon(Icons.assignment_return_rounded, color: AppColors.info, size: 20),
              SizedBox(width: 12),
              Text('استرداد'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledBanner() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.warning.withOpacity(0.15), AppColors.warning.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_rounded, color: AppColors.warning, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'هذا المشترى تم إلغاؤه',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainInfoCard(Color statusColor) {
    return _AnimatedCard(
      delay: 100,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surface.withOpacity(0.98)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'معلومات الشراء',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.purchase.paymentStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.tag_rounded, 'رقم العملية', '#${widget.purchase.id}', AppColors.primary),
            _buildDetailRow(Icons.calendar_today_rounded, 'التاريخ', widget.purchase.date, AppColors.info),
            _buildDetailRow(Icons.access_time_rounded, 'الوقت', widget.purchase.time, AppColors.accent),
            _buildDetailRow(Icons.person_outline_rounded, 'المورد', widget.purchase.supplierName ?? 'غير محدد', AppColors.success),
            if (widget.purchase.qatTypeName != null)
              _buildDetailRow(Icons.category_rounded, 'نوع القات', widget.purchase.qatTypeName!, AppColors.purchases),
            if (widget.purchase.invoiceNumber != null)
              _buildDetailRow(Icons.receipt_long_rounded, 'رقم الفاتورة', widget.purchase.invoiceNumber!, AppColors.info),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityPriceCard() {
    return _AnimatedCard(
      delay: 200,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surface.withOpacity(0.98)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الكمية والسعر',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    icon: Icons.inventory_2_rounded,
                    label: 'الكمية',
                    value: '${widget.purchase.quantity}',
                    unit: widget.purchase.unit,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBox(
                    icon: Icons.attach_money_rounded,
                    label: 'سعر الوحدة',
                    value: widget.purchase.unitPrice.toStringAsFixed(0),
                    unit: 'ر.ي',
                    color: AppColors.purchases,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purchases.withOpacity(0.1), AppColors.purchases.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.purchases.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.purchase.totalAmount.toStringAsFixed(0)} ر.ي',
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppColors.purchases,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  if (widget.purchase.remainingAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'متبقي',
                            style: TextStyle(fontSize: 11, color: AppColors.danger),
                          ),
                          Text(
                            '${widget.purchase.remainingAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.danger,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Color statusColor) {
    return _AnimatedCard(
      delay: 300,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surface.withOpacity(0.98)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الدفع',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.payment_rounded, 'طريقة الدفع', widget.purchase.paymentMethod, AppColors.primary),
            if (widget.purchase.dueDate != null)
              _buildDetailRow(Icons.event_rounded, 'تاريخ الاستحقاق', widget.purchase.dueDate!, AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return _AnimatedCard(
      delay: 400,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surface.withOpacity(0.98)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.note_rounded, color: AppColors.info, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'ملاحظات',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.purchase.notes!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return _AnimatedCard(
      delay: 500,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(
            context,
            '/debt-payment',
            arguments: {
              'purchaseId': widget.purchase.id,
              'supplierId': widget.purchase.supplierId,
              'remainingAmount': widget.purchase.remainingAmount,
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.success, AppColors.success],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'سداد المبلغ المتبقي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editPurchase() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPurchaseScreen(purchase: widget.purchase),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _cancelPurchase() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'إلغاء المشترى',
      message: 'هل أنت متأكد من إلغاء هذا المشترى؟',
      confirmText: 'إلغاء المشترى',
      cancelText: 'رجوع',
      isDangerous: true,
    );
    if (confirmed == true && widget.purchase.id != null && mounted) {
      context.read<PurchasesBloc>().add(CancelPurchaseEvent(widget.purchase.id!));
      Navigator.of(context).pop(true);
    }
  }

  void _openReturnScreen() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(
      context,
      RouteNames.addReturn,
      arguments: widget.purchase,
    );
  }

  void _printInvoice() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.print_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('جاري طباعة الفاتورة...'),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'مدفوع':
        return AppColors.success;
      case 'مدفوع جزئياً':
        return AppColors.warning;
      case 'غير مدفوع':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _AnimatedCard extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedCard({required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
