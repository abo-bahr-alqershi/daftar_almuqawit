import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/customer_card.dart';
import 'widgets/customer_search.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';

/// شاشة قائمة العملاء
class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
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
    _loadCustomers();
  }

  void _loadCustomers() {
    context.read<CustomersBloc>().add(LoadCustomers());
  }

  void _showAddCustomerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerScreen(),
      ),
    ).then((_) => _loadCustomers());
  }

  void _showCustomerDetails(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailsScreen(customer: customer),
      ),
    ).then((_) => _loadCustomers());
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'حذف العميل',
      message: 'هل أنت متأكد من حذف العميل "${customer.name}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true && customer.id != null) {
      context.read<CustomersBloc>().add(DeleteCustomerEvent(customer.id!));
    }
  }

  Future<void> _toggleBlockCustomer(Customer customer) async {
    final action = customer.isBlocked ? 'إلغاء حظر' : 'حظر';
    final confirmed = await ConfirmDialog.show(
      context: context,
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

  List<Customer> _filterCustomers(List<Customer> customers) {
    var filtered = customers;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) {
        final query = _searchQuery.toLowerCase();
        return customer.name.toLowerCase().contains(query) ||
            (customer.phone?.contains(query) ?? false) ||
            (customer.nickname?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // تطبيق الفلتر
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('العملاء', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCustomers,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط البحث
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: CustomerSearch(
                onSearch: (query) {
                  setState(() => _searchQuery = query);
                },
              ),
            ),

            // فلاتر
            Container(
              height: 50,
              color: AppColors.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
                itemCount: _filterTypes.length,
                itemBuilder: (context, index) {
                  final type = _filterTypes[index];
                  final isSelected = _filterType == type;
                  
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.spaceS,
                    ),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _filterType = type);
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // قائمة العملاء
            Expanded(
              child: BlocConsumer<CustomersBloc, CustomersState>(
                listener: (context, state) {
                  if (state is CustomersError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  } else if (state is CustomerOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CustomersLoading) {
                    return const LoadingWidget(message: 'جاري تحميل العملاء...');
                  }

                  if (state is CustomersError) {
                    return app_error.ErrorWidget(
                      message: state.message,
                      onRetry: _loadCustomers,
                    );
                  }

                  if (state is CustomersLoaded) {
                    final filteredCustomers = _filterCustomers(state.customers);

                    if (filteredCustomers.isEmpty) {
                      return EmptyWidget(
                        message: _searchQuery.isEmpty
                            ? 'لا يوجد عملاء مسجلين'
                            : 'لا توجد نتائج للبحث',
                        icon: Icons.people_outline,
                        actionLabel: _searchQuery.isEmpty ? 'إضافة عميل' : null,
                        onAction: _searchQuery.isEmpty ? _showAddCustomerScreen : null,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadCustomers(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        itemCount: filteredCustomers.length,
                        separatorBuilder: (context, index) => 
                            const SizedBox(height: AppDimensions.spaceM),
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return CustomerCard(
                            customer: customer,
                            onTap: () => _showCustomerDetails(customer),
                            onDelete: () => _deleteCustomer(customer),
                            onToggleBlock: () => _toggleBlockCustomer(customer),
                          );
                        },
                      ),
                    );
                  }

                  return const EmptyWidget(
                    message: 'لا يوجد بيانات',
                    icon: Icons.people_outline,
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddCustomerScreen,
          icon: const Icon(Icons.person_add),
          label: const Text('إضافة عميل'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}
