import 'package:flutter/material.dart';
import '../../../../domain/entities/inventory.dart';

/// ويدجت قائمة المخزون
class InventoryListWidget extends StatelessWidget {
  final List<Inventory> inventory;
  final Function(Inventory)? onItemTap;
  final Function(Inventory)? onItemEdit;
  final Function(Inventory)? onAdjustQuantity;
  final bool showLowStockWarning;

  const InventoryListWidget({
    super.key,
    required this.inventory,
    this.onItemTap,
    this.onItemEdit,
    this.onAdjustQuantity,
    this.showLowStockWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    if (inventory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد أصناف في المخزون',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: inventory.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = inventory[index];
        return _InventoryItemCard(
          item: item,
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
          onEdit: onItemEdit != null ? () => onItemEdit!(item) : null,
          onAdjustQuantity: onAdjustQuantity != null ? () => onAdjustQuantity!(item) : null,
          showLowStockWarning: showLowStockWarning,
        );
      },
    );
  }
}

/// بطاقة عنصر المخزون
class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({
    required this.item,
    this.onTap,
    this.onEdit,
    this.onAdjustQuantity,
    this.showLowStockWarning = false,
  });

  final Inventory item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAdjustQuantity;
  final bool showLowStockWarning;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف الأول: اسم الصنف والإجراءات
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.qatTypeName ?? 'غير محدد',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الوحدة: ${item.unit}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // أيقونة حالة المخزون
                  _buildStockStatusIcon(),
                  
                  // قائمة الإجراءات
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'adjust':
                          onAdjustQuantity?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'adjust',
                        child: Row(
                          children: [
                            Icon(Icons.tune, size: 20),
                            SizedBox(width: 8),
                            Text('تعديل الكمية'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // الصف الثاني: الكميات
              Row(
                children: [
                  _buildQuantityInfo(
                    label: 'الكمية الحالية',
                    value: item.currentQuantity,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildQuantityInfo(
                    label: 'المتاحة للبيع',
                    value: item.availableQuantity,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildQuantityInfo(
                    label: 'الحد الأدنى',
                    value: item.minimumQuantity,
                    color: Colors.orange,
                  ),
                ],
              ),
              
              // شريط التقدم (إختياري)
              if (item.maximumQuantity != null && item.maximumQuantity! > 0)
                _buildProgressBar(),
              
              // تحذير المخزون المنخفض
              if (showLowStockWarning && item.isLowStock)
                _buildLowStockWarning(),
              
              // معلومات إضافية
              if (item.averageCost != null || item.lastPurchaseDate != null)
                _buildAdditionalInfo(),
            ],
          ),
        ),
      ),
    );
  }

  /// أيقونة حالة المخزون
  Widget _buildStockStatusIcon() {
    Color color;
    IconData icon;

    if (item.isEmpty) {
      color = Colors.red;
      icon = Icons.remove_circle;
    } else if (item.isLowStock) {
      color = Colors.orange;
      icon = Icons.warning;
    } else if (item.isOverStock) {
      color = Colors.purple;
      icon = Icons.trending_up;
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
    }

    return Icon(icon, color: color, size: 24);
  }

  /// معلومات الكمية
  Widget _buildQuantityInfo({
    required String label,
    required double value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// شريط التقدم للكمية
  Widget _buildProgressBar() {
    if (item.maximumQuantity == null || item.maximumQuantity! == 0) {
      return const SizedBox.shrink();
    }

    final percentage = (item.currentQuantity / item.maximumQuantity!).clamp(0.0, 1.0);
    Color barColor;

    if (percentage >= 0.8) {
      barColor = Colors.red; // ممتلئ تقريباً
    } else if (percentage >= 0.5) {
      barColor = Colors.orange; // نصف ممتلئ
    } else {
      barColor = Colors.green; // مساحة متاحة
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('الامتلاء: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('${(percentage * 100).toInt()}%', 
                 style: TextStyle(fontSize: 12, color: barColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
      ],
    );
  }

  /// تحذير المخزون المنخفض
  Widget _buildLowStockWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 16, color: Colors.orange[700]),
          const SizedBox(width: 4),
          Text(
            'مخزون منخفض - يحتاج لإعادة تموين',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// معلومات إضافية
  Widget _buildAdditionalInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (item.averageCost != null) ...[
            const Icon(Icons.attach_money, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'متوسط التكلفة: ${item.averageCost!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          
          if (item.averageCost != null && item.lastPurchaseDate != null)
            const SizedBox(width: 16),
          
          if (item.lastPurchaseDate != null) ...[
            const Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'آخر شراء: ${item.lastPurchaseDate}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
