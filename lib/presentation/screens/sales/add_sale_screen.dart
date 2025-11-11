import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/sale.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_event.dart';
import '../../blocs/sales/sales_state.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/sale_form.dart';

/// شاشة إضافة عملية بيع
class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات المطلوبة
    context.read<CustomersBloc>().add(LoadCustomers());
    context.read<QatTypesBloc>().add(LoadQatTypes());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('إضافة عملية بيع'),
      backgroundColor: AppColors.primary,
    ),
    body: BlocConsumer<SalesBloc, SalesState>(
      listener: (context, state) {
        if (state is SalesSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت إضافة البيع بنجاح')),
          );
          Navigator.of(context).pop();
        } else if (state is SalesError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, salesState) {
        if (salesState is SalesLoading) {
          return const LoadingWidget();
        }

        return BlocBuilder<CustomersBloc, CustomersState>(
          builder: (context, customersState) =>
              BlocBuilder<QatTypesBloc, QatTypesState>(
                builder: (context, qatTypesState) {
                  if (customersState is CustomersLoaded &&
                      qatTypesState is QatTypesLoaded) {
                    return SaleForm(
                      customers: customersState.customers,
                      qatTypes: qatTypesState.qatTypes,
                      onSubmit: (data) {
                        context.read<SalesBloc>().add(
                          AddSaleEvent(
                            Sale(
                              date: data['date'],
                              time: data['time'],
                              customerId: data['customerId'],
                              qatTypeId: data['qatTypeId'],
                              quantity: data['quantity'],
                              unit: data['unit'] ?? 'كيس',
                              unitPrice: data['unitPrice'],
                              totalAmount: data['totalAmount'],
                              discount: data['discount'],
                              paymentMethod: data['paymentMethod'],
                              notes: data['notes'],
                            ),
                          ),
                        );
                      },
                      onCancel: () => Navigator.of(context).pop(),
                    );
                  }

                  return const LoadingWidget();
                },
              ),
        );
      },
    ),
  );
}
