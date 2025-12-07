import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _CustomersListScreenState extends State<CustomersListScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  String _searchQuery = '';
  String _filterType = 'الكل';

  final List<String> _filterTypes = ['الكل', 'نشط', 'محظور', 'VIP', 'عليه دين'];

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
          body: Column(
            children: [
              const SizedBox(height: 16),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomerSearch(
                  onSearch: (query) => setState(() => _searchQuery = query),
                ),
              ),

              const SizedBox(height: 16),

              // Filter chips
              _buildFilterChips(),

              const SizedBox(height: 16),

              // Customer list
              Expanded(
                child: BlocConsumer<CustomersBloc, CustomersState>(
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
                      final filtered = _filterCustomers(state.customers);
                      return _buildCustomersList(filtered);
                    }
                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final opacity = (_scrollOffset / 80).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(),
      actions: [
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
              padding: const EdgeInsets.fromLTRB(60, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'قائمة العملاء',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<CustomersBloc, CustomersState>(
                    builder: (context, state) {
                      if (state is CustomersLoaded) {
                        return Text(
                          '${_filterCustomers(state.customers).length} عميل',
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
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1A1A2E),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
              margin: const EdgeInsets.only(left: 10),
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

  Widget _buildCustomersList(List<Customer> customers) {
    if (customers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomerCard(
            customer: customers[index],
            onTap: () => _showCustomerDetails(customers[index]),
            onDelete: () => _deleteCustomer(customers[index]),
            onToggleBlock: () => _toggleBlockCustomer(customers[index]),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            Text(
              _searchQuery.isEmpty ? 'لا يوجد عملاء' : 'لا توجد نتائج',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'ابدأ بإضافة عملاء جدد'
                  : 'جرب البحث بكلمات مختلفة',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
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
          MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
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
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
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
      message: 'هل أنت متأكد من حذف "${customer.name}"؟',
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
      message: 'هل أنت متأكد من $action "${customer.name}"؟',
      confirmText: action,
      cancelText: 'إلغاء',
    );

    if (confirmed == true && customer.id != null) {
      context.read<CustomersBloc>().add(
        BlockCustomerEvent(customer.id!, !customer.isBlocked),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
