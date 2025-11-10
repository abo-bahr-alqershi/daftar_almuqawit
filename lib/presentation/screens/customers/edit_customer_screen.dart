import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customer_form_bloc.dart';
import '../../blocs/customers/customer_form_event.dart';
import '../../blocs/customers/customer_form_state.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// شاشة تعديل بيانات العميل
class EditCustomerScreen extends StatefulWidget {
  final Customer customer;

  const EditCustomerScreen({
    super.key,
    required this.customer,
  });

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone ?? '');
    _addressController = TextEditingController(text: '');
    _notesController = TextEditingController(text: widget.customer.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateCustomer() {
    if (_formKey.currentState!.validate()) {
      final updatedCustomer = widget.customer.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
      );

      context.read<CustomersBloc>().add(UpdateCustomerEvent(updatedCustomer));
    }
  }

  void _deleteCustomer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العميل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CustomersBloc>().add(
                    DeleteCustomerEvent(widget.customer.id!),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('حذف'),
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
          'تعديل بيانات العميل',
          style: AppTextStyles.h2.copyWith(color: AppColors.textOnDark),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCustomer,
            tooltip: 'حذف العميل',
          ),
        ],
      ),
      body: BlocListener<CustomersBloc, CustomersState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is CustomersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معلومات العميل',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _nameController,
                          label: 'اسم العميل *',
                          hint: 'أدخل اسم العميل',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال اسم العميل';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            context.read<CustomerFormBloc>().add(
                                  CustomerNameChanged(value),
                                );
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField.phone(
                          controller: _phoneController,
                          label: 'رقم الهاتف *',
                          hint: 'أدخل رقم الهاتف',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            context.read<CustomerFormBloc>().add(
                                  CustomerPhoneChanged(value),
                                );
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _addressController,
                          label: 'العنوان',
                          hint: 'أدخل عنوان العميل',
                          prefixIcon: Icons.location_on,
                          onChanged: (value) {
                            context.read<CustomerFormBloc>().add(
                                  CustomerAddressChanged(value),
                                );
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField.multiline(
                          controller: _notesController,
                          label: 'ملاحظات',
                          hint: 'أدخل ملاحظات إضافية',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إحصائيات العميل',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 16),
                        _buildStatItem(
                          'إجمالي المشتريات',
                          '${widget.customer.totalPurchases.toStringAsFixed(2)} ريال',
                          Icons.shopping_cart,
                        ),
                        const Divider(height: 24),
                        _buildStatItem(
                          'الدين الحالي',
                          '${widget.customer.currentDebt.toStringAsFixed(2)} ريال',
                          Icons.account_balance_wallet,
                          valueColor: widget.customer.currentDebt > 0
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                        const Divider(height: 24),
                        _buildStatItem(
                          'حد الائتمان',
                          '${widget.customer.creditLimit.toStringAsFixed(2)} ريال',
                          Icons.credit_card,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<CustomersBloc, CustomersState>(
                  builder: (context, state) {
                    return AppButton.primary(
                      text: 'حفظ التعديلات',
                      icon: Icons.save,
                      onPressed: _updateCustomer,
                      isLoading: state is CustomersLoading,
                      fullWidth: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.h3.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
