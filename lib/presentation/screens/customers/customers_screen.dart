import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../navigation/route_names.dart';
import 'widgets/customer_card.dart';
import 'widgets/customer_search.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';
import 'blocked_customers_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  String _searchQuery = '';
  String _filterType = 'الكل';

  final List<String> _filterTypes = [
    'الكل',
    'نشط',
    'محظور',
    'VIP',
    'عليه دين',
    'تجاوز الحد',
  ];

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersBloc>().add(LoadCustomers());
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
            _buildGradientBackground(),

            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildModernAppBar(topPadding),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      BlocBuilder<CustomersBloc, CustomersState>(
                        builder: (context, state) {
                          if (state is CustomersLoaded) {
                            return _buildQuickStatsWidget(state.customers);
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: 32),

                      _buildSectionTitle('تصنيف العملاء', Icons.filter_list_rounded),

                      const SizedBox(height: 16),

                      _buildFilterChips(),

                      const SizedBox(height: 32),

                      _buildSectionTitle('قائمة العملاء', Icons.people_rounded),

                      const SizedBox(height: 16),

                      BlocConsumer<CustomersBloc, CustomersState>(
                        listener: (context, state) {
                          if (state is CustomersError) {
                            _showErrorSnackBar(state.message);
                          } else if (state is CustomerOperationSuccess) {
                            _showSuccessSnackBar(state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is CustomersLoading) {
                            return _buildLoadingState();
                          }

                          if (state is CustomersError) {
                            return _buildErrorState(state);
                          }

                          if (state is CustomersLoaded) {
                            final filteredCustomers = _filterCustomers(state.customers);
                            return _buildCustomersList(filteredCustomers);
                          }

                          return _buildEmptyState('لا يوجد بيانات', Icons.people_outline);
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),

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
          AppColors.accent.withOpacity(0.08),
          AppColors.primary.withOpacity(0.05),
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
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.people_rounded,
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
                              'إدارة العملاء',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<CustomersBloc, CustomersState>(
                              builder: (context, state) {
                                if (state is CustomersLoaded) {
                                  return Text(
                                    '${state.customers.length} عميل مسجل',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
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
          Icons.block_rounded,
          onPressed: () => _navigateToBlockedCustomers(),
        ),
        _buildIconButton(
          Icons.search_rounded,
          onPressed: () => _showSearchSheet(context),
        ),
        _buildIconButton(
          Icons.refresh_rounded,
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.read<CustomersBloc>().add(LoadCustomers());
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {required VoidCallback onPressed}) => 
      Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: IconButton(
          icon: Icon(icon, color: AppColors.textPrimary, size: 20),
          onPressed: onPressed,
        ),
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
                AppColors.accent.withOpacity(0.1),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.accent),
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

  Widget _buildQuickStatsWidget(List<Customer> customers) {
    final totalCustomers = customers.length;
    final activeCustomers = customers.where((c) => !c.isBlocked).length;
    final vipCustomers = customers.where((c) => c.customerType == 'VIP').length;
    final customersWithDebt = customers.where((c) => c.currentDebt > 0).length;
    final totalDebt = customers.fold(0.0, (sum, c) => sum + c.currentDebt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _StatsBackgroundPainter()),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'إجمالي العملاء',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'إجمالي الديون: ${totalDebt.toStringAsFixed(0)} ريال',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
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
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success,
                                        blurRadius: 8,
                                        spreadRadius: 2,
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
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            totalCustomers.toString(),
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'عميل',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$activeCustomers نشط',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModernStatCard(
                  title: 'VIP',
                  value: vipCustomers.toString(),
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernStatCard(
                  title: 'عليه دين',
                  value: customersWithDebt.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() => SizedBox(
    height: 50,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filterTypes.length,
      itemBuilder: (context, index) {
        final type = _filterTypes[index];
        final isSelected = _filterType == type;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _filterType = type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF7C3AED)],
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
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildCustomersList(List<Customer> customers) {
    if (customers.isEmpty) {
      return _buildEmptyState(
        _searchQuery.isEmpty ? 'لا يوجد عملاء' : 'لا توجد نتائج',
        Icons.people_outline,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: customers.map((customer) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scale: value.clamp(0.0, 1.0),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CustomerCard(
                    customer: customer,
                    onTap: () => _showCustomerDetails(customer),
                    onDelete: () => _deleteCustomer(customer),
                    onToggleBlock: () => _toggleBlockCustomer(customer),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => _buildShimmerCard()),
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

  Widget _buildErrorState(CustomersError state) => Center(
    child: Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
              context.read<CustomersBloc>().add(LoadCustomers());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
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

  Widget _buildEmptyState(String message, IconData icon) => Center(
    child: Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                      AppColors.accent.withOpacity(0.05),
                      AppColors.primary.withOpacity(0.03),
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
          const Text(
            'ابدأ بإضافة عملاء جدد',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddCustomerScreen();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'إضافة عميل',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildFloatingActionButton(BuildContext context) => Positioned(
    bottom: 20,
    left: 20,
    child: FloatingActionButton.extended(
      onPressed: _showAddCustomerScreen,
      backgroundColor: AppColors.accent,
      icon: const Icon(Icons.person_add_rounded, color: Colors.white),
      label: const Text(
        'إضافة عميل',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      elevation: 8,
    ),
  );

  List<Customer> _filterCustomers(List<Customer> customers) {
    var filtered = customers;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) {
        final query = _searchQuery.toLowerCase();
        return customer.name.toLowerCase().contains(query) ||
            (customer.phone?.contains(query) ?? false) ||
            (customer.nickname?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterType != 'الكل') {
      filtered = filtered.where((customer) {
        switch (_filterType) {
          case 'نشط':
            return !customer.isBlocked && customer.currentDebt == 0;
          case 'محظور':
            return customer.isBlocked;
          case 'VIP':
            return customer.customerType == 'VIP';
          case 'عليه دين':
            return customer.currentDebt > 0;
          case 'تجاوز الحد':
            return customer.hasExceededCreditLimit;
          default:
            return true;
        }
      }).toList();
    }

    filtered.sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));

    return filtered;
  }

  void _showAddCustomerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
    ).then((_) => context.read<CustomersBloc>().add(LoadCustomers()));
  }

  void _showCustomerDetails(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailsScreen(customer: customer),
      ),
    ).then((_) => context.read<CustomersBloc>().add(LoadCustomers()));
  }

  void _navigateToBlockedCustomers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BlockedCustomersScreen()),
    ).then((_) => context.read<CustomersBloc>().add(LoadCustomers()));
  }

  void _showSearchSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
            CustomerSearch(
              onSearch: (query) {
                setState(() => _searchQuery = query);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCustomer(Customer customer) async {
    HapticFeedback.mediumImpact();
    if (customer.id != null) {
      context.read<CustomersBloc>().add(DeleteCustomerEvent(customer.id!));
    }
  }

  void _toggleBlockCustomer(Customer customer) async {
    HapticFeedback.mediumImpact();
    if (customer.id != null) {
      context.read<CustomersBloc>().add(
        BlockCustomerEvent(customer.id!, !customer.isBlocked),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

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
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _StatsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 60, paint);

    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 80, paint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width * 0.3, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
