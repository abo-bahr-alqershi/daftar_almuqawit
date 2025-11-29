import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/expenses_tutorial_service.dart';
import '../../../domain/entities/expense.dart';
import '../../blocs/expenses/expenses_bloc.dart';
import '../../blocs/expenses/expenses_event.dart';
import '../../blocs/expenses/expenses_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import './widgets/expense_form.dart';

/// شاشة تعديل مصروف - تصميم راقي هادئ
class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({
    super.key,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<ExpenseFormState>();

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitExpense() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final formData = _formKey.currentState!.getFormData();
    final now = DateTime.now();

    final updatedExpense = Expense(
      id: widget.expense.id,
      amount: formData['amount'],
      category: formData['category'],
      description: formData['description'],
      notes: formData['notes'],
      date: formData['date'].toString().split(' ')[0],
      time: formData['time'] ?? '${now.hour}:${now.minute}',
      paymentMethod: formData['paymentMethod'] ?? 'نقد',
      recurring: formData['recurring'] ?? false,
    );

    if (mounted) {
      context.read<ExpensesBloc>().add(UpdateExpenseEvent(updatedExpense));
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
              controller: _scrollController,
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: BlocConsumer<ExpensesBloc, ExpensesState>(
                    listener: (context, state) {
                      if (state is ExpenseOperationSuccess) {
                        _showSuccessMessage(context, 'تم تعديل المصروف بنجاح');
                        Navigator.of(context).pop(true);
                      } else if (state is ExpensesError) {
                        _showErrorMessage(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is ExpensesLoading;

                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoCard(),
                            const SizedBox(height: 20),
                            ExpenseForm(
                              key: _formKey,
                              initialExpense: widget.expense,
                              isLoading: isLoading,
                              onSubmit: _submitExpense,
                              onCancel: () async {
                                final confirm = await ConfirmDialog.show(
                                  context,
                                  title: 'إلغاء التعديل',
                                  message: 'هل تريد إلغاء تعديل المصروف؟',
                                  confirmText: 'نعم، إلغاء',
                                  cancelText: 'لا، متابعة',
                                );
                                if (confirm == true && context.mounted) {
                                  Navigator.of(context).pop();
                                }
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
            AppColors.expense.withOpacity(0.08),
            AppColors.danger.withOpacity(0.05),
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
            title: 'إلغاء التعديل',
            message: 'هل تريد إلغاء تعديل المصروف؟',
            confirmText: 'نعم، إلغاء',
            cancelText: 'لا، متابعة',
          );
          if (confirm == true && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.help_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            final formState = _formKey.currentState;
            if (formState != null && formState.mounted) {
              final keys = formState.tutorialKeys;

              ExpensesTutorialService.showFormTutorial(
                context: context,
                categorySectionKey: keys['category']!,
                amountFieldKey: keys['amount']!,
                descriptionFieldKey: keys['description']!,
                paymentMethodKey: keys['paymentMethod']!,
                dateFieldKey: keys['date']!,
                recurringSwitchKey: keys['recurring']!,
                notesFieldKey: keys['notes']!,
                saveButtonKey: keys['saveButton']!,
                scrollController: _scrollController,
                onFinish: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تمت التعليمات بنجاح'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('يرجى انتظار تحميل النموذج أولاً'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
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
                            colors: [AppColors.expense, AppColors.danger],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.expense.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
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
                              'تعديل المصروف',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.expense.category,
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
              'قم بتعديل بيانات المصروف أدناه',
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
