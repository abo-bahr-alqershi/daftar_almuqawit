import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/home/dashboard_bloc.dart';
import '../../blocs/home/dashboard_event.dart';
import '../../blocs/home/dashboard_state.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import 'widgets/quick_stats_widget.dart';
import 'widgets/sync_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _statsAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _statsScaleAnimation;
  late Animation<double> _cardsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadDashboard();

    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _statsScaleAnimation = CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.elasticOut,
    );

    _cardsFadeAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeInOut,
    );

    _statsAnimationController.forward();
    _cardsAnimationController.forward();
  }

  @override
  void dispose() {
    _statsAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  void _loadDashboard() {
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: ui.TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // خلفية متحركة
          _buildAnimatedBackground(),

          // المحتوى الرئيسي
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // AppBar مخصص
              _buildCustomAppBar(),

              // محتوى لوحة التحكم
              SliverToBoxAdapter(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return _buildLoadingState();
                    }

                    if (state is DashboardError) {
                      return _buildErrorState(state);
                    }

                    if (state is DashboardLoaded) {
                      return _buildDashboardContent(state);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildAnimatedBackground() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withOpacity(0.03),
          AppColors.accent.withOpacity(0.02),
          AppColors.background,
        ],
      ),
    ),
    child: CustomPaint(
      painter: _BackgroundPainter(),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    ),
  );

  Widget _buildCustomAppBar() => SliverAppBar(
    expandedHeight: 120,
    floating: true,
    snap: true,
    backgroundColor: Colors.transparent,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surface.withOpacity(0.9)],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // أيقونة لوحة التحكم
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // العنوان
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'لوحة التحكم',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCurrentDateFormatted(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // أزرار الإجراءات
                    BlocBuilder<SyncBloc, SyncState>(
                      builder: (context, state) => SyncIndicator(
                        isSyncing: state is SyncInProgress,
                        lastSyncTime: state is SyncSuccess
                            ? DateTime.now()
                            : null,
                        onTap: () => _showSyncDetails(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      Icons.refresh_rounded,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _loadDashboard();
                      },
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

  Widget _buildActionButton(IconData icon, {required VoidCallback onPressed}) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: AppColors.primary),
          onPressed: onPressed,
        ),
      );

  Widget _buildLoadingState() => Container(
    height: 600,
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Loading Animation
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
          'جاري تحميل البيانات...',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorState(DashboardError state) => Container(
    height: 600,
    padding: const EdgeInsets.all(20),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon with Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
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
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadDashboard();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded),
                SizedBox(width: 8),
                Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildDashboardContent(DashboardLoaded state) => RefreshIndicator(
    onRefresh: () async {
      _loadDashboard();
    },
    color: AppColors.primary,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // الإحصائيات السريعة مع Animation
          ScaleTransition(
            scale: _statsScaleAnimation,
            child: QuickStatsWidget(
              stats: state.dailyStats,
              yesterdayStats: state.yesterdayStats,
            ),
          ),

          const SizedBox(height: 32),

          // العنوان مع أيقونة
          _buildSectionHeader('الإحصائيات التفصيلية', Icons.analytics_rounded),

          const SizedBox(height: 20),

          // الإحصائيات التفصيلية مع Animation
          FadeTransition(
            opacity: _cardsFadeAnimation,
            child: _buildDetailedStats(state),
          ),

          const SizedBox(height: 32),

          // العنوان مع أيقونة
          _buildSectionHeader('الوصول السريع', Icons.touch_app_rounded),

          const SizedBox(height: 20),

          // الإجراءات السريعة
          FadeTransition(
            opacity: _cardsFadeAnimation,
            child: _buildQuickActions(),
          ),

          const SizedBox(height: 32),

          // إحصائيات إضافية
          _buildAdditionalInsights(state),
        ],
      ),
    ),
  );

  Widget _buildSectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const Spacer(),
        const TextButton(
          onPressed: HapticFeedback.lightImpact,
          child: Text(
            'عرض الكل',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildDetailedStats(DashboardLoaded state) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ModernStatCard(
                title: 'المبيعات',
                value: state.dailyStats.totalSales.toStringAsFixed(0),
                subtitle: 'ريال',
                icon: Icons.trending_up_rounded,
                color: AppColors.sales,
                trend: '+12%',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ModernStatCard(
                title: 'المشتريات',
                value: state.dailyStats.totalPurchases.toStringAsFixed(0),
                subtitle: 'ريال',
                icon: Icons.shopping_cart_rounded,
                color: AppColors.purchases,
                trend: '+5%',
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ModernStatCard(
                title: 'المصروفات',
                value: state.dailyStats.totalExpenses.toStringAsFixed(0),
                subtitle: 'ريال',
                icon: Icons.payment_rounded,
                color: AppColors.expense,
                trend: '-8%',
                isPositive: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ModernStatCard(
                title: 'صافي الربح',
                value: state.dailyStats.netProfit.toStringAsFixed(0),
                subtitle: 'ريال',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
                trend: '+15%',
                isPositive: true,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildQuickActions() => SizedBox(
    height: 280,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _ModernQuickActionCard(
          icon: Icons.flash_on_rounded,
          label: 'بيع سريع',
          description: 'إضافة عملية بيع جديدة',
          color: AppColors.success,
          onTap: () => Navigator.pushNamed(context, RouteNames.quickSale),
        ),
        const SizedBox(width: 16),
        _ModernQuickActionCard(
          icon: Icons.shopping_bag_rounded,
          label: 'شراء جديد',
          description: 'تسجيل عملية شراء',
          color: AppColors.purchases,
          onTap: () => Navigator.pushNamed(context, RouteNames.purchases),
        ),
        const SizedBox(width: 16),
        _ModernQuickActionCard(
          icon: Icons.person_add_rounded,
          label: 'عميل جديد',
          description: 'إضافة عميل للنظام',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, RouteNames.customers),
        ),
        const SizedBox(width: 16),
        _ModernQuickActionCard(
          icon: Icons.bar_chart_rounded,
          label: 'التقارير',
          description: 'عرض التقارير المفصلة',
          color: AppColors.info,
          onTap: () => Navigator.pushNamed(context, RouteNames.statistics),
        ),
      ],
    ),
  );

  Widget _buildAdditionalInsights(DashboardLoaded state) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.accent.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'رؤى سريعة',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightItem(
            'أفضل يوم في الأسبوع',
            'الخميس',
            Icons.calendar_today_rounded,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'متوسط قيمة الفاتورة',
            '2,450 ريال',
            Icons.receipt_rounded,
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'عدد العملاء النشطين',
            '45 عميل',
            Icons.people_rounded,
            AppColors.accent,
          ),
        ],
      ),
    ),
  );

  Widget _buildInsightItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Row(
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
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  String _getCurrentDateFormatted() {
    final now = DateTime.now();
    final days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _showSyncDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    // عرض تفاصيل المزامنة
  }
}

// بطاقة الإحصائيات المحسنة
class _ModernStatCard extends StatelessWidget {
  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositive,
  });
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? isPositive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.08),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            if (trend != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ?? true)
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      (isPositive ?? true)
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: (isPositive ?? true)
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend!,
                      style: TextStyle(
                        color: (isPositive ?? true)
                            ? AppColors.success
                            : AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// بطاقة الإجراء السريع المحسنة
class _ModernQuickActionCard extends StatelessWidget {
  const _ModernQuickActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'ابدأ الآن',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, color: color, size: 18),
            ],
          ),
        ],
      ),
    ),
  );
}

// رسام الخلفية المخصص
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // رسم دوائر الخلفية
    paint.color = AppColors.primary.withOpacity(0.03);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.1), 150, paint);

    paint.color = AppColors.accent.withOpacity(0.02);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 200, paint);

    paint.color = AppColors.success.withOpacity(0.02);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7), 180, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
