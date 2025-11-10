import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/expense.dart';
import '../../blocs/expenses/expenses_bloc.dart';
import '../../blocs/expenses/expenses_event.dart';
import '../../blocs/expenses/expenses_state.dart';
import '../../widgets/common/snackbar_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import './widgets/expense_form.dart';

/// شاشة إضافة مصروف
/// 
/// تسمح بإضافة مصروف جديد
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<ExpenseFormState>();

  Future<void> _submitExpense() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final formData = _formKey.currentState!.getFormData();
    final now = DateTime.now();

    context.read<ExpensesBloc>().add(
      AddExpenseEvent(
        Expense(
          amount: formData['amount'],
          category: formData['category'],
          description: formData['description'],
          notes: formData['notes'],
          date: formData['date'].toString().split(' ')[0],
          time: '${now.hour}:${now.minute}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مصروف'),
        backgroundColor: AppColors.danger,
        elevation: 0,
      ),
      body: BlocConsumer<ExpensesBloc, ExpensesState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            SnackbarWidget.showSuccess(
              context: context,
              message: 'تمت إضافة المصروف بنجاح',
            );
            Navigator.of(context).pop(true);
          } else if (state is ExpensesError) {
            SnackbarWidget.showError(
              context: context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ExpensesLoading;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ExpenseForm(
                key: _formKey,
                isLoading: isLoading,
                onSubmit: _submitExpense,
                onCancel: () async {
                  final confirm = await ConfirmDialog.show(
                    context,
                    title: 'إلغاء العملية',
                    message: 'هل تريد إلغاء إضافة المصروف؟',
                    confirmText: 'نعم، إلغاء',
                    cancelText: 'لا، متابعة',
                  );
                  if (confirm == true && mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
