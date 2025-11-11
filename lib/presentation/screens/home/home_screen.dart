import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/home/dashboard_bloc.dart';
import '../../blocs/home/dashboard_event.dart';
import '../../blocs/home/dashboard_state.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_state.dart';
import '../../navigation/route_names.dart';
import 'widgets/menu_grid.dart';
import 'widgets/quick_stats_widget.dart';
import 'widgets/sync_indicator.dart';
import 'widgets/shortcuts_bar.dart';
import 'widgets/recent_activities.dart';

/// الشاشة الرئيسية للتطبيق - تصميم متطور
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // تحميل بيانات لوحة التحكم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(LoadDashboard());
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

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // خلفية متدرجة ديناميكية
            _buildGradientBackground(),

            // المحتوى الرئيسي
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // AppBar مخصص مع تأثيرات
                _buildModernAppBar(topPadding),

                // محتوى الشاشة
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // الإحصائيات السريعة
                      BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          if (state is DashboardLoading) {
                            return _buildShimmerStats();
                          }
                          if (state is DashboardLoaded) {
                            return Hero(
                              tag: 'quick-stats',
                              child: QuickStatsWidget(stats: state.dailyStats),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: 32),

                      // عنوان الاختصارات مع تأثير
                      _buildSectionTitle('اختصارات سريعة', Icons.flash_on),

                      const SizedBox(height: 16),

                      // شريط الاختصارات
                      ShortcutsBar(
                        onQuickSale: () => _navigateWithAnimation(
                          context,
                          RouteNames.quickSale,
                        ),
                        onAddPurchase: () => _navigateWithAnimation(
                          context,
                          RouteNames.purchases,
                        ),
                        onAddExpense: () => _navigateWithAnimation(
                          context,
                          RouteNames.expenses,
                        ),
                        onViewReports: () => _navigateWithAnimation(
                          context,
                          RouteNames.statistics,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // عنوان القائمة الرئيسية
                      _buildSectionTitle('القائمة الرئيسية', Icons.apps),

                      const SizedBox(height: 16),

                      // شبكة القوائم
                      const MenuGrid(),

                      const SizedBox(height: 32),

                      // النشاطات الأخيرة
                      BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          if (state is DashboardLoaded) {
                            final activities = _buildActivitiesFromData(
                              state.todaySales,
                              state.todayPurchases,
                            );
                            return RecentActivities(
                              activities: activities,
                              onViewAll: () => _navigateWithAnimation(
                                context,
                                RouteNames.statistics,
                              ),
                            );
                          }
                          return const RecentActivities(activities: []);
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),

            // زر عائم متطور
            _buildFloatingActionButton(context),
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
          AppColors.primary.withOpacity(0.08),
          AppColors.accent.withOpacity(0.05),
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
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
                      // صورة المستخدم أو أيقونة
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'دفتر المقوت',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGreeting(),
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
      actions: [
        // مؤشر المزامنة
        BlocBuilder<SyncBloc, SyncState>(
          builder: (context, state) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SyncIndicator(
              isSyncing: state is SyncInProgress,
              lastSyncTime: state is SyncSuccess ? DateTime.now() : null,
              onTap: () => _showSyncBottomSheet(context),
            ),
          ),
        ),

        // زر الإشعارات
        _buildIconButton(
          Icons.notifications_outlined,
          onPressed: () => _showNotificationsSheet(context),
          badge: '3',
        ),

        // زر الإعدادات
        _buildIconButton(
          Icons.settings_outlined,
          onPressed: () => _navigateWithAnimation(context, RouteNames.settings),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    required VoidCallback onPressed,
    String? badge,
  }) => Stack(
    children: [
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: onPressed,
      ),
      if (badge != null)
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  );

  Widget _buildSectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
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
      ],
    ),
  );

  Widget _buildShimmerStats() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    height: 180,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildFloatingActionButton(BuildContext context) => Positioned(
    bottom: 20,
    left: 20,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: () => _showQuickActionsSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إضافة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 8,
      ),
    ),
  );

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير 🌅';
    if (hour < 18) return 'مساء الخير ☀️';
    return 'مساء الخير 🌙';
  }

  void _navigateWithAnimation(BuildContext context, String routeName) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, routeName);
  }

  void _showQuickActionsSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickActionsBottomSheet(),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    // عرض الإشعارات
  }

  void _showSyncBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    // عرض تفاصيل المزامنة
  }

  List<ActivityItem> _buildActivitiesFromData(
    List<Sale> sales,
    List<Purchase> purchases,
  ) {
    final activities = <ActivityItem>[];

    for (final sale in sales.take(5)) {
      activities.add(
        ActivityItem(
          title:
              'بيع ${sale.qatTypeName ?? "قات"} - ${sale.quantity} ${sale.unit}',
          time: _formatTime(sale.time),
          icon: Icons.point_of_sale_rounded,
          color: AppColors.success,
          amount: '${sale.totalAmount.toStringAsFixed(0)} ريال',
          status: sale.paymentStatus,
        ),
      );
    }

    for (final purchase in purchases.take(5)) {
      activities.add(
        ActivityItem(
          title:
              'شراء ${purchase.qatTypeName ?? "قات"} - ${purchase.quantity} ${purchase.unit}',
          time: _formatTime(purchase.time),
          icon: Icons.shopping_cart_rounded,
          color: AppColors.info,
          amount: '${purchase.totalAmount.toStringAsFixed(0)} ريال',
          status: purchase.paymentStatus,
        ),
      );
    }

    activities.sort((a, b) {
      final aTime = _parseTime(a.time);
      final bTime = _parseTime(b.time);
      return bTime.compareTo(aTime);
    });

    return activities.take(10).toList();
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        final time = DateTime(now.year, now.month, now.day, hour, minute);
        final diff = now.difference(time);

        if (diff.inMinutes < 1) {
          return 'الآن';
        } else if (diff.inMinutes < 60) {
          return 'منذ ${diff.inMinutes} دقيقة';
        } else if (diff.inHours < 24) {
          return 'منذ ${diff.inHours} ساعة';
        } else {
          return timeStr;
        }
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  DateTime _parseTime(String timeStr) {
    try {
      if (timeStr.contains('الآن')) {
        return DateTime.now();
      } else if (timeStr.contains('منذ')) {
        final parts = timeStr.split(' ');
        if (parts.length >= 2) {
          final value = int.tryParse(parts[1]) ?? 0;
          if (timeStr.contains('دقيقة')) {
            return DateTime.now().subtract(Duration(minutes: value));
          } else if (timeStr.contains('ساعة')) {
            return DateTime.now().subtract(Duration(hours: value));
          }
        }
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }
}

// Bottom Sheet للإجراءات السريعة
class _QuickActionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, -5),
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
          'إجراء سريع',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        _buildQuickAction(
          context,
          Icons.point_of_sale,
          'بيع سريع',
          AppColors.success,
          () => Navigator.pushNamed(context, RouteNames.quickSale),
        ),
        _buildQuickAction(
          context,
          Icons.shopping_cart,
          'إضافة مشتريات',
          AppColors.info,
          () => Navigator.pushNamed(context, RouteNames.purchases),
        ),
        _buildQuickAction(
          context,
          Icons.person_add,
          'عميل جديد',
          AppColors.primary,
          () => Navigator.pushNamed(context, RouteNames.customers),
        ),
        _buildQuickAction(
          context,
          Icons.receipt_long,
          'إضافة مصروف',
          AppColors.expense,
          () => Navigator.pushNamed(context, RouteNames.expenses),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) => ListTile(
    onTap: () {
      HapticFeedback.lightImpact();
      Navigator.pop(context);
      onTap();
    },
    leading: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    ),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: AppColors.textHint,
    ),
  );
}
