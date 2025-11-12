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
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/customer_card.dart';
import 'widgets/customer_search.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen>
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

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomerSearch(
                          onSearch: (query) {
                            setState(() => _searchQuery = query);
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildFilterChips(),

                      const SizedBox(height: 20),

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
                            final filteredCustomers =
                                _filterCustomers(state.customers);
                            return _buildCustomersList(filteredCustomers);
                          }

                          return _buildEmptyState();
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
      expandedHeight: 120,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'قائمة العملاء',
                              style: AppTextStyles.h2.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<CustomersBloc, CustomersState>(
                              builder: (context, state) {
                                if (state is CustomersLoaded) {
                                  final filtered =
                                      _filterCustomers(state.customers);
                                  return Text(
                                    '${filtered.length} عميل',
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
                            Icons.refresh_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.read<CustomersBloc>().add(LoadCustomers());
                          },
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: customers.asMap().entries.map((entry) {
          final index = entry.key;
          final customer = entry.value;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  Widget _buildEmptyState() => Center(
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
                    child: const Icon(
                      Icons.people_outline,
                      size: 70,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _searchQuery.isEmpty
                    ? 'لا يوجد عملاء'
                    : 'لا توجد نتائج للبحث',
                style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isEmpty
                    ? 'ابدأ بإضافة عملاء جدد'
                    : 'جرب البحث بكلمات مختلفة',
                style: const TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
              const SizedBox(height: 32),
              if (_searchQuery.isEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showAddCustomerScreen();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
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
          default:
            return true;
        }
      }).toList();
    }

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

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف العميل',
      message: 'هل أنت متأكد من حذف العميل "${customer.name}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && customer.id != null) {
      context.read<CustomersBloc>().add(DeleteCustomerEvent(customer.id!));
    }
  }

  Future<void> _toggleBlockCustomer(Customer customer) async {
    final action = customer.isBlocked ? 'إلغاء حظر' : 'حظر';
    final confirmed = await ConfirmDialog.show(
      context,
      title: '$action العميل',
      message: 'هل أنت متأكد من $action العميل "${customer.name}"؟',
      confirmText: action,
      cancelText: 'إلغاء',
    );

    if (confirmed == true && customer.id != null) {
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
