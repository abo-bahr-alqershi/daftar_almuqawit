import 'package:flutter/material.dart';
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
        const Text(
          'تصفية المخزون',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // خيارات التصفية
        ...InventoryFilterType.values.map((filter) => 
          RadioListTile<InventoryFilterType>(
            title: Text(_getFilterTitle(filter)),
            subtitle: Text(_getFilterDescription(filter)),
            value: filter,
            groupValue: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
            },
          ),
        ),
        
        // خيارات إضافية للمخزن (إذا كانت التصفية بالمخزن)
        if (_selectedFilter == InventoryFilterType.warehouse) ...[
          const SizedBox(height: 16),
          const Text(
            'اختيار المخزن:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedWarehouse,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'المخزن',
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('المخزن الرئيسي')),
              DropdownMenuItem(value: 2, child: Text('مخزن فرعي 1')),
              DropdownMenuItem(value: 3, child: Text('مخزن فرعي 2')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedWarehouse = value!;
              });
            },
          ),
        ],
        
        const SizedBox(height: 24),
        
        // أزرار الإجراء
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final options = _selectedFilter == InventoryFilterType.warehouse
                      ? {'warehouseId': _selectedWarehouse}
                      : null;
                  
                  widget.onFilterChanged?.call(_selectedFilter, options);
                  Navigator.pop(context);
                },
                child: const Text('تطبيق التصفية'),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
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
}

/// نافذة حوار التصفية
class InventoryFilterDialog extends StatelessWidget {
  final InventoryFilterType currentFilter;
  final Function(InventoryFilterType, Map<String, dynamic>?)? onFilterChanged;

  const InventoryFilterDialog({
    super.key,
    this.currentFilter = InventoryFilterType.all,
    this.onFilterChanged,
  });

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
