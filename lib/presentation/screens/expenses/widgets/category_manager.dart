import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// مدير الفئات
/// 
/// يوفر واجهة لإدارة فئات المصروفات (إضافة، تعديل، حذف)
class CategoryManager extends StatefulWidget {
  final List<String> categories;
  final Function(String) onAddCategory;
  final Function(String, String) onEditCategory;
  final Function(String) onDeleteCategory;

  const CategoryManager({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onEditCategory,
    required this.onDeleteCategory,
  });

  @override
  State<CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  final _categoryController = TextEditingController();
  String? _editingCategory;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    _categoryController.clear();
    _editingCategory = null;
    _showCategoryDialog('إضافة فئة جديدة');
  }

  void _showEditDialog(String category) {
    _categoryController.text = category;
    _editingCategory = category;
    _showCategoryDialog('تعديل الفئة');
  }

  void _showCategoryDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final categoryName = _categoryController.text.trim();
              if (categoryName.isNotEmpty) {
                if (_editingCategory != null) {
                  widget.onEditCategory(_editingCategory!, categoryName);
                } else {
                  widget.onAddCategory(categoryName);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الفئة'),
        content: Text('هل أنت متأكد من حذف الفئة "$category"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDeleteCategory(category);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الفئات',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('إضافة فئة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.categories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد فئات',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.categories.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.category,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  category,
                  style: AppTextStyles.bodyLarge,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditDialog(category),
                      color: AppColors.info,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _showDeleteDialog(category),
                      color: AppColors.danger,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
