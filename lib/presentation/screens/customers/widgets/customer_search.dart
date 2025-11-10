import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// شريط بحث العملاء مع فلاتر
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

class _CustomerSearchState extends State<CustomerSearch> {
  late final TextEditingController _searchController;
  String? _selectedCustomerType;
  String? _selectedStatus;
  bool _showFilters = false;

  final List<String> _customerTypes = ['الكل', 'عادي', 'VIP', 'جديد'];
  final List<String> _statuses = ['الكل', 'نشط', 'محظور', 'عليه دين', 'تجاوز الحد'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedCustomerType = widget.initialCustomerType;
    _selectedStatus = widget.initialStatus;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    widget.onSearch?.call(query);
  }

  void _handleCustomerTypeChanged(String? type) {
    setState(() {
      _selectedCustomerType = (type == 'الكل') ? null : type;
    });
    widget.onCustomerTypeChanged?.call(_selectedCustomerType);
  }

  void _handleStatusChanged(String? status) {
    setState(() {
      _selectedStatus = (status == 'الكل') ? null : status;
    });
    widget.onStatusChanged?.call(_selectedStatus);
  }

  void _handleClearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCustomerType = null;
      _selectedStatus = null;
    });
    widget.onSearch?.call('');
    widget.onCustomerTypeChanged?.call(null);
    widget.onStatusChanged?.call(null);
    widget.onClearFilters?.call();
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      _selectedCustomerType != null ||
      _selectedStatus != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط البحث
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن عميل...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _handleSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingM,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceS),
              // زر الفلاتر
              Material(
                color: _hasActiveFilters ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                child: InkWell(
                  onTap: () {
                    setState(() => _showFilters = !_showFilters);
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _hasActiveFilters ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      color: _hasActiveFilters ? AppColors.textOnDark : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // قسم الفلاتر
          if (_showFilters) ...[
            const SizedBox(height: AppDimensions.spaceM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الفلاتر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الفلاتر',
                        style: AppTextStyles.titleSmall,
                      ),
                      if (_hasActiveFilters)
                        TextButton.icon(
                          onPressed: _handleClearFilters,
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('مسح الكل'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceM),
                  
                  // فلتر نوع العميل
                  Text(
                    'نوع العميل',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceS),
                  Wrap(
                    spacing: AppDimensions.spaceS,
                    runSpacing: AppDimensions.spaceS,
                    children: _customerTypes.map((type) {
                      final isSelected = type == 'الكل'
                          ? _selectedCustomerType == null
                          : _selectedCustomerType == type;
                      return _FilterChip(
                        label: type,
                        isSelected: isSelected,
                        onTap: () => _handleCustomerTypeChanged(type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.spaceM),
                  
                  // فلتر الحالة
                  Text(
                    'الحالة',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceS),
                  Wrap(
                    spacing: AppDimensions.spaceS,
                    runSpacing: AppDimensions.spaceS,
                    children: _statuses.map((status) {
                      final isSelected = status == 'الكل'
                          ? _selectedStatus == null
                          : _selectedStatus == status;
                      return _FilterChip(
                        label: status,
                        isSelected: isSelected,
                        onTap: () => _handleStatusChanged(status),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// رقاقة فلتر قابلة للنقر
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
