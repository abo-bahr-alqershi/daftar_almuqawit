import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CustomerSearch extends StatefulWidget {
  final String? initialQuery;
  final String? initialCustomerType;
  final String? initialStatus;
  final void Function(String query)? onSearch;
  final void Function(String? customerType)? onCustomerTypeChanged;
  final void Function(String? status)? onStatusChanged;
  final VoidCallback? onClearFilters;

  const CustomerSearch({
    super.key,
    this.initialQuery,
    this.initialCustomerType,
    this.initialStatus,
    this.onSearch,
    this.onCustomerTypeChanged,
    this.onStatusChanged,
    this.onClearFilters,
  });

  @override
  State<CustomerSearch> createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<CustomerSearch>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    widget.onSearch?.call(query);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.98)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isFocused
                  ? AppColors.accent.withOpacity(0.5)
                  : AppColors.border.withOpacity(0.3),
              width: _isFocused ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? AppColors.accent.withOpacity(0.1)
                    : Colors.black.withOpacity(0.03),
                blurRadius: _isFocused ? 20 : 10,
                offset: Offset(0, _isFocused ? 6 : 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
              _handleSearch(value);
            },
            onSubmitted: _handleSearch,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isFocused = true);
              _animationController.forward();
            },
            onTapOutside: (_) {
              setState(() => _isFocused = false);
              _animationController.reverse();
              FocusScope.of(context).unfocus();
            },
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث عن عميل بالاسم، الهاتف أو الكنية...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.danger,
                          size: 16,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _searchController.clear();
                        setState(() {});
                        _handleSearch('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
