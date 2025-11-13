import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/debt.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/debts/debts_bloc.dart';
import '../../blocs/debts/debts_event.dart';
import '../../blocs/debts/debts_state.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import './widgets/debt_form.dart';

/// شاشة إضافة دين جديد - تصميم راقي هادئ
class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<DebtFormState>();

  @override
  void initState() {
    super.initState();
    context.read<CustomersBloc>().add(LoadCustomers());
  }

  Future<void> _submitDebt() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final formData = _formKey.currentState!.getFormData();

    final debt = Debt(
      personType: 'عميل',
      personId: formData['customerId'],
      personName: formData['customerName'],
      customerPhone: formData['customerPhone'],
      transactionType: formData['debtType'],
      originalAmount: formData['amount'],
      remainingAmount: formData['amount'],
      date: formData['date'].toString().split(' ')[0],
      dueDate: formData['dueDate']?.toString().split(' ')[0],
      notes: formData['notes'],
      status: 'غير مسدد',
    );

    if (mounted) {
      context.read<DebtsBloc>().add(AddDebtEvent(debt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: BlocConsumer<DebtsBloc, DebtsState>(
                    listener: (context, state) {
                      if (state is DebtOperationSuccess) {
                        _showSuccessMessage(context, 'تمت إضافة الدين بنجاح');
                        Navigator.of(context).pop(true);
                      } else if (state is DebtsError) {
                        _showErrorMessage(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is DebtsLoading;

                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoCard(),
                            const SizedBox(height: 20),
                            BlocBuilder<CustomersBloc, CustomersState>(
                              builder: (context, customerState) {
                                final customers = customerState is CustomersLoaded
                                    ? customerState.customers
                                    : <Customer>[]; // تحديد النوع بشكل صريح

                                return DebtForm(
                                  key: _formKey,
                                  customers: customers,
                                  isLoading: isLoading,
                                  onSubmit: _submitDebt,
                                  onCancel: () async {
                                    final confirm = await ConfirmDialog.show(
                                      context,
                                      title: 'إلغاء العملية',
                                      message: 'هل تريد إلغاء إضافة الدين؟',
                                      confirmText: 'نعم، إلغاء',
                                      cancelText: 'لا، متابعة',
                                    );
                                    if (confirm == true && context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.danger.withOpacity(0.08),
            AppColors.warning.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        onPressed: () async {
          final confirm = await ConfirmDialog.show(
            context,
            title: 'إلغاء العملية',
            message: 'هل تريد إلغاء إضافة الدين؟',
            confirmText: 'نعم، إلغاء',
            cancelText: 'لا، متابعة',
          );
          if (confirm == true && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.danger, AppColors.warning],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.danger.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'إضافة دين',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تسجيل دين جديد على العميل',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: AppColors.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'قم بتعبئة البيانات أدناه لتسجيل دين جديد',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
