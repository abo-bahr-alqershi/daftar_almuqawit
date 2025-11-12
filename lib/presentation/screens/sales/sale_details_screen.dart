import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/sale.dart';

/// شاشة تفاصيل عملية البيع - تصميم هادئ وراقي
class SaleDetailsScreen extends StatefulWidget {
  final Sale sale;

  const SaleDetailsScreen({super.key, required this.sale});

  @override
  State<SaleDetailsScreen> createState() => _SaleDetailsScreenState();
}

class _SaleDetailsScreenState extends State<SaleDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _fadeController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),

            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildModernAppBar(topPadding),

                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // بطاقة الملخص الرئيسية
                            _buildMainSummaryCard(),

                            // معلومات العميل
                            if (widget.sale.customerName != null)
                              _buildCustomerInfoCard(),

                            // تفاصيل المنتج
                            _buildProductDetailsCard(),

                            // معلومات الدفع
                            _buildPaymentInfoCard(),

                            // الملاحظات
                            if (widget.sale.notes?.isNotEmpty == true)
                              _buildNotesCard(),

                            // الإحصائيات
                            _buildStatisticsCard(),

                            // الإجراءات
                            _buildActionsSection(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
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
        height: 500,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sales.withOpacity(0.08),
              AppColors.success.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
      );

  Widget _buildModernAppBar(double topPadding) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 2,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: opacity < 0.5
                ? AppColors.surface.withOpacity(0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withOpacity(opacity < 0.5 ? 0.5 : 0),
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: opacity < 0.5
                  ? AppColors.surface.withOpacity(0.9)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withOpacity(opacity < 0.5 ? 0.5 : 0),
              ),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _editSale();
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: opacity < 0.5
                  ? AppColors.surface.withOpacity(0.9)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withOpacity(opacity < 0.5 ? 0.5 : 0),
              ),
            ),
            child: const Icon(
              Icons.share_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _shareSale();
          },
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.sales.withOpacity(0.05),
                AppColors.success.withOpacity(0.03),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.sales,
                              AppColors.success.withOpacity(0.8)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sales.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.sales.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تفاصيل الفاتورة',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'فاتورة #${widget.sale.invoiceNumber ?? widget.sale.id}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
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
    );
  }

  Widget _buildMainSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.sales.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.sales.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.sales.withOpacity(0.15),
                        AppColors.success.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    size: 22,
                    color: AppColors.sales,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ملخص الفاتورة',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // المبلغ الإجمالي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.sales.withOpacity(0.1),
                    AppColors.success.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبلغ الإجمالي',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.sale.totalAmount.toStringAsFixed(0)} ريال',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.sales,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor().withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.sale.status == 'ملغي'
                          ? 'ملغي'
                          : widget.sale.paymentStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // التاريخ والوقت
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today_outlined,
                    'التاريخ',
                    widget.sale.date,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    Icons.access_time_rounded,
                    'الوقت',
                    widget.sale.time,
                    AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(height: 1),

            const SizedBox(height: 20),

            // ملخص مالي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAmountItem(
                  'المدفوع',
                  widget.sale.paidAmount,
                  AppColors.success,
                  Icons.check_circle_outline,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: AppColors.border.withOpacity(0.3),
                ),
                _buildAmountItem(
                  'المتبقي',
                  widget.sale.remainingAmount,
                  AppColors.warning,
                  Icons.pending_outlined,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: AppColors.border.withOpacity(0.3),
                ),
                _buildAmountItem(
                  'الربح',
                  widget.sale.profit,
                  AppColors.info,
                  Icons.trending_up_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.sale.customerId != null
              ? () {
                  HapticFeedback.lightImpact();
                  _viewCustomerDetails();
                }
              : null,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.accent.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العميل',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.sale.customerName ?? 'عميل عام',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.sale.customerId != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withOpacity(0.15),
                        AppColors.success.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 22,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'تفاصيل المنتج',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // نوع القات
            _buildDetailRow(
              'نوع القات',
              widget.sale.qatTypeName ?? 'غير محدد',
              Icons.grass_outlined,
            ),

            const SizedBox(height: 16),

            // الكمية
            _buildDetailRow(
              'الكمية',
              '${widget.sale.quantity} ${widget.sale.unit}',
              Icons.shopping_basket_outlined,
            ),

            const SizedBox(height: 16),

            // سعر الوحدة
            _buildDetailRow(
              'سعر الوحدة',
              '${widget.sale.unitPrice.toStringAsFixed(0)} ريال',
              Icons.attach_money_rounded,
            ),

            if (widget.sale.discount > 0) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                'الخصم',
                '${widget.sale.discount.toStringAsFixed(0)} ريال',
                Icons.discount_outlined,
                color: AppColors.danger,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.info.withOpacity(0.15),
                        AppColors.info.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payment_outlined,
                    size: 22,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'معلومات الدفع',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // طريقة الدفع
            _buildDetailRow(
              'طريقة الدفع',
              widget.sale.paymentMethod,
              _getPaymentIcon(widget.sale.paymentMethod),
            ),

            const SizedBox(height: 20),

            // حالة الدفع
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor().withOpacity(0.1),
                    _getStatusColor().withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة الدفع',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.sale.status == 'ملغي'
                              ? 'ملغي'
                              : widget.sale.paymentStatus,
                          style: AppTextStyles.h3.copyWith(
                            color: _getStatusColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.sale.remainingAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.sale.remainingAmount.toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (widget.sale.dueDate != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                'تاريخ الاستحقاق',
                widget.sale.dueDate!,
                Icons.event_outlined,
                color: AppColors.warning,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning.withOpacity(0.15),
                        AppColors.warning.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.note_outlined,
                    size: 22,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ملاحظات',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.sale.notes!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'معدل الربح',
                  '${((widget.sale.profit / widget.sale.totalAmount) * 100).toStringAsFixed(1)}%',
                  Icons.trending_up_rounded,
                  AppColors.success,
                ),
                _buildStatItem(
                  'نوع البيع',
                  widget.sale.isQuickSale ? 'سريع' : 'عادي',
                  Icons.flash_on_outlined,
                  AppColors.accent,
                ),
                _buildStatItem(
                  'رقم المرجع',
                  '#${widget.sale.id}',
                  Icons.tag_outlined,
                  AppColors.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'طباعة',
              Icons.print_outlined,
              AppColors.primary,
              () {
                HapticFeedback.mediumImpact();
                _printReceipt();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'مشاركة',
              Icons.share_outlined,
              AppColors.accent,
              () {
                HapticFeedback.mediumImpact();
                _shareSale();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'حذف',
              Icons.delete_outline_rounded,
              AppColors.danger,
              () {
                HapticFeedback.mediumImpact();
                _deleteSale();
              },
              isOutlined: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isOutlined
            ? null
            : LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: isOutlined
            ? Border.all(
                color: color.withOpacity(0.5),
                width: 1.5,
              )
            : null,
        boxShadow: isOutlined
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isOutlined ? color : Colors.white,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isOutlined ? color : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem(
      String label, double value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${value.toStringAsFixed(0)}',
          style: AppTextStyles.h3.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (widget.sale.status == 'ملغي') return AppColors.danger;

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

  IconData _getStatusIcon() {
    switch (widget.sale.paymentStatus) {
      case 'مدفوع':
        return Icons.check_circle_rounded;
      case 'غير مدفوع':
        return Icons.cancel_rounded;
      case 'مدفوع جزئياً':
        return Icons.pending_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'نقد':
      case 'نقدي':
        return Icons.money_rounded;
      case 'آجل':
        return Icons.schedule_rounded;
      case 'بطاقة':
        return Icons.credit_card_rounded;
      case 'تحويل':
        return Icons.account_balance_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  void _editSale() {
    Navigator.pushNamed(context, '/edit-sale', arguments: widget.sale);
  }

  void _printReceipt() {
    // طباعة الفاتورة
  }

  void _shareSale() {
    // مشاركة الفاتورة
  }

  void _deleteSale() {
    // حذف الفاتورة
  }

  void _viewCustomerDetails() {
    // عرض تفاصيل العميل
  }
}
