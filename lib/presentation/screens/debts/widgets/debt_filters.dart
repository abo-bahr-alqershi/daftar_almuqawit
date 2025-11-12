import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ويدجت فلترة الديون - تصميم راقي هادئ
class DebtFilters extends StatelessWidget {
  final String selectedStatus;
  final String selectedSortBy;
  final Function(String) onStatusChanged;
  final Function(String) onSortChanged;

  const DebtFilters({
    super.key,
    required this.selectedStatus,
    required this.selectedSortBy,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(context),
            _buildContent(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.danger.withOpacity(0.1),
                  AppColors.warning.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'فلترة وترتيب الديون',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusFilter(),
          const SizedBox(height: 24),
          _buildSortOptions(),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.danger, AppColors.warning],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'حالة الدين',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              label: 'الكل',
              icon: Icons.list_alt_rounded,
              isSelected: selectedStatus == 'الكل',
              onTap: () => onStatusChanged('الكل'),
            ),
            _StatusChip(
              label: 'معلقة',
              icon: Icons.pending_rounded,
              isSelected: selectedStatus == 'معلقة',
              onTap: () => onStatusChanged('معلقة'),
              color: AppColors.warning,
            ),
            _StatusChip(
              label: 'متأخرة',
              icon: Icons.warning_rounded,
              isSelected: selectedStatus == 'متأخرة',
              onTap: () => onStatusChanged('متأخرة'),
              color: AppColors.danger,
            ),
            _StatusChip(
              label: 'مدفوعة',
              icon: Icons.check_circle_rounded,
              isSelected: selectedStatus == 'مدفوعة',
              onTap: () => onStatusChanged('مدفوعة'),
              color: AppColors.success,
            ),
            _StatusChip(
              label: 'جزئية',
              icon: Icons.pie_chart_rounded,
              isSelected: selectedStatus == 'جزئية',
              onTap: () => onStatusChanged('جزئية'),
              color: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.info, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'الترتيب حسب',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SortOption(
          label: 'التاريخ',
          icon: Icons.calendar_today_rounded,
          isSelected: selectedSortBy == 'التاريخ',
          onTap: () => onSortChanged('التاريخ'),
        ),
        const SizedBox(height: 8),
        _SortOption(
          label: 'المبلغ',
          icon: Icons.attach_money_rounded,
          isSelected: selectedSortBy == 'المبلغ',
          onTap: () => onSortChanged('المبلغ'),
        ),
        const SizedBox(height: 8),
        _SortOption(
          label: 'العميل',
          icon: Icons.person_rounded,
          isSelected: selectedSortBy == 'العميل',
          onTap: () => onSortChanged('العميل'),
        ),
        const SizedBox(height: 8),
        _SortOption(
          label: 'تاريخ الاستحقاق',
          icon: Icons.event_available_rounded,
          isSelected: selectedSortBy == 'الاستحقاق',
          onTap: () => onSortChanged('الاستحقاق'),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [chipColor, chipColor.withOpacity(0.8)],
                )
              : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
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
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.info.withOpacity(0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.info.withOpacity(0.3)
                : AppColors.border.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [AppColors.info, AppColors.primary]
                      : [
                          AppColors.textSecondary.withOpacity(0.1),
                          AppColors.textSecondary.withOpacity(0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.info : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.info,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
