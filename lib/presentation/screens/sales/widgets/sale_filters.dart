import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// فلاتر المبيعات - تصميم راقي واحترافي
class SaleFilters extends StatefulWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<String> filterOptions;

  const SaleFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    this.filterOptions = const [
      'الكل',
      'اليوم',
      'الأسبوع',
      'الشهر',
      'مدفوع',
      'غير مدفوع',
    ],
  });

  @override
  State<SaleFilters> createState() => _SaleFiltersState();
}

class _SaleFiltersState extends State<SaleFilters> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          _buildSearchBar(),
          const SizedBox(height: 18),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.filter_list_rounded,
            color: Color(0xFF10B981),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'البحث والتصفية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'ابحث عن فواتير أو قم بتصفية النتائج',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isSearchFocused
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFE5E7EB),
          width: _isSearchFocused ? 1.5 : 1,
        ),
        boxShadow: _isSearchFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: 'ابحث عن فاتورة، عميل، أو منتج...',
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isSearchFocused
                ? const Color(0xFF10B981)
                : const Color(0xFF9CA3AF),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          widget.onSearchChanged(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.tune_rounded, size: 14, color: Color(0xFF9CA3AF)),
            SizedBox(width: 6),
            Text(
              'تصفية حسب',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.filterOptions.map((filter) {
            final isSelected = widget.selectedFilter == filter;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onFilterChanged(filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFilterIcon(filter),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'الكل':
        return Icons.grid_view_rounded;
      case 'اليوم':
        return Icons.today_rounded;
      case 'الأسبوع':
        return Icons.date_range_rounded;
      case 'الشهر':
        return Icons.calendar_month_rounded;
      case 'مدفوع':
        return Icons.check_circle_rounded;
      case 'غير مدفوع':
        return Icons.pending_rounded;
      default:
        return Icons.filter_alt_rounded;
    }
  }
}
