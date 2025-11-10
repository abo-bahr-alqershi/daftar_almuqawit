import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// شريط بحث مخصص
class SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const SearchBar({
    super.key,
    this.controller,
    this.hint = 'البحث...',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: controller?.text.isNotEmpty ?? false
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
                color: AppColors.textSecondary,
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
