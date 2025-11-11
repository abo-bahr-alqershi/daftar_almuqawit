import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/sale.dart';

/// شاشة تفاصيل عملية البيع - تصميم Tesla/iOS متطور
class SaleDetailsScreen extends StatefulWidget {
  const SaleDetailsScreen({required this.sale, super.key});
  final Sale sale;

  @override
  State<SaleDetailsScreen> createState() => _SaleDetailsScreenState();
}

class _SaleDetailsScreenState extends State<SaleDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _fabScaleAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _fabScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _headerAnimationController.forward();
    _contentAnimationController.forward();
    _fabAnimationController.forward();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = true);
    } else if (_scrollController.offset <= 100 && _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = false);
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        // خلفية متحركة
        _buildAnimatedBackground(),

        // المحتوى الرئيسي
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header مخصص
            _buildModernHeader(),

            // المحتوى
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _contentFadeAnimation,
                builder: (context, child) => FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: Column(
                    children: [
                      // بطاقة الملخص الرئيسية
                      _buildMainSummaryCard(),

                      // معلومات العميل
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

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // أزرار عائمة
        _buildFloatingActions(),
      ],
    ),
  );

  Widget _buildAnimatedBackground() => Container(
    height: 400,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_getStatusColor().withOpacity(0.1), AppColors.background],
      ),
    ),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        color: Colors.transparent,
        child: CustomPaint(
          painter: _DetailBackgroundPainter(color: _getStatusColor()),
        ),
      ),
    ),
  );

  Widget _buildModernHeader() => SliverAppBar(
    expandedHeight: 200,
    pinned: true,
    backgroundColor: Colors.transparent,
    flexibleSpace: AnimatedBuilder(
      animation: _headerSlideAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _headerSlideAnimation.value),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_getStatusColor(), _getStatusColor().withOpacity(0.8)],
            ),
          ),
          child: FlexibleSpaceBar(
            title: AnimatedOpacity(
              opacity: _isHeaderCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                'فاتورة #${widget.sale.invoiceNumber ?? widget.sale.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            background: _buildHeaderBackground(),
          ),
        ),
      ),
    ),
    leading: _buildBackButton(),
    actions: _buildHeaderActions(),
  );

  Widget _buildBackButton() => Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
    ),
  );

  List<Widget> _buildHeaderActions() => [
    Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        onPressed: _editSale,
      ),
    ),
    Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.share_rounded, color: Colors.white),
        onPressed: _shareSale,
      ),
    ),
  ];

  Widget _buildHeaderBackground() => Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // رقم الفاتورة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'فاتورة #${widget.sale.invoiceNumber ?? widget.sale.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // المبلغ الإجمالي
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.sale.totalAmount),
          duration: const Duration(milliseconds: 1000),
          builder: (context, value, child) => Text(
            '${value.toStringAsFixed(0)} ريال',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // الحالة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.sale.status == 'ملغي'
                    ? 'ملغي'
                    : widget.sale.paymentStatus,
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildMainSummaryCard() => Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        // التاريخ والوقت
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoItem(
              Icons.calendar_today,
              'التاريخ',
              widget.sale.date,
              AppColors.primary,
            ),
            Container(height: 40, width: 1, color: AppColors.border),
            _buildInfoItem(
              Icons.access_time,
              'الوقت',
              widget.sale.time,
              AppColors.accent,
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),

        // ملخص مالي
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAmountItem(
              'المدفوع',
              widget.sale.paidAmount,
              AppColors.success,
            ),
            _buildAmountItem(
              'المتبقي',
              widget.sale.remainingAmount,
              AppColors.warning,
            ),
            _buildAmountItem('الربح', widget.sale.profit, AppColors.info),
          ],
        ),
      ],
    ),
  );

  Widget _buildCustomerInfoCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: widget.sale.customerId != null ? _viewCustomerDetails : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'العميل',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.sale.customerName ?? 'عميل عام',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.sale.totalAmount.toString(),
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.sale.customerId != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textHint,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildProductDetailsCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withOpacity(0.1),
                        AppColors.success.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تفاصيل المنتج',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // نوع القات
            _buildDetailRow(
              'نوع القات',
              widget.sale.qatTypeName ?? 'غير محدد',
              Icons.grass,
            ),

            const SizedBox(height: 12),

            // الكمية
            _buildDetailRow(
              'الكمية',
              '${widget.sale.quantity} ${widget.sale.unit}',
              Icons.shopping_basket,
            ),

            const SizedBox(height: 12),

            // سعر الوحدة
            _buildDetailRow(
              'سعر الوحدة',
              '${widget.sale.unitPrice} ريال',
              Icons.attach_money,
            ),

            if (widget.sale.discount > 0) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                'الخصم',
                '${widget.sale.discount} ريال',
                Icons.discount,
                color: AppColors.danger,
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _buildPaymentInfoCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.info.withOpacity(0.1),
                        AppColors.info.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: AppColors.info,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'معلومات الدفع',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // طريقة الدفع
            _buildDetailRow(
              'طريقة الدفع',
              widget.sale.paymentMethod,
              _getPaymentIcon(widget.sale.paymentMethod),
            ),

            const SizedBox(height: 12),

            // حالة الدفع
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getStatusColor().withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(), color: _getStatusColor()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'حالة الدفع',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.sale.paymentStatus,
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.sale.remainingAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.sale.remainingAmount} ريال',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (widget.sale.dueDate != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                'تاريخ الاستحقاق',
                widget.sale.dueDate!,
                Icons.event,
                color: AppColors.warning,
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _buildNotesCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning.withOpacity(0.1),
                        AppColors.warning.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.note,
                    color: AppColors.warning,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ملاحظات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.sale.notes!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildStatisticsCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.05),
          AppColors.accent.withOpacity(0.02),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem(
              'معدل الربح',
              '${((widget.sale.profit / widget.sale.totalAmount) * 100).toStringAsFixed(1)}%',
              Icons.trending_up,
              AppColors.success,
            ),
            _buildStatItem(
              'حالة البيع',
              widget.sale.isQuickSale ? 'سريع' : 'عادي',
              Icons.flash_on,
              AppColors.accent,
            ),
            _buildStatItem(
              'رقم المرجع',
              '#${widget.sale.id}',
              Icons.tag,
              AppColors.info,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildActionsSection() => Container(
    margin: const EdgeInsets.all(20),
    child: Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'طباعة',
            Icons.print,
            AppColors.primary,
            _printReceipt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'مشاركة',
            Icons.share,
            AppColors.accent,
            _shareSale,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'حذف',
            Icons.delete,
            AppColors.danger,
            _deleteSale,
            isOutlined: true,
          ),
        ),
      ],
    ),
  );

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) => Material(
    color: isOutlined ? Colors.transparent : color,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isOutlined ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isOutlined ? color : Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isOutlined ? color : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildFloatingActions() => Positioned(
    bottom: 20,
    left: 20,
    child: AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _fabScaleAnimation.value,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _editSale();
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    ),
  );

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) => Expanded(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildAmountItem(String label, double value, Color color) => Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value.toStringAsFixed(0),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    ],
  );

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) => Row(
    children: [
      Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
      const SizedBox(width: 12),
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ],
  );

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) => Column(
    children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(color: AppColors.textHint, fontSize: 12),
      ),
    ],
  );

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
        return Icons.check_circle;
      case 'غير مدفوع':
        return Icons.cancel;
      case 'مدفوع جزئياً':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
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

// رسام الخلفية
class _DetailBackgroundPainter extends CustomPainter {
  _DetailBackgroundPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // رسم الدوائر
    for (var i = 0; i < 3; i++) {
      paint.color = color.withOpacity(0.03 - (i * 0.01));
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.3), size.height * (0.3 + i * 0.1)),
        80 + (i * 30).toDouble(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
