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
import 'add_return_screen.dart';
import 'add_damaged_item_screen.dart';
import 'return_damage_details_screen.dart';

/// الشاشة الرئيسية لإدارة المردودات والتوالف - تصميم احترافي راقي
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  double _scrollOffset = 0;
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryBloc>().add(const LoadReturnsEvent());
      context.read<InventoryBloc>().add(const LoadDamagedItemsEvent());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: BlocConsumer<InventoryBloc, InventoryState>(
                listener: (context, state) {
                  if (state is ReturnOperationSuccess) {
                    _showSuccessMessage(state.message);
                  } else if (state is DamageOperationSuccess) {
                    _showSuccessMessage(state.message);
                  } else if (state is InventoryError) {
                    _showErrorMessage(state.message);
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildStatsSection(state),
                      const SizedBox(height: 24),
                      _buildFilterSection(),
                      const SizedBox(height: 20),
                      _buildContent(state),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(),
      actions: [
        _buildAppBarAction(
          Icons.refresh_rounded,
          () {
            HapticFeedback.lightImpact();
            context.read<InventoryBloc>().add(const LoadReturnsEvent());
            context.read<InventoryBloc>().add(const LoadDamagedItemsEvent());
          },
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildHeaderContent()),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, color: const Color(0xFF1A1A2E), size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FA), Color(0xFFF8F9FA)],
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
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.assignment_return_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'المردودات والتوالف',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'إدارة المردودات والبضاعة التالفة',
                          style: TextStyle(
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
    );
  }

  Widget _buildStatsSection(InventoryState state) {
    final returns = (state is ReturnsLoadedState) ? state.returns : [];
    final damages = (state is DamagedItemsLoadedState) ? state.damagedItems : [];
    
    final returnsTotal = returns.fold<double>(0, (sum, item) => sum + (item.totalAmount ?? 0));
    final damagesTotal = damages.fold<double>(0, (sum, item) => sum + (item.totalCost ?? 0));
    final totalAmount = returnsTotal + damagesTotal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي القيمة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${returns.length + damages.length} عملية',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'نشط',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0, end: totalAmount),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            'ريال',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المردودات',
                  returnsTotal,
                  Icons.keyboard_return_rounded,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'التوالف',
                  damagesTotal,
                  Icons.broken_image_rounded,
                  const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'عدد المردودات',
                  returns.length.toDouble(),
                  Icons.assignment_return_rounded,
                  const Color(0xFF3B82F6),
                  isCount: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'عدد التوالف',
                  damages.length.toDouble(),
                  Icons.report_problem_rounded,
                  const Color(0xFF6366F1),
                  isCount: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    double value,
    IconData icon,
    Color color, {
    bool isCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                size: 16,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0, end: value),
            curve: Curves.easeOut,
            builder: (context, animatedValue, child) {
              return Text(
                isCount
                    ? animatedValue.toInt().toString()
                    : animatedValue.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.2,
                ),
              );
            },
          ),
          if (!isCount)
            const Text(
              'ر.ي',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = ['الكل', 'المردودات', 'التوالف', 'المعلق', 'المؤكد'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'التصنيف',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Material(
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedFilter = filter);
                      _applyFilter(filter);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(InventoryState state) {
    if (state is InventoryLoading) {
      return _buildLoadingState();
    }

    final returns = (state is ReturnsLoadedState) ? state.returns : [];
    final damages = (state is DamagedItemsLoadedState) ? state.damagedItems : [];
    
    final filteredReturns = _filterData(returns, true);
    final filteredDamages = _filterData(damages, false);
    
    final allItems = [...filteredReturns, ...filteredDamages];
    
    if (allItems.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredReturns.isNotEmpty) ...[
            const Text(
              'المردودات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            ...filteredReturns.map((item) => _buildReturnCard(item)).toList(),
          ],
          if (filteredDamages.isNotEmpty) ...[
            if (filteredReturns.isNotEmpty) const SizedBox(height: 20),
            const Text(
              'البضاعة التالفة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            ...filteredDamages.map((item) => _buildDamagedCard(item)).toList(),
          ],
        ],
      ),
    );
  }

  List<dynamic> _filterData(List<dynamic> items, bool isReturns) {
    if (_selectedFilter == 'الكل') return items;
    if (_selectedFilter == 'المردودات' && isReturns) return items;
    if (_selectedFilter == 'التوالف' && !isReturns) return items;
    if (_selectedFilter == 'المعلق') {
      return items.where((item) => item.status == 'معلق').toList();
    }
    if (_selectedFilter == 'المؤكد') {
      return items.where((item) => item.status == 'مؤكد').toList();
    }
    return [];
  }

  void _applyFilter(String filter) {
    if (filter == 'الكل' || filter == 'المردودات') {
      context.read<InventoryBloc>().add(const LoadReturnsEvent());
    }
    if (filter == 'الكل' || filter == 'التوالف') {
      context.read<InventoryBloc>().add(const LoadDamagedItemsEvent());
    }
  }

  Widget _buildFAB() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToAddReturn(),
              heroTag: 'add_return',
              backgroundColor: const Color(0xFF10B981),
              icon: const Icon(Icons.keyboard_return_rounded, color: Colors.white),
              label: const Text(
                'إضافة مردود',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToDamaged(),
              heroTag: 'add_damage',
              backgroundColor: const Color(0xFFDC2626),
              icon: const Icon(Icons.broken_image_rounded, color: Colors.white),
              label: const Text(
                'تسجيل تلف',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
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
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReturnDamageDetailsScreen(item: returnItem),
              ),
            );
          },
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
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReturnDamageDetailsScreen(item: damagedItem),
              ),
            );
          },
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

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_return_rounded,
                size: 60,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد عمليات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة مردود أو تسجيل بضاعة تالفة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
