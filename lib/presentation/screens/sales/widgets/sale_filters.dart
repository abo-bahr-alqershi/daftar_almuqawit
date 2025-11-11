import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// فلاتر المبيعات - تصميم متطور
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

class _SaleFiltersState extends State<SaleFilters>
    with TickerProviderStateMixin {
  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _filterAnimation;

  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  void _initAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutBack,
    );

    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.elasticOut,
    );

    _searchAnimationController.forward();
    _filterAnimationController.forward();
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          _buildHeader(),
          const SizedBox(height: 20),

          // Search Bar
          ScaleTransition(
            scale: _searchAnimation,
            child: _buildModernSearchBar(),
          ),

          const SizedBox(height: 20),

          // Filter Chips
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_filterAnimation),
            child: FadeTransition(
              opacity: _filterAnimation,
              child: _buildModernFilterChips(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'البحث والتصفية',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isSearchFocused
              ? [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.accent.withOpacity(0.05),
                ]
              : [AppColors.surface, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearchFocused
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border.withOpacity(0.2),
          width: _isSearchFocused ? 2 : 1,
        ),
        boxShadow: _isSearchFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        focusNode: _searchFocusNode,
        onChanged: (value) {
          widget.onSearchChanged(value);
          if (value.isNotEmpty) {
            HapticFeedback.lightImpact();
          }
        },
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'ابحث عن فاتورة، عميل، أو منتج...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isSearchFocused ? Icons.search_rounded : Icons.search,
                color: _isSearchFocused
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    widget.onSearchChanged('');
                    HapticFeedback.lightImpact();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'تصفية حسب',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: widget.filterOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              final isSelected = widget.selectedFilter == filter;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 50)),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _ModernFilterChip(
                        label: filter,
                        isSelected: isSelected,
                        onSelected: () {
                          widget.onFilterChanged(filter);
                          HapticFeedback.lightImpact();
                        },
                        icon: _getFilterIcon(filter),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'الكل':
        return Icons.all_inclusive;
      case 'اليوم':
        return Icons.today;
      case 'الأسبوع':
        return Icons.date_range;
      case 'الشهر':
        return Icons.calendar_month;
      case 'مدفوع':
        return Icons.check_circle_outline;
      case 'غير مدفوع':
        return Icons.pending_outlined;
      default:
        return Icons.filter_alt_outlined;
    }
  }
}

class _ModernFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final IconData icon;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.icon,
  });

  @override
  State<_ModernFilterChip> createState() => _ModernFilterChipState();
}

class _ModernFilterChipState extends State<_ModernFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isSelected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.border.withOpacity(0.3),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
