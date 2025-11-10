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

/// شاشة إضافة عميل جديد
class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerFormBloc>().add(ResetCustomerForm());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
        customerType: 'عادي',
        creditLimit: 0,
        totalPurchases: 0,
        currentDebt: 0,
        isBlocked: false,
      );

      context.read<CustomersBloc>().add(AddCustomerEvent(customer));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة عميل جديد',
          style: AppTextStyles.h2.copyWith(color: AppColors.textOnDark),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnDark),
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
                          'معلومات العميل الأساسية',
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
                const SizedBox(height: 24),
                BlocBuilder<CustomersBloc, CustomersState>(
                  builder: (context, state) {
                    return AppButton.primary(
                      text: 'حفظ العميل',
                      icon: Icons.save,
                      onPressed: _saveCustomer,
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
}
