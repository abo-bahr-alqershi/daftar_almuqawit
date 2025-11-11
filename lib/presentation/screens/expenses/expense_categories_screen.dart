import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/expenses/expenses_bloc.dart';
import '../../blocs/expenses/expenses_event.dart';
import '../../blocs/expenses/expenses_state.dart';
import '../../widgets/common/snackbar_widget.dart';
import './widgets/category_manager.dart';

/// شاشة فئات المصروفات
/// 
/// تعرض وتدير فئات المصروفات المختلفة
class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() => _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> {
  List<String> _categories = [
    'رواتب',
    'إيجار',
    'كهرباء',
    'ماء',
    'مواصلات',
    'صيانة',
    'مشتريات',
    'اتصالات',
    'تسويق',
  ];

  void _addCategory(String category) {
    setState(() {
      if (!_categories.contains(category)) {
        _categories.add(category);
        SnackbarWidget.showSuccess(
          context: context,
          message: 'تمت إضافة الفئة بنجاح',
        );
      } else {
        SnackbarWidget.showError(
          context: context,
          message: 'الفئة موجودة مسبقاً',
        );
      }
    });
  }

  void _editCategory(String oldCategory, String newCategory) {
    setState(() {
      final index = _categories.indexOf(oldCategory);
      if (index != -1 && !_categories.contains(newCategory)) {
        _categories[index] = newCategory;
        SnackbarWidget.showSuccess(
          context: context,
          message: 'تم تعديل الفئة بنجاح',
        );
      } else if (_categories.contains(newCategory)) {
        SnackbarWidget.showError(
          context: context,
          message: 'الفئة موجودة مسبقاً',
        );
      }
    });
  }

  void _deleteCategory(String category) {
    setState(() {
      _categories.remove(category);
      SnackbarWidget.showSuccess(
        context: context,
        message: 'تم حذف الفئة بنجاح',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('فئات المصروفات'),
          backgroundColor: AppColors.danger,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'يمكنك إضافة وتعديل الفئات حسب احتياجاتك',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CategoryManager(
              categories: _categories,
              onAddCategory: _addCategory,
              onEditCategory: _editCategory,
              onDeleteCategory: _deleteCategory,
            ),
          ],
        ),
      ),
    );
  }
}
