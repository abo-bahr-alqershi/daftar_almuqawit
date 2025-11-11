import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/sale.dart';

/// معاينة الفاتورة - تصميم Tesla/iOS متطور
class ReceiptPreview extends StatefulWidget {
  final Sale sale;
  final String? storeName;
  final String? storeAddress;
  final String? storePhone;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  const ReceiptPreview({
    super.key,
    required this.sale,
    this.storeName,
    this.storeAddress,
    this.storePhone,
    this.onPrint,
    this.onShare,
  });

  @override
  State<ReceiptPreview> createState() => _ReceiptPreviewState();
}

class _ReceiptPreviewState extends State<ReceiptPreview>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _stampAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _stampScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _stampAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    _stampScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stampAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimationController.forward();
    _fadeAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      _stampAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _stampAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, AppColors.surface],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Paper Texture Background
              _buildPaperTexture(),

              // Receipt Content
              _buildReceiptContent(),

              // Stamp Effect
              _buildStampEffect(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaperTexture() {
    return Positioned.fill(child: CustomPaint(painter: _PaperTexturePainter()));
  }

  Widget _buildReceiptContent() {
    return Column(
      children: [
        // Header
        _buildReceiptHeader(),

        // Divider with Style
        _buildStyledDivider(),

        // Receipt Details
        _buildReceiptDetails(),

        // Items List
        _buildItemsList(),

        // Totals Section
        _buildTotalsSection(),

        // Footer
        _buildReceiptFooter(),

        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildReceiptHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Store Logo
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 36),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Store Name
          Text(
            widget.storeName ?? 'دفتر المقاولات',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),

          if (widget.storeAddress != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.storeAddress!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],

          if (widget.storePhone != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  widget.storePhone!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStyledDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(
          30,
          (index) => Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: index % 2 == 0
                  ? AppColors.border.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildDetailRow(
            'رقم الفاتورة',
            '#${widget.sale.invoiceNumber ?? widget.sale.id ?? 'N/A'}',
            Icons.receipt,
          ),
          _buildDetailRow('التاريخ', widget.sale.date, Icons.calendar_today),
          _buildDetailRow('الوقت', widget.sale.time, Icons.access_time),
          if (widget.sale.customerName != null)
            _buildDetailRow('العميل', widget.sale.customerName!, Icons.person),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.shopping_basket, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'التفاصيل',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.sale.quantity} ${widget.sale.unit}',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                'x ${widget.sale.unitPrice} ريال',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(widget.sale.quantity * widget.sale.unitPrice).toStringAsFixed(2)} ريال',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (widget.sale.discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الخصم',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.danger,
                  ),
                ),
                Text(
                  '- ${widget.sale.discount} ريال',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.accent.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الكلي',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.sale.totalAmount),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '${value.toStringAsFixed(2)} ريال',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPaymentStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getPaymentIcon(),
                  size: 16,
                  color: _getPaymentStatusColor(),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.sale.paymentMethod,
                  style: TextStyle(
                    color: _getPaymentStatusColor(),
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

  Widget _buildReceiptFooter() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: AppColors.danger.withOpacity(0.5),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'شكراً لتعاملكم معنا',
            style: AppTextStyles.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'نتطلع لخدمتكم مجدداً',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onPrint?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.print),
              label: const Text('طباعة'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onShare?.call();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.share),
              label: const Text('مشاركة'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStampEffect() {
    return Positioned(
      top: 100,
      right: 30,
      child: AnimatedBuilder(
        animation: _stampScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _stampScaleAnimation.value,
            child: Transform.rotate(
              angle: -math.pi / 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success, width: 3),
                ),
                child: Text(
                  'مدفوع',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPaymentStatusColor() {
    switch (widget.sale.paymentStatus) {
      case 'مدفوع':
        return AppColors.success;
      case 'غير مدفوع':
        return AppColors.danger;
      case 'مدفوع جزئياً':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPaymentIcon() {
    switch (widget.sale.paymentMethod) {
      case 'نقد':
      case 'نقدي':
        return Icons.money;
      case 'آجل':
        return Icons.schedule;
      case 'بطاقة':
        return Icons.credit_card;
      case 'تحويل':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}

// رسام نسيج الورق
class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // رسم نسيج الورق
    for (int i = 0; i < 20; i++) {
      paint.color = AppColors.border.withOpacity(0.02);
      canvas.drawLine(
        Offset(0, size.height * i / 20),
        Offset(size.width, size.height * i / 20),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
