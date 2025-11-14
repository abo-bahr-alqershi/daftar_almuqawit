import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/inventory.dart';
import '../../../domain/usecases/inventory/get_inventory_list.dart';
import '../../../domain/usecases/inventory/get_inventory_statistics.dart';
import '../../blocs/inventory/inventory_bloc.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/inventory_item_card.dart';
import 'widgets/inventory_stats_card.dart';
import 'widgets/inventory_transaction_card.dart';
import 'widgets/inventory_filter_widget.dart';
import 'add_return_screen.dart';
import 'add_damaged_item_screen.dart';
import 'inventory_details_screen.dart';
import 'adjust_quantity_screen.dart';

/// الشاشة الرئيسية لإدارة المخزون - تصميم راقي هادئ
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  double _scrollOffset = 0;
  late TabController _tabController;
  InventoryFilterType _currentFilter = InventoryFilterType.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      _onTabChanged(_tabController.index);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryBloc>().add(const LoadInventoryStatisticsEvent());
      context.read<InventoryBloc>().add(
        const LoadInventoryListEvent(filterType: InventoryFilterType.all),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _tabController.dispose();
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
            _buildGradientBackground(),
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildModernAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      BlocConsumer<InventoryBloc, InventoryState>(
                        listener: (context, state) {
                          if (state is InventoryOperationSuccess) {
                            _showSuccessMessage(state.message);
                          } else if (state is InventoryError) {
                            _showErrorMessage(state.message);
                          }
                        },
                        builder: (context, state) {
                          InventoryStatistics? statistics;

                          if (state is InventoryListLoaded &&
                              state.statistics != null) {
                            statistics = state.statistics;
                          } else if (state is InventoryStatisticsLoaded) {
                            statistics = state.statistics;
                          }

                          return Column(
                            children: [
                              if (statistics != null)
                                InventoryStatsCard(statistics: statistics),
                              const SizedBox(height: 20),
                              _buildSearchBar(),
                              const SizedBox(height: 20),
                              _buildTabBar(),
                              const SizedBox(height: 16),
                              _buildTabContent(state),
                              const SizedBox(height: 100),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildFloatingActionButton(),
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
          AppColors.info.withOpacity(0.08),
          AppColors.primary.withOpacity(0.05),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildModernAppBar() {
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
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.info, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
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
                              'المخزون',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة المخزون والأصناف',
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
        _buildIconButton(
          Icons.filter_list_rounded,
          onPressed: _showFilterDialog,
        ),
        _buildIconButton(
          Icons.refresh_rounded,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.read<InventoryBloc>().add(const RefreshInventoryEvent());
          },
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

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'البحث في المخزون...',
          hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onSubmitted: (query) {
          context.read<InventoryBloc>().add(SearchInventoryEvent(query));
        },
      ),
    ),
  );

  Widget _buildTabBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TabBar(
      controller: _tabController,
      isScrollable: true,
      indicator: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.info, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTextStyles.labelMedium,
      padding: const EdgeInsets.all(4),
      tabs: const [
        Tab(text: 'الكل'),
        Tab(text: 'منخفض'),
        Tab(text: 'الحركات'),
        Tab(text: 'المردودات'),
        Tab(text: 'التالف'),
      ],
    ),
  );

  Widget _buildTabContent(InventoryState state) {
    if (state is InventoryLoading) {
      return _buildLoadingShimmer();
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAllInventoryTab(state),
          _buildLowStockTab(state),
          _buildTransactionsTab(state),
          _buildReturnsTab(state),
          _buildDamagedTab(state),
        ],
      ),
    );
  }

  Widget _buildAllInventoryTab(InventoryState state) {
    if (state is InventoryListLoaded) {
      if (state.inventory.isEmpty) {
        return _buildEmptyState(
          icon: Icons.inventory_2_rounded,
          title: 'لا توجد أصناف',
          subtitle: 'ابدأ بإضافة أصناف جديدة للمخزون',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.inventory.length,
        itemBuilder: (context, index) {
          final item = state.inventory[index];
          return InventoryItemCard(
            item: item,
            onTap: () => _navigateToDetails(item),
            onEdit: () => _showEditDialog(item),
            onAdjustQuantity: () => _navigateToAdjustQuantity(item),
          );
        },
      );
    }
    if (state is InventoryError) {
      return _buildErrorState(state.message);
    }
    return _buildEmptyState(
      icon: Icons.inventory_2_rounded,
      title: 'لا توجد بيانات',
    );
  }

  Widget _buildLowStockTab(InventoryState state) {
    if (state is InventoryListLoaded) {
      final lowStockItems = state.inventory
          .where((item) => item.isLowStock)
          .toList();
      if (lowStockItems.isEmpty) {
        return _buildEmptyState(
          icon: Icons.check_circle_rounded,
          title: 'ممتاز!',
          subtitle: 'لا يوجد مخزون منخفض',
          color: AppColors.success,
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: lowStockItems.length,
        itemBuilder: (context, index) {
          final item = lowStockItems[index];
          return InventoryItemCard(
            item: item,
            showLowStockWarning: true,
            onTap: () => _navigateToDetails(item),
            onEdit: () => _showEditDialog(item),
            onAdjustQuantity: () => _navigateToAdjustQuantity(item),
          );
        },
      );
    }
    return _buildEmptyState(
      icon: Icons.warning_rounded,
      title: 'لا توجد بيانات',
    );
  }

  Widget _buildTransactionsTab(InventoryState state) {
    if (state is InventoryTransactionsLoaded) {
      if (state.transactions.isEmpty) {
        return _buildEmptyState(
          icon: Icons.history_rounded,
          title: 'لا توجد حركات',
          subtitle: 'ستظهر حركات المخزون هنا',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.transactions.length,
        itemBuilder: (context, index) {
          final transaction = state.transactions[index];
          return InventoryTransactionCard(transaction: transaction);
        },
      );
    }
    return _buildEmptyState(
      icon: Icons.history_rounded,
      title: 'لا توجد حركات',
    );
  }

  Widget _buildReturnsTab(InventoryState state) {
    if (state is ReturnsLoadedState) {
      if (state.returns.isEmpty) {
        return _buildEmptyState(
          icon: Icons.assignment_return_rounded,
          title: 'لا توجد مردودات',
          subtitle: 'ستظهر المردودات هنا عند إضافتها',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.returns.length,
        itemBuilder: (context, index) {
          final returnItem = state.returns[index];
          return _buildReturnCard(returnItem);
        },
      );
    }
    return _buildEmptyState(
      icon: Icons.assignment_return_rounded,
      title: 'لا توجد مردودات',
    );
  }

  Widget _buildDamagedTab(InventoryState state) {
    if (state is DamagedItemsLoadedState) {
      if (state.damagedItems.isEmpty) {
        return _buildEmptyState(
          icon: Icons.broken_image_rounded,
          title: 'لا توجد بضاعة تالفة',
          subtitle: 'ستظهر البضاعة التالفة هنا عند تسجيلها',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.damagedItems.length,
        itemBuilder: (context, index) {
          final damagedItem = state.damagedItems[index];
          return _buildDamagedCard(damagedItem);
        },
      );
    }
    return _buildEmptyState(
      icon: Icons.broken_image_rounded,
      title: 'لا توجد بضاعة تالفة',
    );
  }

  Widget _buildReturnCard(dynamic returnItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            AppColors.warning.withOpacity(0.15),
                            AppColors.warning.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.keyboard_return_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            returnItem.qatTypeName ?? 'غير محدد',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'السبب: ${returnItem.returnReason}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          returnItem.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        returnItem.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(returnItem.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetricItem(
                      icon: Icons.inventory_2_rounded,
                      label: 'الكمية',
                      value: '${returnItem.quantity} ${returnItem.unit}',
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    _buildMetricItem(
                      icon: Icons.attach_money_rounded,
                      label: 'المبلغ',
                      value:
                          '${returnItem.totalAmount.toStringAsFixed(0)} ريال',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDamagedCard(dynamic damagedItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.danger.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            _getSeverityColor(
                              damagedItem.severityLevel,
                            ).withOpacity(0.15),
                            _getSeverityColor(
                              damagedItem.severityLevel,
                            ).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getDamageIcon(damagedItem.severityLevel),
                        color: _getSeverityColor(damagedItem.severityLevel),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            damagedItem.qatTypeName ?? 'غير محدد',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'السبب: ${damagedItem.damageReason}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(
                          damagedItem.severityLevel,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        damagedItem.severityLevel,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSeverityColor(damagedItem.severityLevel),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetricItem(
                      icon: Icons.inventory_2_rounded,
                      label: 'الكمية',
                      value: '${damagedItem.quantity} ${damagedItem.unit}',
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    _buildMetricItem(
                      icon: Icons.attach_money_rounded,
                      label: 'التكلفة',
                      value: '${damagedItem.totalCost.toStringAsFixed(0)} ريال',
                      color: AppColors.danger,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (color ?? AppColors.textSecondary).withOpacity(0.1),
                  (color ?? AppColors.textSecondary).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: color ?? AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: color ?? AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildErrorState(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.danger,
          ),
          const SizedBox(height: 20),
          Text(
            'حدث خطأ',
            style: AppTextStyles.h3.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<InventoryBloc>().add(const LoadInventoryListEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );

  Widget _buildLoadingShimmer() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: 5,
    itemBuilder: (context, index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
      );
    },
  );

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 24,
      left: 20,
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final currentIndex = _tabController.index;

          switch (currentIndex) {
            case 0:
            case 1:
              return FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: AppColors.info,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'إضافة صنف',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            case 3:
              return FloatingActionButton.extended(
                onPressed: () => _navigateToAddReturn(),
                backgroundColor: AppColors.warning,
                icon: const Icon(
                  Icons.keyboard_return_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'إضافة مردود',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            case 4:
              return FloatingActionButton.extended(
                onPressed: () => _navigateToDamaged(),
                backgroundColor: AppColors.danger,
                icon: const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'تسجيل تلف',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void _onTabChanged(int index) {
    setState(() {});
    switch (index) {
      case 0:
        context.read<InventoryBloc>().add(
          const LoadInventoryListEvent(filterType: InventoryFilterType.all),
        );
        break;
      case 1:
        context.read<InventoryBloc>().add(
          const LoadInventoryListEvent(
            filterType: InventoryFilterType.lowStock,
          ),
        );
        break;
      case 2:
        context.read<InventoryBloc>().add(
          const LoadInventoryTransactionsEvent(),
        );
        break;
      case 3:
        context.read<InventoryBloc>().add(const LoadReturnsEvent());
        break;
      case 4:
        context.read<InventoryBloc>().add(const LoadDamagedItemsEvent());
        break;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: InventoryFilterWidget(
          currentFilter: _currentFilter,
          onFilterChanged: (filter, options) {
            setState(() => _currentFilter = filter);
            context.read<InventoryBloc>().add(
              LoadInventoryListEvent(filterType: filter),
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetails(Inventory item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryDetailsScreen(item: item),
      ),
    );
  }

  void _navigateToAdjustQuantity(Inventory item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdjustQuantityScreen(item: item)),
    );
  }

  void _navigateToAddReturn() {
    final inventoryBloc = context.read<InventoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (screenContext) => BlocProvider.value(
          value: inventoryBloc,
          child: const AddReturnScreen(),
        ),
      ),
    );
  }

  void _navigateToDamaged() {
    final inventoryBloc = context.read<InventoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (screenContext) => BlocProvider.value(
          value: inventoryBloc,
          child: const AddDamagedItemScreen(),
        ),
      ),
    );
  }

  void _showEditDialog(Inventory item) {}

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مؤكد':
        return AppColors.success;
      case 'معلق':
        return AppColors.warning;
      case 'ملغي':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getSeverityColor(String level) {
    switch (level) {
      case 'طفيف':
        return AppColors.success;
      case 'متوسط':
        return AppColors.warning;
      case 'كبير':
        return AppColors.danger;
      case 'كارثي':
        return AppColors.purchases;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getDamageIcon(String level) {
    switch (level) {
      case 'طفيف':
        return Icons.info_outline_rounded;
      case 'متوسط':
        return Icons.warning_rounded;
      case 'كبير':
        return Icons.error_rounded;
      case 'كارثي':
        return Icons.dangerous_rounded;
      default:
        return Icons.broken_image_rounded;
    }
  }
}
