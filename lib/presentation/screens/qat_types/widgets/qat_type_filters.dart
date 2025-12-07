import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// فلترة أنواع القات - تصميم احترافي راقي
class QatTypeFilters extends StatefulWidget {
  final String selectedFilter;
  final String selectedSortBy;
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;

  const QatTypeFilters({
    super.key,
    this.selectedFilter = 'الكل',
    this.selectedSortBy = 'الاسم',
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  State<QatTypeFilters> createState() => _QatTypeFiltersState();
}

class _QatTypeFiltersState extends State<QatTypeFilters> {
  late String _selectedFilter;
  late String _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
    _selectedSortBy = widget.selectedSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تصفية أنواع القات',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quality filter
          _buildSectionTitle('حسب الجودة'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('الكل', const Color(0xFF6B7280)),
              _buildFilterChip('ممتاز', const Color(0xFF16A34A)),
              _buildFilterChip('جيد جداً', const Color(0xFF0EA5E9)),
              _buildFilterChip('جيد', const Color(0xFF6366F1)),
              _buildFilterChip('متوسط', const Color(0xFFF59E0B)),
              _buildFilterChip('عادي', const Color(0xFFEF4444)),
            ],
          ),

          const SizedBox(height: 24),

          // Sort
          _buildSectionTitle('الترتيب'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('الاسم', Icons.sort_by_alpha),
              _buildSortChip('سعر الشراء', Icons.shopping_cart_outlined),
              _buildSortChip('سعر البيع', Icons.sell_outlined),
              _buildSortChip('الربح', Icons.trending_up),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedFilter = 'الكل';
                        _selectedSortBy = 'الاسم';
                      });
                      widget.onFilterChanged('الكل');
                      widget.onSortChanged('الاسم');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: const Text(
                        'إعادة تعيين',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Material(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onFilterChanged(_selectedFilter);
                      widget.onSortChanged(_selectedSortBy);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'تطبيق الفلاتر',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, IconData icon) {
    final isSelected = _selectedSortBy == label;
    const color = Color(0xFF0EA5E9);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedSortBy = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// عرض الفلترة كـ Bottom Sheet
Future<void> showQatTypeFilters({
  required BuildContext context,
  required String selectedFilter,
  required String selectedSortBy,
  required Function(String) onFilterChanged,
  required Function(String) onSortChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => QatTypeFilters(
      selectedFilter: selectedFilter,
      selectedSortBy: selectedSortBy,
      onFilterChanged: onFilterChanged,
      onSortChanged: onSortChanged,
    ),
  );
}
