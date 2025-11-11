import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/snackbar_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import './widgets/qat_type_form.dart';

/// شاشة إضافة نوع قات
/// 
/// تسمح بإضافة نوع قات جديد
class AddQatTypeScreen extends StatefulWidget {
  const AddQatTypeScreen({super.key});

  @override
  State<AddQatTypeScreen> createState() => _AddQatTypeScreenState();
}

class _AddQatTypeScreenState extends State<AddQatTypeScreen> {
  final _formKey = GlobalKey<QatTypeFormState>();

  Future<void> _submitQatType() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final formData = _formKey.currentState!.getFormData();

    context.read<QatTypesBloc>().add(
      AddQatTypeEvent(
        QatType(
          name: formData['name'],
          qualityGrade: formData['qualityGrade'],
          defaultBuyPrice: formData['defaultBuyPrice'],
          defaultSellPrice: formData['defaultSellPrice'],
          icon: formData['icon'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة نوع قات'),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: BlocConsumer<QatTypesBloc, QatTypesState>(
          listener: (context, state) {
            if (state is QatTypeOperationSuccess) {
              SnackbarWidget.showSuccess(
                context: context,
                message: 'تمت إضافة نوع القات بنجاح',
              );
              Navigator.of(context).pop(true);
            } else if (state is QatTypesError) {
              SnackbarWidget.showError(
                context: context,
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is QatTypesLoading;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                QatTypeForm(
                  key: _formKey,
                  isLoading: isLoading,
                  onSubmit: _submitQatType,
                  onCancel: () async {
                    final confirm = await ConfirmDialog.show(
                      context,
                      title: 'إلغاء العملية',
                      message: 'هل تريد إلغاء إضافة نوع القات؟',
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
      ),
    );
  }
}
