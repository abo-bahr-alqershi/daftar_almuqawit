import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  String _selectedPeriod = 'all';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              if (_showFilters) _buildFilterChips(),
              Expanded(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return _buildLoadingState();
                    }

                    if (state is DashboardError) {
                      return _buildErrorState(state.message);
                    }

                    if (state is DashboardLoaded) {
                      return _buildContent(state);
                    }

                    return _buildEmptyState(
                      'لا توجد بيانات',
                      Icons.inbox_outlined,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFilterFAB(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          // Back Button
          _buildIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سجل النشاطات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoaded) {
                      final count =
                          state.todaySales.length + state.todayPurchases.length;
                      return Text(
                        '$count نشاط مسجل',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Search Button
          _buildIconButton(
            icon: Icons.search_rounded,
            onTap: () => _showSearchSheet(),
          ),
          const SizedBox(width: 10),

          // Export Button
          _buildPrimaryIconButton(
            icon: Icons.download_rounded,
            onTap: _exportActivities,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(icon, color: const Color(0xFF374151), size: 20),
        ),
      ),
    );
  }

  Widget _buildPrimaryIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF6366F1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        labelColor: const Color(0xFF1A1A2E),
        unselectedLabelColor: const Color(0xFF9CA3AF),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(text: 'الكل', height: 42),
          Tab(text: 'المبيعات', height: 42),
          Tab(text: 'المشتريات', height: 42),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildChip('الكل', 'all'),
          const SizedBox(width: 8),
          _buildChip('اليوم', 'today'),
          const SizedBox(width: 8),
          _buildChip('الأسبوع', 'week'),
          const SizedBox(width: 8),
          _buildChip('الشهر', 'month'),
          const SizedBox(width: 8),
          _buildDateChip(),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = _selectedPeriod == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPeriod = value);
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1)),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          // Apply date filter
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Color(0xFF6B7280),
            ),
            SizedBox(width: 6),
            Text(
              'تحديد فترة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DashboardLoaded state) {
    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildAllActivities(state),
        _buildSalesActivities(state.todaySales),
        _buildPurchasesActivities(state.todayPurchases),
      ],
    );
  }

  Widget _buildAllActivities(DashboardLoaded state) {
    final activities = _buildActivityList(state);

    if (activities.isEmpty) {
      return _buildEmptyState('لا توجد نشاطات', Icons.inbox_outlined);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return _AnimatedActivityCard(
            activity: activities[index],
            index: index,
            onTap: () => _showActivityDetails(activities[index]),
          );
        },
      ),
    );
  }

  Widget _buildSalesActivities(List<Sale> sales) {
    if (sales.isEmpty) {
      return _buildEmptyState('لا توجد مبيعات', Icons.shopping_cart_outlined);
    }

    final activities = sales
        .map(
          (sale) => ActivityItem(
            title:
                'مبيعة ${sale.customerName != null ? "إلى ${sale.customerName}" : ""}',
            time: sale.date,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF16A34A),
            amount: '${sale.totalAmount.toStringAsFixed(0)} ريال',
          ),
        )
        .toList();

    return _buildActivitiesList(activities);
  }

  Widget _buildPurchasesActivities(List<Purchase> purchases) {
    if (purchases.isEmpty) {
      return _buildEmptyState('لا توجد مشتريات', Icons.shopping_bag_outlined);
    }

    final activities = purchases
        .map(
          (purchase) => ActivityItem(
            title:
                'مشترى ${purchase.supplierName != null ? "من ${purchase.supplierName}" : ""}',
            time: purchase.date,
            icon: Icons.shopping_cart_outlined,
            color: const Color(0xFF0EA5E9),
            amount: '${purchase.totalAmount.toStringAsFixed(0)} ريال',
          ),
        )
        .toList();

    return _buildActivitiesList(activities);
  }

  Widget _buildActivitiesList(List<ActivityItem> activities) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
      },
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return _AnimatedActivityCard(
            activity: activities[index],
            index: index,
            onTap: () => _showActivityDetails(activities[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة نشاطات جديدة',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 24),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Material(
      color: const Color(0xFF6366F1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<DashboardBloc>().add(LoadRecentActivities(limit: 50));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: const Color(0xFF6366F1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/quick-sale');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'إضافة نشاط',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterFAB() {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        setState(() => _showFilters = !_showFilters);
      },
      backgroundColor: const Color(0xFF6366F1),
      elevation: 4,
      child: AnimatedRotation(
        turns: _showFilters ? 0.125 : 0,
        duration: const Duration(milliseconds: 300),
        child: const Icon(Icons.filter_list_rounded, color: Colors.white),
      ),
    );
  }

  List<ActivityItem> _buildActivityList(DashboardLoaded state) {
    final activities = <ActivityItem>[];

    for (final sale in state.todaySales) {
      activities.add(
        ActivityItem(
          title:
              'مبيعة ${sale.customerName != null ? "إلى ${sale.customerName}" : ""}',
          time: sale.date,
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF16A34A),
          amount: '${sale.totalAmount.toStringAsFixed(0)} ريال',
        ),
      );
    }

    for (final purchase in state.todayPurchases) {
      activities.add(
        ActivityItem(
          title:
              'مشترى ${purchase.supplierName != null ? "من ${purchase.supplierName}" : ""}',
          time: purchase.date,
          icon: Icons.shopping_cart_outlined,
          color: const Color(0xFF0EA5E9),
          amount: '${purchase.totalAmount.toStringAsFixed(0)} ريال',
        ),
      );
    }

    activities.sort((a, b) => b.time.compareTo(a.time));
    return _applyFilter(activities);
  }

  List<ActivityItem> _applyFilter(List<ActivityItem> activities) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'today':
        return activities.where((a) {
          final date = DateTime.tryParse(a.time) ?? now;
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return activities.where((a) {
          final date = DateTime.tryParse(a.time) ?? now;
          return date.isAfter(weekAgo);
        }).toList();
      case 'month':
        return activities.where((a) {
          final date = DateTime.tryParse(a.time) ?? now;
          return date.year == now.year && date.month == now.month;
        }).toList();
      default:
        return activities;
    }
  }

  void _showActivityDetails(ActivityItem activity) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityDetailsSheet(activity: activity),
    );
  }

  void _showSearchSheet() {
    HapticFeedback.lightImpact();
    // Implement search
  }

  void _exportActivities() {
    HapticFeedback.mediumImpact();
    // Implement export
  }
}

// بطاقة النشاط مع Animation
class _AnimatedActivityCard extends StatelessWidget {
  final ActivityItem activity;
  final int index;
  final VoidCallback onTap;

  const _AnimatedActivityCard({
    required this.activity,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _ActivityCard(activity: activity, onTap: onTap),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final ActivityItem activity;
  final VoidCallback onTap;

  const _ActivityCard({required this.activity, required this.onTap});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.04),
              blurRadius: _isPressed ? 4 : 8,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.activity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.activity.icon,
                color: widget.activity.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.activity.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            if (widget.activity.amount != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.activity.amount!.split(' ')[0],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.activity.color,
                    ),
                  ),
                  Text(
                    'ريال',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.activity.color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),

            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}

// Sheet تفاصيل النشاط
class _ActivityDetailsSheet extends StatelessWidget {
  final ActivityItem activity;

  const _ActivityDetailsSheet({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: activity.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(activity.icon, color: activity.color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.time,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),

          // Details
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildDetailsCard([
                _DetailRow('المبلغ', activity.amount ?? '0 ريال'),
                _DetailRow('الحالة', activity.status ?? 'مكتمل'),
                _DetailRow('رقم المرجع', '#${activity.hashCode}'),
                _DetailRow('طريقة الدفع', 'نقدي'),
              ]),
            ),
          ),

          // Actions
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'تعديل',
                    Icons.edit_outlined,
                    const Color(0xFF6366F1),
                    true,
                    () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'مشاركة',
                    Icons.share_outlined,
                    const Color(0xFF374151),
                    false,
                    () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(List<_DetailRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.value.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  entry.value.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    bool isPrimary,
    VoidCallback onTap,
  ) {
    return Material(
      color: isPrimary ? color : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isPrimary ? Colors.white : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  _DetailRow(this.label, this.value);
}
