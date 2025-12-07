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
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_state.dart';
import '../../blocs/purchases/purchases_bloc.dart';
import '../../blocs/purchases/purchases_state.dart';
import '../../blocs/expenses/expenses_bloc.dart';
import '../../blocs/expenses/expenses_state.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_state.dart';
import '../../blocs/sync/sync_event.dart';
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

    return MultiBlocListener(
      listeners: [
        // الاستماع لنجاح عمليات المبيعات
        BlocListener<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is SaleOperationSuccess) {
              // إعادة تحميل Dashboard
              context.read<DashboardBloc>().add(LoadDashboard());
            }
          },
        ),
        // الاستماع لنجاح عمليات المشتريات
        BlocListener<PurchasesBloc, PurchasesState>(
          listener: (context, state) {
            if (state is PurchaseOperationSuccess) {
              context.read<DashboardBloc>().add(LoadDashboard());
            }
          },
        ),
        // الاستماع لنجاح عمليات المصروفات
        BlocListener<ExpensesBloc, ExpensesState>(
          listener: (context, state) {
            if (state is ExpenseOperationSuccess) {
              context.read<DashboardBloc>().add(LoadDashboard());
            }
          },
        ),
      ],
      child: Directionality(
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
                                child: QuickStatsWidget(
                                  stats: state.dailyStats,
                                  yesterdayStats: state.yesterdayStats,
                                ),
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
                          onAddSale: () =>
                              _navigateWithAnimation(context, RouteNames.sales),
                          onAddPurchase: () => _navigateWithAnimation(
                            context,
                            RouteNames.purchases,
                          ),
                          onAddDebtPayment: () =>
                              _navigateWithAnimation(context, RouteNames.debts),
                          onAddExpense: () => _navigateWithAnimation(
                            context,
                            RouteNames.addExpense,
                          ),
                          onAddReturn: () => _navigateWithAnimation(
                            context,
                            RouteNames.addReturn,
                          ),
                          onAddDamaged: () => _navigateWithAnimation(
                            context,
                            RouteNames.addDamagedItem,
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
                                  RouteNames.activities,
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
    final opacity = (_scrollOffset / 80).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE5E7EB).withOpacity(opacity),
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // أيقونة المتجر
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // العنوان والتحية
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'دفتر المقوت',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
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
          builder: (context, state) {
            final isSyncing = state is SyncInProgress;
            DateTime? lastSyncTime;

            if (state is SyncSuccess) {
              lastSyncTime = DateTime.now();
            } else if (state is SyncPartial) {
              lastSyncTime = DateTime.now();
            }

            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SyncIndicator(
                isSyncing: isSyncing,
                lastSyncTime: lastSyncTime,
                showDetails: false,
                onTap: () => _showSyncBottomSheet(context, state),
              ),
            );
          },
        ),

        // زر الإشعارات
        _buildHeaderAction(
          icon: Icons.notifications_outlined,
          onPressed: () => _showNotificationsSheet(context),
          badge: '3',
        ),

        // زر الإعدادات
        _buildHeaderAction(
          icon: Icons.settings_outlined,
          onPressed: () => _navigateWithAnimation(context, RouteNames.settings),
        ),

        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onPressed,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Stack(
        children: [
          Material(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onPressed();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                child: Icon(icon, color: const Color(0xFF374151), size: 20),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // أيضاً تحديث _buildIconButton القديم ليستخدم النمط الجديد
  Widget _buildIconButton(
    IconData icon, {
    required VoidCallback onPressed,
    String? badge,
  }) {
    return _buildHeaderAction(icon: icon, onPressed: onPressed, badge: badge);
  }

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
      isScrollControlled: true,
      builder: (context) => _QuickActionsBottomSheet(),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    // عرض الإشعارات
  }

  void _showSyncBottomSheet(BuildContext context, SyncState state) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: context.read<SyncBloc>(),
        child: BlocBuilder<SyncBloc, SyncState>(
          builder: (context, state) {
            final isSyncing = state is SyncInProgress;
            DateTime? lastSyncTime;
            int itemsSynced = 0;
            int itemsPending = 0;

            if (state is SyncSuccess) {
              lastSyncTime = DateTime.now();
              itemsSynced = 100;
            } else if (state is SyncPartial) {
              lastSyncTime = DateTime.now();
              itemsSynced = 80;
              itemsPending = 20;
            } else if (state is SyncInProgress) {
              itemsPending = 50;
            }

            return _SyncBottomSheet(
              isSyncing: isSyncing,
              lastSyncTime: lastSyncTime,
              itemsSynced: itemsSynced,
              itemsPending: itemsPending,
              onSync: () {
                context.read<SyncBloc>().add(StartSync(fullSync: true));
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('جاري المزامنة...'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF6366F1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
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

// Bottom Sheet للإجراءات السريعة - محسّن باحترافية عالية مع DraggableScrollableSheet
class _QuickActionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, // يبدأ بـ 70% من الشاشة
      minChildSize: 0.5, // الحد الأدنى 50%
      maxChildSize: 0.95, // الحد الأقصى 95%
      expand: false,
      builder: (context, scrollController) {
        return Container(
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
            children: [
              // Handle Bar - قابل للسحب
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // العنوان
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Text(
                  'إجراء سريع',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 1),
              // القائمة القابلة للتمرير - الآن تستخدم scrollController من DraggableScrollableSheet
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  children: [
                    // 1. بيع سريع
                    _buildQuickAction(
                      context,
                      Icons.point_of_sale,
                      'بيع سريع',
                      AppColors.success,
                      () => Navigator.pushNamed(context, RouteNames.quickSale),
                    ),
                    // 2. بيع لعميل (البيع العادي)
                    _buildQuickAction(
                      context,
                      Icons.shopping_bag,
                      'بيع لعميل',
                      AppColors.sales,
                      () => Navigator.pushNamed(context, RouteNames.addSale),
                    ),
                    // 3. شراء
                    _buildQuickAction(
                      context,
                      Icons.shopping_cart,
                      'شراء',
                      AppColors.purchases,
                      () =>
                          Navigator.pushNamed(context, RouteNames.addPurchase),
                    ),
                    // 4. دفعة دين
                    _buildQuickAction(
                      context,
                      Icons.payments,
                      'دفعة دين',
                      AppColors.primary,
                      () => Navigator.pushNamed(
                        context,
                        RouteNames.addDebtPayment,
                      ),
                    ),
                    // 5. مصروف
                    _buildQuickAction(
                      context,
                      Icons.receipt_long,
                      'مصروف',
                      AppColors.expense,
                      () => Navigator.pushNamed(context, RouteNames.addExpense),
                    ),
                    // 6. مردود
                    _buildQuickAction(
                      context,
                      Icons.assignment_return,
                      'مردود',
                      AppColors.warning,
                      () => Navigator.pushNamed(context, RouteNames.addReturn),
                    ),
                    // 7. تالف
                    _buildQuickAction(
                      context,
                      Icons.broken_image,
                      'تالف',
                      AppColors.danger,
                      () => Navigator.pushNamed(
                        context,
                        RouteNames.addDamagedItem,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

// Bottom Sheet المزامنة المحسّن
class _SyncBottomSheet extends StatelessWidget {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int itemsSynced;
  final int itemsPending;
  final VoidCallback? onSync;

  const _SyncBottomSheet({
    required this.isSyncing,
    this.lastSyncTime,
    this.itemsSynced = 0,
    this.itemsPending = 0,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Header Icon
          _buildHeaderIcon(),

          const SizedBox(height: 20),

          // Title
          Text(
            isSyncing ? 'جاري المزامنة' : 'حالة المزامنة',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),

          const SizedBox(height: 8),

          // Last Sync Time
          if (lastSyncTime != null && !isSyncing)
            Text(
              'آخر مزامنة: ${_formatLastSync(lastSyncTime!)}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),

          if (isSyncing)
            const Text(
              'يرجى الانتظار...',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),

          const SizedBox(height: 28),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'تمت المزامنة',
                  value: itemsSynced.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'في الانتظار',
                  value: itemsPending.toString(),
                  icon: Icons.pending_outlined,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sync Details
          _buildSyncDetails(),

          const SizedBox(height: 24),

          // Sync Button
          _buildSyncButton(context),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon() {
    final color = isSyncing
        ? const Color(0xFF0EA5E9)
        : itemsPending > 0
        ? const Color(0xFFF59E0B)
        : const Color(0xFF16A34A);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Ring
        if (isSyncing)
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.3)),
            ),
          ),

        // Icon Container
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: isSyncing
              ? const _RotatingIcon()
              : Icon(
                  itemsPending > 0
                      ? Icons.cloud_sync_outlined
                      : Icons.cloud_done_outlined,
                  size: 32,
                  color: color,
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.cloud_upload_outlined,
            title: 'البيانات المحلية',
            value: 'متزامنة',
            color: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.cloud_download_outlined,
            title: 'البيانات السحابية',
            value: itemsPending > 0 ? 'يوجد تحديثات' : 'محدثة',
            color: itemsPending > 0
                ? const Color(0xFFF59E0B)
                : const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.wifi_rounded,
            title: 'حالة الاتصال',
            value: 'متصل',
            color: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: isSyncing ? const Color(0xFFE5E7EB) : const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isSyncing
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onSync?.call();
                },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 54,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSyncing) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        isSyncing ? const Color(0xFF9CA3AF) : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(
                  isSyncing ? 'جاري المزامنة...' : 'مزامنة الآن',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSyncing ? const Color(0xFF9CA3AF) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastSync(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'منذ لحظات';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// أيقونة دوارة للمزامنة
class _RotatingIcon extends StatefulWidget {
  const _RotatingIcon();

  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: const Icon(
            Icons.sync_rounded,
            size: 32,
            color: Color(0xFF0EA5E9),
          ),
        );
      },
    );
  }
}
