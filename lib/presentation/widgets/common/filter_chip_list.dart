import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// قائمة رقائق التصفية (Filter Chips)
/// 
/// تستخدم لتصفية البيانات بطريقة مرئية وسهلة
class FilterChipList<T> extends StatelessWidget {
  /// القيم المختارة حالياً
  final List<T> selectedValues;
  
  /// دالة يتم استدعاؤها عند تغيير الاختيار
  final ValueChanged<List<T>>? onChanged;
  
  /// الخيارات المتاحة
  final Map<T, String> options;
  
  /// الأيقونات الاختيارية
  final Map<T, IconData>? icons;
  
  /// هل يسمح باختيار متعدد
  final bool multiSelect;
  
  /// اتجاه العرض
  final Axis direction;
  
  /// المسافة بين الرقائق
  final double spacing;
  
  /// المسافة بين الأسطر
  final double runSpacing;

  const FilterChipList({
    super.key,
    required this.selectedValues,
    this.onChanged,
    required this.options,
    this.icons,
    this.multiSelect = true,
    this.direction = Axis.horizontal,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  void _handleChipTap(T value) {
    if (onChanged == null) return;

    final newValues = List<T>.from(selectedValues);
    
    if (multiSelect) {
      if (newValues.contains(value)) {
        newValues.remove(value);
      } else {
        newValues.add(value);
      }
    } else {
      newValues.clear();
      newValues.add(value);
    }
    
    onChanged!(newValues);
  }

  @override
  Widget build(BuildContext context) {
    final chips = options.entries.map((entry) {
      final isSelected = selectedValues.contains(entry.key);
      final icon = icons?[entry.key];

      return FilterChip(
        label: Text(entry.value),
        selected: isSelected,
        onSelected: onChanged != null ? (_) => _handleChipTap(entry.key) : null,
        avatar: icon != null
            ? Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              )
            : null,
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.1),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }).toList();

    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chips.map((chip) => Padding(
          padding: EdgeInsets.only(bottom: runSpacing),
          child: chip,
        )).toList(),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: chips,
    );
  }
}

/// رقاقة تصفية مفردة مخصصة
/// 
/// تستخدم عندما تحتاج لتحكم أكبر في التصميم
class AppFilterChip extends StatelessWidget {
  /// النص
  final String label;
  
  /// هل محددة
  final bool selected;
  
  /// دالة عند الضغط
  final ValueChanged<bool>? onSelected;
  
  /// الأيقونة
  final IconData? icon;
  
  /// اللون عند التحديد
  final Color? selectedColor;
  
  /// لون الخلفية
  final Color? backgroundColor;

  const AppFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
    this.selectedColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.primary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon != null
          ? Icon(
              icon,
              size: 18,
              color: selected ? effectiveSelectedColor : AppColors.textSecondary,
            )
          : null,
      backgroundColor: backgroundColor ?? AppColors.surface,
      selectedColor: effectiveSelectedColor.withOpacity(0.1),
      checkmarkColor: effectiveSelectedColor,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: selected ? effectiveSelectedColor : AppColors.textPrimary,
      ),
      side: BorderSide(
        color: selected ? effectiveSelectedColor : AppColors.border,
        width: selected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// مجموعة رقائق اختيار (Choice Chips)
/// 
/// تسمح باختيار خيار واحد فقط من القائمة
class ChoiceChipList<T> extends StatelessWidget {
  /// القيمة المختارة
  final T? selectedValue;
  
  /// دالة عند الاختيار
  final ValueChanged<T?>? onSelected;
  
  /// الخيارات المتاحة
  final Map<T, String> options;
  
  /// الأيقونات الاختيارية
  final Map<T, IconData>? icons;
  
  /// اتجاه العرض
  final Axis direction;
  
  /// المسافة بين الرقائق
  final double spacing;
  
  /// المسافة بين الأسطر
  final double runSpacing;

  const ChoiceChipList({
    super.key,
    this.selectedValue,
    this.onSelected,
    required this.options,
    this.icons,
    this.direction = Axis.horizontal,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final chips = options.entries.map((entry) {
      final isSelected = selectedValue == entry.key;
      final icon = icons?[entry.key];

      return ChoiceChip(
        label: Text(entry.value),
        selected: isSelected,
        onSelected: onSelected != null ? (_) => onSelected!(entry.key) : null,
        avatar: icon != null
            ? Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
              )
            : null,
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }).toList();

    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chips.map((chip) => Padding(
          padding: EdgeInsets.only(bottom: runSpacing),
          child: chip,
        )).toList(),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: chips,
    );
  }
}
