import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/loading_widget.dart';
import 'customer_details_screen.dart';

/// شاشة العملاء المحظورين
class BlockedCustomersScreen extends StatefulWidget {
  const BlockedCustomersScreen({super.key});

  @override
  State<BlockedCustomersScreen> createState() => _BlockedCustomersScreenState();
}

class _BlockedCustomersScreenState extends State<BlockedCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    context.read<CustomersBloc>().add(LoadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers(List<Customer> allCustomers, String query) {
    final blocked = allCustomers.where((c) => c.isBlocked).toList();
    
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = blocked;
      });
    } else {
      setState(() {
        _filteredCustomers = blocked
            .where((customer) =>
                customer.name.toLowerCase().contains(query.toLowerCase()) ||
                (customer.phone?.contains(query) ?? false))
            .toList();
      });
    }
  }

  void _unblockCustomer(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء حظر العميل'),
        content: Text('هل تريد إلغاء حظر ${customer.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CustomersBloc>().add(
                    BlockCustomerEvent(customer.id!, false),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.success),
            child: const Text('إلغاء الحظر'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'العملاء المحظورون',
          style: AppTextStyles.h2.copyWith(color: AppColors.textOnDark),
        ),
        backgroundColor: AppColors.danger,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnDark),
      ),
      body: BlocConsumer<CustomersBloc, CustomersState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<CustomersBloc>().add(LoadCustomers());
          } else if (state is CustomersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomersLoading) {
            return const LoadingWidget(message: 'جاري تحميل العملاء المحظورين...');
          }

          if (state is CustomersError) {
            return custom_error.AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<CustomersBloc>().add(LoadCustomers());
              },
            );
          }

          if (state is CustomersLoaded) {
            final blockedCustomers =
                state.customers.where((c) => c.isBlocked).toList();

            if (_filteredCustomers.isEmpty && _searchController.text.isEmpty) {
              _filteredCustomers = blockedCustomers;
            }

            return Column(
              children: [
                // شريط البحث
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: AppTextField.search(
                    controller: _searchController,
                    hint: 'البحث عن عميل محظور...',
                    onChanged: (query) {
                      _filterCustomers(state.customers, query);
                    },
                  ),
                ),

                // إحصائيات العملاء المحظورين
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.danger.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'عدد العملاء المحظورين: ${blockedCustomers.length}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // قائمة العملاء المحظورين
                Expanded(
                  child: _filteredCustomers.isEmpty
                      ? EmptyWidget(
                          title: _searchController.text.isEmpty
                              ? 'لا يوجد عملاء محظورون'
                              : 'لم يتم العثور على عملاء',
                          message: _searchController.text.isEmpty
                              ? 'لم يتم حظر أي عميل بعد'
                              : 'جرب البحث بكلمات مختلفة',
                          icon: Icons.block,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<CustomersBloc>().add(LoadCustomers());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];
                              return _buildCustomerCard(customer);
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const EmptyWidget(
            title: 'لا يوجد بيانات',
            message: 'لم يتم تحميل بيانات العملاء',
            icon: Icons.block,
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.danger.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CustomerDetailsScreen(customer: customer),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.danger.withOpacity(0.1),
                    child: Icon(
                      Icons.block,
                      color: AppColors.danger,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customer.phone ?? 'غير محدد',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lock_open),
                    color: AppColors.success,
                    onPressed: () => _unblockCustomer(customer),
                    tooltip: 'إلغاء الحظر',
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'الدين الحالي',
                      '${customer.currentDebt.toStringAsFixed(2)} ريال',
                      Icons.account_balance_wallet,
                      customer.currentDebt > 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoItem(
                      'إجمالي المشتريات',
                      '${customer.totalPurchases.toStringAsFixed(2)} ريال',
                      Icons.shopping_cart,
                      AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          customer.notes!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
