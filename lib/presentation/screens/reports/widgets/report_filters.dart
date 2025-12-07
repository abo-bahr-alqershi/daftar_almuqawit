import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FilterType {
  all,
  sales,
  purchases,
  expenses,
  debts,
}

class ReportFilters extends StatefulWidget {
  const ReportFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.horizontal = true,
  });

  final FilterType selectedFilter;
  final Function(FilterType filter) onFilterChanged;
  final bool horizontal;

  @override
  State<ReportFilters> createState() => _ReportFiltersState();
}

class _ReportFiltersState extends State<ReportFilters> {
  @override
  Widget build(BuildContext context) {
    final filters = [
      _FilterOption(
        type: FilterType.all,
        label: 'الكل',
        icon: Icons.dashboard_rounded,
        color: const Color(0xFF6366F1),
      ),
      _FilterOption(
        type: FilterType.sales,
        label: 'المبيعات',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF10B981),
      ),
      _FilterOption(
        type: FilterType.purchases,
        label: 'المشتريات',
        icon: Icons.shopping_cart_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _FilterOption(
        type: FilterType.expenses,
        label: 'المصروفات',
        icon: Icons.payment_rounded,
        color: const Color(0xFFEF4444),
      ),
      _FilterOption(
        type: FilterType.debts,
        label: 'الديون',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF3B82F6),
      ),
    ];

    if (widget.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: filters.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(left: entry.key < filters.length - 1 ? 10 : 0),
              child: _FilterChip(
                option: entry.value,
                isSelected: widget.selectedFilter == entry.value.type,
                onTap: () => widget.onFilterChanged(entry.value.type),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters.map((filter) {
        return _FilterChip(
          option: filter,
          isSelected: widget.selectedFilter == filter.type,
          onTap: () => widget.onFilterChanged(filter.type),
        );
      }).toList(),
    );
  }
}

class _FilterOption {
  const _FilterOption({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });

  final FilterType type;
  final String label;
  final IconData icon;
  final Color color;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _FilterOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [option.color, option.color.withOpacity(0.8)],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? option.color : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: option.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                option.icon,
                size: 18,
                color: isSelected ? Colors.white : option.color,
              ),
              const SizedBox(width: 8),
              Text(
                option.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportSorting extends StatelessWidget {
  const ReportSorting({
    super.key,
    required this.sortOptions,
    required this.selectedSort,
    required this.onSortChanged,
    required this.isAscending,
    required this.onDirectionChanged,
  });

  final List<String> sortOptions;
  final String selectedSort;
  final Function(String sort) onSortChanged;
  final bool isAscending;
  final Function(bool ascending) onDirectionChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: selectedSort,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Color(0xFF6B7280),
              ),
              items: sortOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.selectionClick();
                  onSortChanged(value);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onDirectionChanged(!isAscending);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAscending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: const Color(0xFF6366F1),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
