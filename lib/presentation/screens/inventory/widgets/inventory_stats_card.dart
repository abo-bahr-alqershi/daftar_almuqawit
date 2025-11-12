import 'package:flutter/material.dart';
import '../../../../domain/usecases/inventory/get_inventory_statistics.dart';

/// بطاقة إحصائيات المخزون
class InventoryStatsCard extends StatelessWidget {
  final InventoryStatistics statistics;

  const InventoryStatsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // الصف الأول: الإحصائيات الأساسية
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'إجمالي الأصناف',
                  value: statistics.totalItems.toInt().toString(),
                  icon: Icons.inventory,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: 'القيمة الإجمالية',
                  value: '${statistics.totalValue.toStringAsFixed(0)} ر.س',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // الصف الثاني: حالات المخزون
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'مخزون منخفض',
                  value: statistics.lowStockItems.toInt().toString(),
                  subtitle: '${statistics.lowStockPercentage.toStringAsFixed(1)}%',
                  icon: Icons.warning,
                  color: Colors.orange,
                  isWarning: statistics.lowStockItems > 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: 'مخزون زائد',
                  value: statistics.overStockItems.toInt().toString(),
                  subtitle: '${statistics.overStockPercentage.toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                  isWarning: statistics.overStockItems > 0,
                ),
              ),
            ],
          ),
          
          // مؤشر الحالة العامة
          if (statistics.needsAttention)
            _buildAttentionIndicator(),
        ],
      ),
    );
  }

  /// مؤشر الحاجة للانتباه
  Widget _buildAttentionIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.amber[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'يحتاج المخزون لانتباه - توجد أصناف تحتاج لإعادة تموين أو تقليل',
              style: TextStyle(
                color: Colors.amber[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة إحصائية واحدة
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isWarning;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          border: isWarning ? Border.all(color: color.withOpacity(0.3), width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الأيقونة والعنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // القيمة
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isWarning ? color : Colors.black87,
              ),
            ),
            
            // النص الفرعي
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
