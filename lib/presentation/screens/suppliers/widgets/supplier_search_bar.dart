import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SupplierSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function(String)? onSearch;
  final VoidCallback? onClear;
  final String? hintText;

  const SupplierSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onSearch,
    this.onClear,
    this.hintText,
  });

  @override
  State<SupplierSearchBar> createState() => _SupplierSearchBarState();
}

class _SupplierSearchBarState extends State<SupplierSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

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
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
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
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.border.withOpacity(0.3),
              width: _isFocused ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.03),
                blurRadius: _isFocused ? 20 : 10,
                offset: Offset(0, _isFocused ? 6 : 3),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {});
              widget.onChanged?.call(value);
              widget.onSearch?.call(value);
            },
            onSubmitted: (value) {
              widget.onSubmitted?.call(value);
              widget.onSearch?.call(value);
            },
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
              hintText:
                  widget.hintText ?? 'ابحث عن المورد بالاسم، الهاتف أو المنطقة',
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
                      AppColors.primary.withOpacity(0.1),
                      AppColors.info.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              suffixIcon: _controller.text.isNotEmpty
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
                        _controller.clear();
                        setState(() {});
                        widget.onClear?.call();
                        widget.onChanged?.call('');
                        widget.onSearch?.call('');
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
