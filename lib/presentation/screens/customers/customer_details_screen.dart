import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/customer_debt_card.dart';
import 'widgets/customer_history_tab.dart';
import 'widgets/customer_rating_widget.dart';
import 'edit_customer_screen.dart';

/// شاشة تفاصيل العميل بتصميم راقي ومتطور
class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
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
          AppColors.primary.withOpacity(0.12),
          AppColors.accent.withOpacity(0.08),
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
                  EditCustomerScreen(customer: widget.customer),
            ),
          );
        }),
        _buildActionButton(
          widget.customer.isBlocked ? Icons.lock_open : Icons.lock_outline,
          () => _toggleBlockStatus(context),
        ),
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
                  AppColors.primary.withOpacity(0.15),
                  AppColors.accent.withOpacity(0.10),
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
                    tag: 'customer-avatar-${widget.customer.id}',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.customer.name.isNotEmpty
                              ? widget.customer.name[0].toUpperCase()
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

                  // اسم العميل
                  Text(
                    widget.customer.name,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // حالة العميل
                  _buildStatusChip(widget.customer),
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
                      '${widget.customer.totalPurchases.toStringAsFixed(0)} ريال',
                  icon: Icons.shopping_cart_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedStatCard(
                  delay: 100,
                  label: 'الدين الحالي',
                  value:
                      '${widget.customer.currentDebt.toStringAsFixed(0)} ريال',
                  icon: Icons.account_balance_wallet_rounded,
                  gradient: LinearGradient(
                    colors: widget.customer.currentDebt > 0
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
                  label: 'حد الائتمان',
                  value:
                      '${widget.customer.creditLimit.toStringAsFixed(0)} ريال',
                  icon: Icons.credit_card_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedStatCard(
                  delay: 300,
                  label: 'نوع العميل',
                  value: widget.customer.customerType,
                  icon: Icons.category_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF30cfd0), Color(0xFF330867)],
                  ),
                ),
              ),
            ],
          ),

          // مؤشر استخدام الائتمان
          if (widget.customer.creditLimit > 0) ...[
            const SizedBox(height: 20),
            _buildCreditUtilizationCard(),
          ],
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

  Widget _buildCreditUtilizationCard() {
    final utilization = widget.customer.creditUtilizationPercentage;
    Color progressColor;

    if (utilization >= 100) {
      progressColor = const Color(0xFFf5576c);
    } else if (utilization >= 80) {
      progressColor = const Color(0xFFfee140);
    } else {
      progressColor = const Color(0xFF00f2fe);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'استخدام الائتمان',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${utilization.toStringAsFixed(1)}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.disabled.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (utilization / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [progressColor, progressColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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

  // TabBar بتصميم iOS/Tesla style
  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(6), // زيادة من 4 إلى 6
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
      child: SizedBox(
        height: 48, // تحديد ارتفاع كافي للـ TabBar
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          isScrollable: false,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 1.2,
          ),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 11,
            height: 1.2,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          onTap: (index) => HapticFeedback.selectionClick(),
          tabs: const [
            Tab(
              icon: Icon(Icons.info_outline, size: 16),
              iconMargin: EdgeInsets.only(bottom: 1),
              text: 'التفاصيل',
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet, size: 16),
              iconMargin: EdgeInsets.only(bottom: 1),
              text: 'الديون',
            ),
            Tab(
              icon: Icon(Icons.history, size: 16),
              iconMargin: EdgeInsets.only(bottom: 1),
              text: 'السجل',
            ),
          ],
        ),
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

          // تقييم العميل
          CustomerRatingWidget(
            initialRating: 0,
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
            widget.customer.phone ?? 'غير محدد',
            const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),

          if (widget.customer.nickname != null &&
              widget.customer.nickname!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildModernInfoRow(
              Icons.badge_rounded,
              'الكنية',
              widget.customer.nickname!,
              const LinearGradient(
                colors: [Color(0xFFfa709a), Color(0xFFfee140)],
              ),
            ),
          ],

          if (widget.customer.notes != null &&
              widget.customer.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildModernInfoRow(
              Icons.notes_rounded,
              'ملاحظات',
              widget.customer.notes!,
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
            'إضافة عملية بيع',
            Icons.add_shopping_cart_rounded,
            const LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
            ),
            () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(
                context,
                '/add-sale',
                arguments: {'customerId': widget.customer.id},
              );
            },
          ),

          const SizedBox(height: 12),

          _buildQuickActionButton(
            'سداد دين',
            Icons.payment_rounded,
            LinearGradient(
              colors: widget.customer.currentDebt > 0
                  ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                  : [AppColors.disabled, AppColors.disabled],
            ),
            widget.customer.currentDebt > 0
                ? () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(
                      context,
                      '/debt-payment',
                      arguments: {
                        'customerId': widget.customer.id,
                        'customerName': widget.customer.name,
                        'remainingAmount': widget.customer.currentDebt,
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

  // تبويب الديون
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
              'عرض قائمة الديون الخاصة بالعميل',
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
    return const CustomerHistoryTab(sales: [], payments: [], isLoading: false);
  }

  Widget _buildStatusChip(Customer customer) {
    Color backgroundColor;
    Color textColor;
    String status = customer.getCustomerStatus();
    IconData icon;

    switch (status) {
      case 'محظور':
        backgroundColor = AppColors.danger;
        textColor = Colors.white;
        icon = Icons.block;
        break;
      case 'تجاوز الحد':
        backgroundColor = AppColors.warning;
        textColor = AppColors.textPrimary;
        icon = Icons.warning_rounded;
        break;
      case 'عليه دين':
        backgroundColor = AppColors.info;
        textColor = Colors.white;
        icon = Icons.account_balance_wallet_rounded;
        break;
      default:
        backgroundColor = AppColors.success;
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
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
                'إضافة بيع',
                Icons.point_of_sale_rounded,
                const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                ),
                () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamed(
                    context,
                    '/add-sale',
                    arguments: {'customerId': widget.customer.id},
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

  void _toggleBlockStatus(BuildContext context) async {
    HapticFeedback.mediumImpact();

    final action = widget.customer.isBlocked ? 'إلغاء حظر' : 'حظر';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: '$action العميل',
        message: 'هل أنت متأكد من $action العميل "${widget.customer.name}"؟',
        confirmText: action,
        cancelText: 'إلغاء',
        isDestructive: !widget.customer.isBlocked,
      ),
    );

    if (confirmed == true && widget.customer.id != null) {
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        context.read<CustomersBloc>().add(
          BlockCustomerEvent(widget.customer.id!, !widget.customer.isBlocked),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _showMoreActionsSheet(BuildContext context) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MoreActionsBottomSheet(customer: widget.customer),
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
  final Customer customer;

  const _MoreActionsBottomSheet({required this.customer});

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
            'حذف العميل',
            const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
            ),
            () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
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
}

// Widget لورقة تفاصيل المزامنة (مستورد من home)
class SyncDetailsSheet extends StatelessWidget {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int itemsSynced;
  final int itemsPending;
  final VoidCallback onSync;

  const SyncDetailsSheet({
    super.key,
    required this.isSyncing,
    required this.lastSyncTime,
    required this.itemsSynced,
    required this.itemsPending,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تفاصيل المزامنة',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          if (!isSyncing)
            ElevatedButton(onPressed: onSync, child: const Text('مزامنة الآن')),
        ],
      ),
    );
  }
}
