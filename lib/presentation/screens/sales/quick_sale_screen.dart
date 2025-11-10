import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/sales/quick_sale/quick_sale_bloc.dart';
import '../../blocs/sales/quick_sale/quick_sale_event.dart';
import '../../blocs/sales/quick_sale/quick_sale_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/number_pad.dart';

/// شاشة البيع السريع
/// 
/// تسمح ببيع سريع دون الحاجة لإدخال تفاصيل كثيرة
class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen> {
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedQatType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيع سريع'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<QuickSaleBloc, QuickSaleState>(
        listener: (context, state) {
          if (state is QuickSaleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت عملية البيع بنجاح')),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField.number(
                  controller: _quantityController,
                  label: 'الكمية (كيس)',
                  hint: 'أدخل الكمية',
                  prefixIcon: Icons.shopping_bag,
                ),
                const SizedBox(height: 16),
                AppTextField.currency(
                  controller: _priceController,
                  label: 'السعر',
                  hint: 'أدخل السعر',
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  text: 'تأكيد البيع',
                  fullWidth: true,
                  isLoading: state is QuickSaleLoading,
                  onPressed: () {
                    context.read<QuickSaleBloc>().add(
                      SubmitQuickSale(
                        quantity: double.tryParse(_quantityController.text) ?? 0,
                        price: double.tryParse(_priceController.text) ?? 0,
                      ),
                    );
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
