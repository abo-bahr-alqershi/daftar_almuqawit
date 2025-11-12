import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/supplier.dart';

/// محدد المورد - تصميم راقي متطور
class SupplierSelector extends StatefulWidget {
  final String? selectedSupplierId;
  final ValueChanged<String?> onChanged;
  final List<Supplier> suppliers;
  final bool enabled;
  final String? errorText;
  final VoidCallback? onAddNewSupplier;

  const SupplierSelector({
    super.key,
    this.selectedSupplierId,
    required this.onChanged,
    required this.suppliers,
    this.enabled = true,
    this.errorText,
    this.onAddNewSupplier,
  });

  @override
  State<SupplierSelector> createState() => _SupplierSelectorState();
}

class _SupplierSelectorState extends State<SupplierSelector>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  List<Supplier> _filteredSuppliers = [];
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _filteredSuppliers = widget.suppliers;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterSuppliers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuppliers = widget.suppliers;
      } else {
        _filteredSuppliers = widget.suppliers.where((supplier) {
          return supplier.name.toLowerCase().contains(query.toLowerCase()) ||
              (supplier.phone?.contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _showSupplierBottomSheet() {
    HapticFeedback.mediumImpact();
    _searchController.clear();
    _filteredSuppliers = widget.suppliers;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purchases.withOpacity(0.2),
                          AppColors.purchases.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_search_rounded,
                      color: AppColors.purchases,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اختر المورد',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isFocused
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.border.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مورد...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _filterSuppliers('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: _filterSuppliers,
                  onTap: () => setState(() => _isFocused = true),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Expanded(
              child: _filteredSuppliers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_off_rounded,
                              size: 48,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا يوجد موردين',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredSuppliers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final supplier = _filteredSuppliers[index];
                        final isSelected =
                            widget.selectedSupplierId == supplier.id?.toString();
                        return _buildSupplierTile(supplier, isSelected);
                      },
                    ),
            ),
            
            if (widget.onAddNewSupplier != null) ...[
              Container(
                margin: const EdgeInsets.all(20),
                child: _buildAddNewButton(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierTile(Supplier supplier, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onChanged(supplier.id?.toString());
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.purchases.withOpacity(0.1),
                    AppColors.purchases.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.purchases.withOpacity(0.3)
                : AppColors.border.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.purchases, AppColors.info],
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.purchases.withOpacity(0.1),
                          AppColors.info.withOpacity(0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.person_rounded,
                color: isSelected ? Colors.white : AppColors.purchases,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.purchases
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (supplier.phone != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          supplier.phone!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        widget.onAddNewSupplier?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'إضافة مورد جديد',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSupplier = widget.suppliers
        .where((s) => s.id?.toString() == widget.selectedSupplierId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'المورد',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.enabled ? _showSupplierBottomSheet : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.surface
                  : AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.errorText != null
                    ? AppColors.danger
                    : AppColors.border.withOpacity(0.2),
                width: widget.errorText != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedSupplier != null
                        ? AppColors.purchases.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: selectedSupplier != null
                        ? AppColors.purchases
                        : AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedSupplier?.name ?? 'اختر المورد',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: selectedSupplier != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_rounded, size: 14, color: AppColors.danger),
              const SizedBox(width: 4),
              Text(
                widget.errorText!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
