import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/customer.dart';

/// محدد العميل - تصميم راقي هادئ
class CustomerSelector extends StatefulWidget {
  final String? selectedCustomerId;
  final ValueChanged<String?> onChanged;
  final List<Customer> customers;
  final bool enabled;
  final String? errorText;
  final bool allowAnonymous;
  final VoidCallback? onAddNewCustomer;

  const CustomerSelector({
    super.key,
    this.selectedCustomerId,
    required this.onChanged,
    required this.customers,
    this.enabled = true,
    this.errorText,
    this.allowAnonymous = true,
    this.onAddNewCustomer,
  });

  @override
  State<CustomerSelector> createState() => _CustomerSelectorState();
}

class _CustomerSelectorState extends State<CustomerSelector>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  List<Customer> _filteredCustomers = [];
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
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

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = widget.customers;
      } else {
        _filteredCustomers = widget.customers.where((customer) {
          return customer.name.toLowerCase().contains(query.toLowerCase()) ||
              (customer.phone?.contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _showCustomerBottomSheet() {
    HapticFeedback.mediumImpact();
    _searchController.clear();
    _filteredCustomers = widget.customers;

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
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_search_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اختر العميل',
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
                    hintText: 'ابحث عن عميل...',
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
                              _filterCustomers('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: _filterCustomers,
                  onTap: () => setState(() => _isFocused = true),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Expanded(
              child: _buildCustomersList(),
            ),
            
            if (widget.onAddNewCustomer != null) ...[
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

  Widget _buildCustomersList() {
    if (widget.allowAnonymous || _filteredCustomers.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          if (widget.allowAnonymous) _buildAnonymousOption(),
          if (widget.allowAnonymous && _filteredCustomers.isNotEmpty)
            const SizedBox(height: 8),
          ..._filteredCustomers.map((customer) {
            final isSelected = widget.selectedCustomerId == customer.id?.toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCustomerTile(customer, isSelected),
            );
          }),
        ],
      );
    }

    return Center(
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
            'لا يوجد عملاء',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousOption() {
    final isSelected = widget.selectedCustomerId == null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onChanged(null);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.1),
                    AppColors.success.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.success.withOpacity(0.3)
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
                        colors: [AppColors.success, AppColors.info],
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.success.withOpacity(0.1),
                          AppColors.info.withOpacity(0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.store_rounded,
                color: isSelected ? Colors.white : AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بيع مباشر',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'بدون تسجيل عميل',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
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

  Widget _buildCustomerTile(Customer customer, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onChanged(customer.id?.toString());
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
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
                        colors: [AppColors.primary, AppColors.accent],
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.accent.withOpacity(0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  customer.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (customer.phone != null) ...[
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
                          customer.phone!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (customer.totalDebt != null && customer.totalDebt! > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'دين: ${customer.totalDebt!.toStringAsFixed(0)} ريال',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
        widget.onAddNewCustomer?.call();
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
              'إضافة عميل جديد',
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
    final selectedCustomer = widget.customers
        .where((c) => c.id?.toString() == widget.selectedCustomerId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'العميل',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.enabled ? _showCustomerBottomSheet : null,
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
                    color: selectedCustomer != null || 
                           (widget.selectedCustomerId == null && widget.allowAnonymous)
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selectedCustomer != null ? Icons.person_rounded : Icons.store_rounded,
                    size: 20,
                    color: selectedCustomer != null ||
                           (widget.selectedCustomerId == null && widget.allowAnonymous)
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCustomer?.name ??
                        (widget.selectedCustomerId == null && widget.allowAnonymous
                            ? 'بيع مباشر'
                            : 'اختر العميل'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: selectedCustomer != null ||
                             (widget.selectedCustomerId == null && widget.allowAnonymous)
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
