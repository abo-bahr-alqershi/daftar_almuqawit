import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
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

class _ActivitiesScreenState extends State<ActivitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('جميع النشاطات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'المبيعات'),
            Tab(text: 'المشتريات'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('الكل'),
              ),
              const PopupMenuItem(
                value: 'today',
                child: Text('اليوم'),
              ),
              const PopupMenuItem(
                value: 'week',
                child: Text('هذا الأسبوع'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('هذا الشهر'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildAllActivities(state),
                _buildSalesActivities(state.todaySales),
                _buildPurchasesActivities(state.todayPurchases),
              ],
            );
          }

          return const Center(
            child: Text('لا توجد بيانات'),
          );
        },
      ),
    );
  }

  Widget _buildAllActivities(DashboardLoaded state) {
    final activities = _buildActivityList(state);

    if (activities.isEmpty) {
      return _buildEmptyState('لا توجد نشاطات', Icons.inbox);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _ActivityCard(activity: activity);
        },
      ),
    );
  }

  Widget _buildSalesActivities(List<Sale> sales) {
    if (sales.isEmpty) {
      return _buildEmptyState('لا توجد مبيعات', Icons.shopping_cart);
    }

    final activities = sales.map((sale) {
      return ActivityItem(
        title: 'مبيعة ${sale.customerName != null ? "إلى ${sale.customerName}" : ""}',
        time: sale.date,
        icon: Icons.shopping_cart,
        color: AppColors.success,
        amount: '${sale.totalAmount.toStringAsFixed(2)} ريال',
      );
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _ActivityCard(activity: activity);
        },
      ),
    );
  }

  Widget _buildPurchasesActivities(List<Purchase> purchases) {
    if (purchases.isEmpty) {
      return _buildEmptyState('لا توجد مشتريات', Icons.add_shopping_cart);
    }

    final activities = purchases.map((purchase) {
      return ActivityItem(
        title: 'مشترى ${purchase.supplierName != null ? "من ${purchase.supplierName}" : ""}',
        time: purchase.date,
        icon: Icons.add_shopping_cart,
        color: AppColors.warning,
        amount: '${purchase.totalAmount.toStringAsFixed(2)} ريال',
      );
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _ActivityCard(activity: activity);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<ActivityItem> _buildActivityList(DashboardLoaded state) {
    final activities = <ActivityItem>[];

    for (final sale in state.todaySales) {
      activities.add(ActivityItem(
        title: 'مبيعة ${sale.customerName != null ? "إلى ${sale.customerName}" : ""}',
        time: sale.date,
        icon: Icons.shopping_cart,
        color: AppColors.success,
        amount: '${sale.totalAmount.toStringAsFixed(2)} ريال',
      ));
    }

    for (final purchase in state.todayPurchases) {
      activities.add(ActivityItem(
        title: 'مشترى ${purchase.supplierName != null ? "من ${purchase.supplierName}" : ""}',
        time: purchase.date,
        icon: Icons.add_shopping_cart,
        color: AppColors.warning,
        amount: '${purchase.totalAmount.toStringAsFixed(2)} ريال',
      ));
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

      default:
        return activities;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  DateTime _parseTime(String time) {
    return DateTime.now();
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityItem activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  activity.time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (activity.amount != null)
            Text(
              activity.amount!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: activity.color,
              ),
            ),
        ],
      ),
    );
  }
}
