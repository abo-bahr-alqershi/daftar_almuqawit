import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_date_picker.dart';

/// شاشة إضافة عملية بيع
class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCustomer;
  String? _selectedQatType;
  String _paymentMethod = 'نقدي';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عملية بيع'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<SalesBloc, SalesState>(
        listener: (context, state) {
          if (state is SalesSuccess) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppDatePicker(
                  label: 'تاريخ البيع',
                  selectedDate: _selectedDate,
                  onDateSelected: (date) => setState(() => _selectedDate = date),
                ),
                const SizedBox(height: 16),
                AppTextField.number(
                  controller: _quantityController,
                  label: 'الكمية',
                  validator: (val) => val?.isEmpty == true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                AppTextField.currency(
                  controller: _priceController,
                  label: 'السعر',
                  validator: (val) => val?.isEmpty == true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                AppTextField.multiline(
                  controller: _notesController,
                  label: 'ملاحظات',
                  hint: 'أضف أي ملاحظات',
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  text: 'حفظ',
                  fullWidth: true,
                  isLoading: state is SalesLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<SalesBloc>().add(AddSale(
                        quantity: double.parse(_quantityController.text),
                        price: double.parse(_priceController.text),
                        notes: _notesController.text,
                        date: _selectedDate ?? DateTime.now(),
                      ));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
