import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/customer.dart';

/// محدد العميل
/// 
/// يعرض قائمة العملاء للاختيار مع إمكانية البحث
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

class _CustomerSelectorState extends State<CustomerSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = widget.customers;
      } else {
        _filteredCustomers = widget.customers.where((customer) {
          return customer.name.toLowerCase().contains(query.toLowerCase()) ||
              customer.phone.contains(query);
        }).toList();
      }
    });
  }

  void _showCustomerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'اختر العميل',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن عميل...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _filterCustomers,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.allowAnonymous)
              _buildCustomerTile(
                null,
                'بيع مباشر (بدون عميل)',
                'لا يتطلب تسجيل عميل',
                Icons.store,
              ),
            const Divider(height: 1),
            Expanded(
              child: _filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد عملاء',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredCustomers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return _buildCustomerTile(
                          customer.id,
                          customer.name,
                          customer.phone,
                          Icons.person,
                          debt: customer.totalDebt,
                        );
                      },
                    ),
            ),
            if (widget.onAddNewCustomer != null) ...[
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.primary),
                ),
                title: Text(
                  'إضافة عميل جديد',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onAddNewCustomer?.call();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTile(
    String? customerId,
    String name,
    String subtitle,
    IconData icon, {
    double? debt,
  }) {
    final isSelected = widget.selectedCustomerId == customerId;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary 
              : AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.textOnDark : AppColors.primary,
        ),
      ),
      title: Text(
        name,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: debt != null && debt > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'دين: ${debt.toStringAsFixed(0)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : isSelected
              ? const Icon(Icons.check_circle, color: AppColors.primary)
              : null,
      onTap: () {
        widget.onChanged(customerId);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCustomer = widget.customers
        .where((c) => c.id == widget.selectedCustomerId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'العميل',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.enabled ? _showCustomerBottomSheet : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: widget.enabled ? AppColors.surface : AppColors.disabled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorText != null 
                    ? AppColors.danger 
                    : AppColors.border,
                width: widget.errorText != null ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedCustomer != null ? Icons.person : Icons.store,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCustomer?.name ?? 
                    (widget.selectedCustomerId == null && widget.allowAnonymous
                        ? 'بيع مباشر'
                        : 'اختر العميل'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selectedCustomer != null || (widget.selectedCustomerId == null && widget.allowAnonymous)
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}
