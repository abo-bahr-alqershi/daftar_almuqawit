import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
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

class _CustomersScreenState extends State<CustomersScreen> {
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
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersBloc>().add(LoadCustomers());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(),
          ],
          body: BlocConsumer<CustomersBloc, CustomersState>(
            listener: (context, state) {
              if (state is CustomersError) {
                _showSnackBar(state.message, isError: true);
              } else if (state is CustomerOperationSuccess) {
                _showSnackBar(state.message);
              }
            },
            builder: (context, state) {
              if (state is CustomersLoading) {
                return _buildLoadingState();
              }
              if (state is CustomersError) {
                return _buildErrorState(state.message);
              }
              if (state is CustomersLoaded) {
                return _buildContent(state.customers);
              }
              return _buildEmptyState();
            },
          ),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final opacity = (_scrollOffset / 80).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      actions: [
        _buildIconButton(Icons.block_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BlockedCustomersScreen()),
          ).then((_) => context.read<CustomersBloc>().add(LoadCustomers()));
        }),
        _buildIconButton(Icons.search_outlined, () => _showSearchSheet()),
        _buildIconButton(Icons.refresh_outlined, () {
          context.read<CustomersBloc>().add(LoadCustomers());
        }),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFFF8F9FA),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.people_outlined,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'إدارة العملاء',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<CustomersBloc, CustomersState>(
                          builder: (context, state) {
                            if (state is CustomersLoaded) {
                              return Text(
                                '${state.customers.length} عميل مسجل',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Customer> customers) {
    final filtered = _filterCustomers(customers);

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        // Stats Section
        _buildStatsSection(customers),

        const SizedBox(height: 24),

        // Filter Section
        _buildSectionHeader('تصنيف العملاء', Icons.filter_list_outlined),
        const SizedBox(height: 12),
        _buildFilterChips(),

        const SizedBox(height: 24),

        // Customers List
        _buildSectionHeader('قائمة العملاء', Icons.people_outlined),
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          _buildEmptyListState()
        else
          ...filtered.map(
            (customer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomerCard(
                customer: customer,
                onTap: () => _showCustomerDetails(customer),
                onDelete: () => _deleteCustomer(customer),
                onToggleBlock: () => _toggleBlockCustomer(customer),
              ),
            ),
          ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatsSection(List<Customer> customers) {
    final totalCustomers = customers.length;
    final activeCustomers = customers.where((c) => !c.isBlocked).length;
    final vipCustomers = customers.where((c) => c.customerType == 'VIP').length;
    final customersWithDebt = customers.where((c) => c.currentDebt > 0).length;
    final totalDebt = customers.fold(0.0, (sum, c) => sum + c.currentDebt);

    return Column(
      children: [
        // Main Stats Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إجمالي العملاء',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$activeCustomers نشط',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalCustomers.toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'عميل',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'إجمالي الديون: ${totalDebt.toStringAsFixed(0)} ر.ي',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Mini Stats Row
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                'VIP',
                vipCustomers.toString(),
                Icons.star_outline,
                const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniStatCard(
                'عليه دين',
                customersWithDebt.toString(),
                Icons.account_balance_wallet_outlined,
                const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF6366F1)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterTypes.length,
        itemBuilder: (context, index) {
          final type = _filterTypes[index];
          final isSelected = _filterType == type;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _filterType = type);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 80,
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
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFDC2626),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.people_outline,
                color: Color(0xFF9CA3AF),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا يوجد عملاء',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة عملاء جدد',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_off_outlined,
              color: Color(0xFF9CA3AF),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'لا يوجد عملاء' : 'لا توجد نتائج',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isEmpty
                ? 'ابدأ بإضافة عملاء جدد'
                : 'جرب البحث بكلمات مختلفة',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return Material(
      color: const Color(0xFF6366F1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.read<CustomersBloc>().add(LoadCustomers());
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_outlined, color: Colors.white, size: 18),
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

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
        ).then((_) => context.read<CustomersBloc>().add(LoadCustomers()));
      },
      backgroundColor: const Color(0xFF6366F1),
      elevation: 4,
      icon: const Icon(
        Icons.person_add_outlined,
        color: Colors.white,
        size: 20,
      ),
      label: const Text(
        'إضافة عميل',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  List<Customer> _filterCustomers(List<Customer> customers) {
    var filtered = customers;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        final query = _searchQuery.toLowerCase();
        return c.name.toLowerCase().contains(query) ||
            (c.phone?.contains(query) ?? false) ||
            (c.nickname?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterType != 'الكل') {
      filtered = filtered.where((c) {
        switch (_filterType) {
          case 'نشط':
            return !c.isBlocked && c.currentDebt == 0;
          case 'محظور':
            return c.isBlocked;
          case 'VIP':
            return c.customerType == 'VIP';
          case 'عليه دين':
            return c.currentDebt > 0;
          case 'تجاوز الحد':
            return c.hasExceededCreditLimit;
          default:
            return true;
        }
      }).toList();
    }

    filtered.sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
    return filtered;
  }

  void _showSearchSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
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

  void _showCustomerDetails(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailsScreen(customer: customer),
      ),
    ).then((_) => context.read<CustomersBloc>().add(LoadCustomers()));
  }

  void _deleteCustomer(Customer customer) {
    HapticFeedback.mediumImpact();
    if (customer.id != null) {
      context.read<CustomersBloc>().add(DeleteCustomerEvent(customer.id!));
    }
  }

  void _toggleBlockCustomer(Customer customer) {
    HapticFeedback.mediumImpact();
    if (customer.id != null) {
      context.read<CustomersBloc>().add(
        BlockCustomerEvent(customer.id!, !customer.isBlocked),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
