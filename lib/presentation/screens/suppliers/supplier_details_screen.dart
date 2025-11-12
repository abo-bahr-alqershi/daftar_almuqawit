import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/supplier.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/supplier_rating_widget.dart';
import 'edit_supplier_screen.dart';

/// شاشة تفاصيل المورد بتصميم راقي ومتطور
class SupplierDetailsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailsScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _tabsAnimationController;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    // تهيئة التحكم في التبويبات
    _tabController = TabController(length: 3, vsync: this);

    // تهيئة controllers الأنيميشن
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _tabsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // بدء الأنيميشن
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _statsAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _tabsAnimationController.forward();
    });

    // مراقبة التمرير
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    _tabsAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // خلفية متدرجة راقية
            _buildGradientBackground(),

            // المحتوى الرئيسي
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // SliverAppBar مع تأثيرات gradient راقية
                _buildModernSliverAppBar(),

                // بطاقات الإحصائيات
                SliverToBoxAdapter(child: _buildStatsSection()),

                // TabBar بتصميم iOS/Tesla
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    tabBar: _buildModernTabBar(),
                    animation: _tabsAnimationController,
                  ),
                ),

                // محتوى التبويبات
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDetailsTab(),
                      _buildDebtsTab(),
                      _buildHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),

            // أزرار الإجراءات العائمة
            _buildFloatingActions(),
          ],
        ),
      ),
    );
  }

  // خلفية متدرجة راقية
  Widget _buildGradientBackground() => Container(
    height: 500,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.info.withOpacity(0.12),
          AppColors.info.withOpacity(0.08),
          Colors.transparent,
        ],
      ),
    ),
  );

  // SliverAppBar متطور مع gradient راقي
  Widget _buildModernSliverAppBar() {
    final opacity = (_scrollOffset / 120).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: opacity * 4,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      actions: [
        _buildActionButton(Icons.edit_outlined, () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  EditSupplierScreen(supplier: widget.supplier),
            ),
          );
        }),
        _buildActionButton(
          Icons.more_vert,
          () => _showMoreActionsSheet(context),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _headerAnimationController,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.info.withOpacity(0.15),
                  AppColors.info.withOpacity(0.10),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Hero animation للصورة الشخصية
                  Hero(
                    tag: 'supplier-avatar-${widget.supplier.id}',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.info, Color(0xFF0284c7)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.info.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.supplier.name.isNotEmpty
                              ? widget.supplier.name[0].toUpperCase()
                              : '؟',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // اسم المورد
                  Text(
                    widget.supplier.name,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // حالة المورد
                  _buildStatusChip(widget.supplier),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // قسم الإحصائيات بتصميم modern مع staggered animation
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // الصف الأول من الإحصائيات
          Row(
            children: [
              Expanded(
                child: _buildAnimatedStatCard(
                  delay: 0,
                  label: 'إجمالي المشتريات',
                  value:
                      '${widget.supplier.totalPurchases.toStringAsFixed(0)} ريال',
                  icon: Icons.shopping_bag_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedStatCard(
                  delay: 100,
                  label: 'الدين له',
                  value:
                      '${widget.supplier.totalDebtToHim.toStringAsFixed(0)} ريال',
                  icon: Icons.account_balance_wallet_rounded,
                  gradient: LinearGradient(
                    colors: widget.supplier.totalDebtToHim > 0
                        ? [const Color(0xFFf093fb), const Color(0xFFf5576c)]
                        : [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // الصف الثاني من الإحصائيات
          Row(
            children: [
              Expanded(
                child: _buildAnimatedStatCard(
                  delay: 200,
                  label: 'تقييم الجودة',
                  value: '${widget.supplier.qualityRating} / 5',
                  icon: Icons.star_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedStatCard(
                  delay: 300,
                  label: 'مستوى الثقة',
                  value: widget.supplier.trustLevel,
                  icon: Icons.verified_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF30cfd0), Color(0xFF330867)],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard({
    required int delay,
    required String label,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return AnimatedBuilder(
      animation: _statsAnimationController,
      builder: (context, child) {
        // حساب begin و end بشكل صحيح مع التأكد من عدم تجاوز 1.0
        final begin = (delay / 400).clamp(0.0, 1.0);
        final end = ((delay + 200) / 400).clamp(0.0, 1.0);

        final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _statsAnimationController,
            curve: Interval(begin, end, curve: Curves.easeOutCubic),
          ),
        );

        return Transform.translate(
          offset: Offset(0, 30 * (1 - delayedAnimation.value)),
          child: Opacity(opacity: delayedAnimation.value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TabBar بتصميم iOS/Tesla style
  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        // زيادة ارتفاع الـ Tab لاستيعاب Icon و Text
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: false,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.info, Color(0xFF0284c7)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.info.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12, // تصغير الخط قليلاً
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        onTap: (index) => HapticFeedback.selectionClick(),
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline, size: 18),
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'التفاصيل',
          ),
          Tab(
            icon: Icon(Icons.account_balance_wallet, size: 18),
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'الديون له',
          ),
          Tab(
            icon: Icon(Icons.history, size: 18),
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'السجل',
          ),
        ],
      ),
    );
  }

  // تبويب التفاصيل
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // بطاقة المعلومات الأساسية
          _buildModernInfoCard(),

          const SizedBox(height: 20),

          // تقييم المورد
          SupplierRatingWidget(
            initialRating: widget.supplier.qualityRating.toDouble(),
            onRatingChanged: (rating) {
              HapticFeedback.lightImpact();
            },
            readOnly: false,
            showLabel: true,
          ),

          const SizedBox(height: 20),

          // الإجراءات السريعة
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الاتصال',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),

          _buildModernInfoRow(
            Icons.phone_rounded,
            'رقم الهاتف',
            widget.supplier.phone ?? 'غير محدد',
            const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),

          if (widget.supplier.area != null &&
              widget.supplier.area!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildModernInfoRow(
              Icons.location_on_rounded,
              'المنطقة',
              widget.supplier.area!,
              const LinearGradient(
                colors: [Color(0xFFfa709a), Color(0xFFfee140)],
              ),
            ),
          ],

          if (widget.supplier.notes != null &&
              widget.supplier.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildModernInfoRow(
              Icons.notes_rounded,
              'ملاحظات',
              widget.supplier.notes!,
              const LinearGradient(
                colors: [Color(0xFF30cfd0), Color(0xFF330867)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(
    IconData icon,
    String label,
    String value,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),

          _buildQuickActionButton(
            'إضافة عملية شراء',
            Icons.add_shopping_cart_rounded,
            const LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
            ),
            () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(
                context,
                '/add-purchase',
                arguments: {'supplierId': widget.supplier.id},
              );
            },
          ),

          const SizedBox(height: 12),

          _buildQuickActionButton(
            'سداد دين له',
            Icons.payment_rounded,
            LinearGradient(
              colors: widget.supplier.totalDebtToHim > 0
                  ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                  : [AppColors.disabled, AppColors.disabled],
            ),
            widget.supplier.totalDebtToHim > 0
                ? () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(
                      context,
                      '/supplier-debt-payment',
                      arguments: {
                        'supplierId': widget.supplier.id,
                        'supplierName': widget.supplier.name,
                        'remainingAmount': widget.supplier.totalDebtToHim,
                      },
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Gradient gradient,
    VoidCallback? onPressed,
  ) {
    final isEnabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isEnabled ? gradient : null,
          color: isEnabled ? null : AppColors.disabled.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled ? Colors.white : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isEnabled ? Colors.white : AppColors.textHint,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تبويب الديون له
  Widget _buildDebtsTab() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'قريباً',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'عرض قائمة الديون المستحقة للمورد',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // تبويب السجل
  Widget _buildHistoryTab() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'قريباً',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'عرض سجل المشتريات والمدفوعات',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Supplier supplier) {
    Color backgroundColor;
    Color textColor;
    String status;
    IconData icon;

    if (supplier.totalDebtToHim > 0) {
      backgroundColor = AppColors.danger;
      textColor = Colors.white;
      status = 'لديه دين';
      icon = Icons.account_balance_wallet_rounded;
    } else if (supplier.qualityRating >= 4) {
      backgroundColor = AppColors.success;
      textColor = Colors.white;
      status = 'ممتاز';
      icon = Icons.verified_rounded;
    } else if (supplier.qualityRating >= 3) {
      backgroundColor = AppColors.info;
      textColor = Colors.white;
      status = 'جيد';
      icon = Icons.star_rounded;
    } else {
      backgroundColor = AppColors.warning;
      textColor = AppColors.textPrimary;
      status = 'متوسط';
      icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: AppTextStyles.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // أزرار عائمة راقية
  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _buildFloatingButton(
                'إضافة شراء',
                Icons.shopping_cart_rounded,
                const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                ),
                () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamed(
                    context,
                    '/add-purchase',
                    arguments: {'supplierId': widget.supplier.id},
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            _buildFloatingIconButton(
              Icons.more_horiz_rounded,
              const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              () {
                HapticFeedback.mediumImpact();
                _showMoreActionsSheet(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(
    String label,
    IconData icon,
    Gradient gradient,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIconButton(
    IconData icon,
    Gradient gradient,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  void _showMoreActionsSheet(BuildContext context) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MoreActionsBottomSheet(supplier: widget.supplier),
    );
  }
}

// Delegate للـ TabBar اللاصق
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;
  final AnimationController animation;

  _StickyTabBarDelegate({required this.tabBar, required this.animation});

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return FadeTransition(
      opacity: animation,
      child: Container(color: AppColors.background, child: tabBar),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

// Bottom Sheet للإجراءات الإضافية
class _MoreActionsBottomSheet extends StatelessWidget {
  final Supplier supplier;

  const _MoreActionsBottomSheet({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'المزيد من الإجراءات',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 24),

          _buildActionItem(
            context,
            Icons.share_rounded,
            'مشاركة',
            const LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
            ),
            () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),

          _buildActionItem(
            context,
            Icons.print_rounded,
            'طباعة',
            const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),

          _buildActionItem(
            context,
            Icons.delete_rounded,
            'حذف المورد',
            const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
            ),
            () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              _confirmDeleteSupplier(context);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String title,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSupplier(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'حذف المورد',
        message: 'هل أنت متأكد من حذف المورد "${supplier.name}"؟',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed == true && supplier.id != null) {
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        context.read<SuppliersBloc>().add(
              DeleteSupplierEvent(supplier.id!),
            );
        Navigator.of(context).pop();
      }
    }
  }
}
