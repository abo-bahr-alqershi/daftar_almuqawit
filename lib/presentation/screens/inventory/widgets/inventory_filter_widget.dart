import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/usecases/inventory/get_inventory_list.dart';

/// ويدجت تصفية المخزون
class InventoryFilterWidget extends StatefulWidget {
  final InventoryFilterType currentFilter;
  final Function(InventoryFilterType, Map<String, dynamic>?)? onFilterChanged;

  const InventoryFilterWidget({
    super.key,
    this.currentFilter = InventoryFilterType.all,
    this.onFilterChanged,
  });

  @override
  State<InventoryFilterWidget> createState() => _InventoryFilterWidgetState();
}

class _InventoryFilterWidgetState extends State<InventoryFilterWidget> {
  InventoryFilterType _selectedFilter = InventoryFilterType.all;
  int _selectedWarehouse = 1;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.filter_list_rounded,
                color: AppColors.info,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'تصفية المخزون',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // خيارات التصفية
        ...InventoryFilterType.values.map((filter) => 
          _FilterOption(
            filter: filter,
            isSelected: _selectedFilter == filter,
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            title: _getFilterTitle(filter),
            description: _getFilterDescription(filter),
            icon: _getFilterIcon(filter),
            color: _getFilterColor(filter),
          ),
        ),
        
        // خيارات إضافية للمخزن
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _selectedFilter == InventoryFilterType.warehouse
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warehouse_rounded,
                                size: 18,
                                color: AppColors.info.withOpacity(0.7),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'اختيار المخزن',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.border.withOpacity(0.5),
                              ),
                            ),
                            child: DropdownButtonFormField<int>(
                              value: _selectedWarehouse,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('المخزن الرئيسي'),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text('مخزن فرعي 1'),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text('مخزن فرعي 2'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedWarehouse = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        
        const SizedBox(height: 24),
        
        // أزرار الإجراء
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.info,
                      AppColors.info.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.info.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final options = _selectedFilter == InventoryFilterType.warehouse
                          ? {'warehouseId': _selectedWarehouse}
                          : null;
                      
                      widget.onFilterChanged?.call(_selectedFilter, options);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: const Text(
                        'تطبيق التصفية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.5),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// الحصول على عنوان التصفية
  String _getFilterTitle(InventoryFilterType filter) {
    switch (filter) {
      case InventoryFilterType.all:
        return 'جميع الأصناف';
      case InventoryFilterType.lowStock:
        return 'مخزون منخفض';
      case InventoryFilterType.overStock:
        return 'مخزون زائد';
      case InventoryFilterType.warehouse:
        return 'تصفية بالمخزن';
      case InventoryFilterType.search:
        return 'البحث';
    }
  }

  /// الحصول على وصف التصفية
  String _getFilterDescription(InventoryFilterType filter) {
    switch (filter) {
      case InventoryFilterType.all:
        return 'عرض جميع أصناف المخزون';
      case InventoryFilterType.lowStock:
        return 'الأصناف التي تحتاج لإعادة تموين';
      case InventoryFilterType.overStock:
        return 'الأصناف التي تجاوزت الحد الأقصى';
      case InventoryFilterType.warehouse:
        return 'تصفية حسب مخزن معين';
      case InventoryFilterType.search:
        return 'البحث في أسماء الأصناف';
    }
  }

  /// الحصول على أيقونة التصفية
  IconData _getFilterIcon(InventoryFilterType filter) {
    switch (filter) {
      case InventoryFilterType.all:
        return Icons.inventory_2_rounded;
      case InventoryFilterType.lowStock:
        return Icons.warning_rounded;
      case InventoryFilterType.overStock:
        return Icons.trending_up_rounded;
      case InventoryFilterType.warehouse:
        return Icons.warehouse_rounded;
      case InventoryFilterType.search:
        return Icons.search_rounded;
    }
  }

  /// الحصول على لون التصفية
  Color _getFilterColor(InventoryFilterType filter) {
    switch (filter) {
      case InventoryFilterType.all:
        return AppColors.info;
      case InventoryFilterType.lowStock:
        return AppColors.warning;
      case InventoryFilterType.overStock:
        return AppColors.purchases;
      case InventoryFilterType.warehouse:
        return AppColors.success;
      case InventoryFilterType.search:
        return AppColors.info;
    }
  }
}

/// خيار تصفية واحد
class _FilterOption extends StatelessWidget {
  final InventoryFilterType filter;
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _FilterOption({
    required this.filter,
    required this.isSelected,
    required this.onTap,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.3)
                : AppColors.border.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // الأيقونة
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // النصوص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // أيقونة التحديد
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? color
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? color
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// نافذة حوار التصفية
class InventoryFilterDialog extends StatelessWidget {
  const InventoryFilterDialog({
    super.key,
    this.currentFilter = InventoryFilterType.all,
    this.onFilterChanged,
  });

  final InventoryFilterType currentFilter;
  final Function(InventoryFilterType, Map<String, dynamic>?)? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: InventoryFilterWidget(
        currentFilter: currentFilter,
        onFilterChanged: onFilterChanged,
      ),
    );
  }
}
