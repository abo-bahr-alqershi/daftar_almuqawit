import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// شريط البحث عن الموردين
class SupplierSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final String? hintText;

  const SupplierSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textAlign: TextAlign.right,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText ?? 'ابحث عن المورد بالاسم، الهاتف أو المنطقة',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: controller?.text.isNotEmpty ?? false
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: onClear ?? () {
                    controller?.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
