import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/home/dashboard_bloc.dart';
import '../../blocs/home/dashboard_event.dart';
import '../../blocs/home/dashboard_state.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/purchase.dart';
import 'widgets/recent_activities.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _filterAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _filterSlideAnimation;
  late Animation<double> _listFadeAnimation;

  String _filterType = 'all';
  String _selectedPeriod = 'today';
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterSlideAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );

    _listFadeAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeIn,
    );

    context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
    _listAnimationController.forward();

    _tabController.addListener(() {
      HapticFeedback.selectionClick();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Stack(
      children: [
        // خلفية متدرجة
        _buildGradientBackground(),

        // المحتوى الرئيسي
        SafeArea(
          child: Column(
            children: [
              // Header مخصص
              _buildCustomHeader(),

              // TabBar متطور
              _buildModernTabBar(),

              // Filter Bar
              _buildFilterBar(),

              // المحتوى
              Expanded(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return _buildLoadingState();
                    }

                    if (state is DashboardError) {
                      return _buildErrorState(state);
                    }

                    if (state is DashboardLoaded) {
                      return FadeTransition(
                        opacity: _listFadeAnimation,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildAllActivities(state),
                            _buildSalesActivities(state.todaySales),
                            _buildPurchasesActivities(state.todayPurchases),
                          ],
                        ),
                      );
                    }

                    return _buildEmptyState(
                      'لا توجد بيانات',
                      Icons.inbox_rounded,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Floating Filter Button
        _buildFloatingFilterButton(),
      ],
    ),
  );

  Widget _buildGradientBackground() => Container(
    height: 300,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.05),
          AppColors.accent.withOpacity(0.02),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildCustomHeader() => Container(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        // زر الرجوع
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(width: 16),

        // العنوان
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سجل النشاطات',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoaded) {
                    final totalActivities =
                        state.todaySales.length + state.todayPurchases.length;
                    return Text(
                      '$totalActivities نشاط مسجل',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),

        // أزرار الإجراءات
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => _showSearchSheet(context),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _exportActivities,
          ),
        ),
      ],
    ),
  );

  Widget _buildModernTabBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.all(6),
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      tabs: const [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.dashboard_rounded, size: 18),
              SizedBox(width: 8),
              Text('الكل'),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up_rounded, size: 18),
              SizedBox(width: 8),
              Text('المبيعات'),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_rounded, size: 18),
              SizedBox(width: 8),
              Text('المشتريات'),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildFilterBar() => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: _isFilterExpanded ? 80 : 0,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('الكل', 'all'),
          const SizedBox(width: 12),
          _buildFilterChip('اليوم', 'today'),
          const SizedBox(width: 12),
          _buildFilterChip('الأسبوع', 'week'),
          const SizedBox(width: 12),
          _buildFilterChip('الشهر', 'month'),
          const SizedBox(width: 12),
          _buildFilterChip('السنة', 'year'),
          const SizedBox(width: 12),
          _buildDateRangeChip(),
        ],
      ),
    ),
  );

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedPeriod == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedPeriod = value;
          _filterType = value;
        });
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border.withOpacity(0.3)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeChip() => GestureDetector(
    onTap: () async {
      HapticFeedback.selectionClick();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        ),
      );

      if (picked != null) {
        // تطبيق الفلتر بالتاريخ المحدد
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8),
          Text(
            'تحديد فترة',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildFloatingFilterButton() => Positioned(
    bottom: 20,
    left: 20,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _isFilterExpanded = !_isFilterExpanded;
            if (_isFilterExpanded) {
              _filterAnimationController.forward();
            } else {
              _filterAnimationController.reverse();
            }
          });
        },
        backgroundColor: AppColors.primary,
        child: AnimatedRotation(
          turns: _isFilterExpanded ? 0.125 : 0,
          duration: const Duration(milliseconds: 300),
          child: const Icon(Icons.filter_list_rounded, color: Colors.white),
        ),
      ),
    ),
  );

  Widget _buildLoadingState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shimmer loading effect
        ...List.generate(5, (index) => _buildShimmerCard()),
      ],
    ),
  );

  Widget _buildShimmerCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorState(DashboardError state) => Center(
    child: Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error animation
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
            state.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<DashboardBloc>().add(
                LoadRecentActivities(limit: 50),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAllActivities(DashboardLoaded state) {
    final activities = _buildActivityList(state);

    if (activities.isEmpty) {
      return _buildEmptyState('لا توجد نشاطات', Icons.inbox_rounded);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: _ModernActivityCard(
                  activity: activity,
                  onTap: () => _showActivityDetails(activity),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSalesActivities(List<Sale> sales) {
    if (sales.isEmpty) {
      return _buildEmptyState('لا توجد مبيعات', Icons.shopping_cart_rounded);
    }

    final activities = sales
        .map(
          (sale) => ActivityItem(
            title:
                'مبيعة ${sale.customerName != null ? "إلى ${sale.customerName}" : ""}',
            time: sale.date,
            icon: Icons.shopping_cart_rounded,
            color: AppColors.success,
            amount: '${sale.totalAmount.toStringAsFixed(2)} ريال',
          ),
        )
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _ModernActivityCard(
            activity: activity,
            onTap: () => _showActivityDetails(activity),
          );
        },
      ),
    );
  }

  Widget _buildPurchasesActivities(List<Purchase> purchases) {
    if (purchases.isEmpty) {
      return _buildEmptyState(
        'لا توجد مشتريات',
        Icons.add_shopping_cart_rounded,
      );
    }

    final activities = purchases
        .map(
          (purchase) => ActivityItem(
            title:
                'مشترى ${purchase.supplierName != null ? "من ${purchase.supplierName}" : ""}',
            time: purchase.date,
            icon: Icons.add_shopping_cart_rounded,
            color: AppColors.warning,
            amount: '${purchase.totalAmount.toStringAsFixed(2)} ريال',
          ),
        )
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _ModernActivityCard(
            activity: activity,
            onTap: () => _showActivityDetails(activity),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) => Center(
    child: Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state animation
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
                child: Icon(icon, size: 70, color: AppColors.textHint),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            'ابدأ بإضافة نشاطات جديدة',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/quick-sale');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'إضافة نشاط',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );

  List<ActivityItem> _buildActivityList(DashboardLoaded state) {
    final activities = <ActivityItem>[];

    for (final sale in state.todaySales) {
      activities.add(
        ActivityItem(
          title:
              'مبيعة ${sale.customerName != null ? "إلى ${sale.customerName}" : ""}',
          time: sale.date,
          icon: Icons.shopping_cart_rounded,
          color: AppColors.success,
          amount: '${sale.totalAmount.toStringAsFixed(2)} ريال',
        ),
      );
    }

    for (final purchase in state.todayPurchases) {
      activities.add(
        ActivityItem(
          title:
              'مشترى ${purchase.supplierName != null ? "من ${purchase.supplierName}" : ""}',
          time: purchase.date,
          icon: Icons.add_shopping_cart_rounded,
          color: AppColors.warning,
          amount: '${purchase.totalAmount.toStringAsFixed(2)} ريال',
        ),
      );
    }

    activities.sort((a, b) => b.time.compareTo(a.time));

    return _applyFilter(activities);
  }

  List<ActivityItem> _applyFilter(List<ActivityItem> activities) {
    final now = DateTime.now();

    switch (_filterType) {
      case 'today':
        return activities.where((activity) {
          final activityDate = _parseTime(activity.time);
          return activityDate.year == now.year &&
              activityDate.month == now.month &&
              activityDate.day == now.day;
        }).toList();

      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return activities.where((activity) {
          final activityDate = _parseTime(activity.time);
          return activityDate.isAfter(weekAgo);
        }).toList();

      case 'month':
        return activities.where((activity) {
          final activityDate = _parseTime(activity.time);
          return activityDate.year == now.year &&
              activityDate.month == now.month;
        }).toList();

      case 'year':
        return activities.where((activity) {
          final activityDate = _parseTime(activity.time);
          return activityDate.year == now.year;
        }).toList();

      default:
        return activities;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} شهور';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  DateTime _parseTime(String time) {
    // Parse time string to DateTime
    // This is a simplified implementation
    return DateTime.now();
  }

  void _showActivityDetails(ActivityItem activity) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityDetailsSheet(activity: activity),
    );
  }

  void _showSearchSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    // Implement search functionality
  }

  void _exportActivities() {
    HapticFeedback.mediumImpact();
    // Implement export functionality
  }
}

// بطاقة النشاط المحسنة
class _ModernActivityCard extends StatelessWidget {
  const _ModernActivityCard({required this.activity, this.onTap});
  final ActivityItem activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activity.color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: activity.color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activity.color.withOpacity(0.15),
                  activity.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(activity.icon, color: activity.color, size: 28),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          if (activity.amount != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity.amount!.split(' ')[0],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: activity.color,
                  ),
                ),
                Text(
                  activity.amount!.split(' ')[1],
                  style: TextStyle(
                    fontSize: 12,
                    color: activity.color.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

          const SizedBox(width: 8),
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

// Sheet تفاصيل النشاط
class _ActivityDetailsSheet extends StatelessWidget {
  const _ActivityDetailsSheet({required this.activity});
  final ActivityItem activity;

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.7,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activity.color.withOpacity(0.15),
                      activity.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(activity.icon, color: activity.color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('المبلغ', activity.amount ?? '0 ريال'),
                _buildDetailItem('الحالة', 'مكتمل'),
                _buildDetailItem('طريقة الدفع', 'نقدي'),
                _buildDetailItem('الملاحظات', 'لا يوجد'),
              ],
            ),
          ),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: HapticFeedback.lightImpact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text(
                    'تعديل',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: HapticFeedback.lightImpact,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text(
                    'مشاركة',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildDetailItem(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: AppColors.border.withOpacity(0.2)),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
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
  );
}
