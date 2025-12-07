import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/customer.dart';

/// محدد العميل - تصميم راقي واحترافي
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildSheetHeader(),
              _buildSearchField(setModalState),
              Expanded(child: _buildCustomersList(setModalState)),
              if (widget.onAddNewCustomer != null) _buildAddNewButton(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: Color(0xFF6366F1),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'اختر العميل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: 'ابحث عن عميل...',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF6B7280),
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _filterCustomers('');
                      setModalState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            _filterCustomers(value);
            setModalState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildCustomersList(StateSetter setModalState) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.allowAnonymous) ...[
          _buildCustomerItem(
            null,
            'بيع مباشر',
            'بدون تسجيل عميل',
            Icons.store_rounded,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
        ],
        ..._filteredCustomers.map((customer) {
          final isSelected =
              widget.selectedCustomerId == customer.id?.toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildCustomerItem(
              customer,
              customer.name,
              customer.phone ?? 'بدون رقم',
              Icons.person_rounded,
              const Color(0xFF6366F1),
              isSelected: isSelected,
              debt: customer.totalDebt,
            ),
          );
        }),
        if (_filteredCustomers.isEmpty && !widget.allowAnonymous)
          _buildEmptySearchState(),
      ],
    );
  }

  Widget _buildCustomerItem(
    Customer? customer,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    bool isSelected = false,
    double? debt,
  }) {
    final isAnonymous = customer == null;
    final actuallySelected = isAnonymous
        ? widget.selectedCustomerId == null
        : widget.selectedCustomerId == customer.id?.toString();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onChanged(customer?.id?.toString());
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: actuallySelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: actuallySelected
                ? color.withOpacity(0.3)
                : const Color(0xFFE5E7EB),
            width: actuallySelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: actuallySelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: actuallySelected ? Colors.white : color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: actuallySelected ? color : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isAnonymous
                            ? Icons.info_outline_rounded
                            : Icons.phone_rounded,
                        size: 12,
                        color: const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  if (debt != null && debt > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'دين: ${debt.toStringAsFixed(0)} ر.ي',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actuallySelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_off_rounded,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا يوجد عملاء',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            widget.onAddNewCustomer?.call();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'إضافة عميل جديد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
            const Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            const Text(
              'العميل',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.enabled ? _showCustomerBottomSheet : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.errorText != null
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFE5E7EB),
                width: widget.errorText != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        selectedCustomer != null ||
                            (widget.selectedCustomerId == null &&
                                widget.allowAnonymous)
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selectedCustomer != null
                        ? Icons.person_rounded
                        : Icons.store_rounded,
                    size: 20,
                    color:
                        selectedCustomer != null ||
                            (widget.selectedCustomerId == null &&
                                widget.allowAnonymous)
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCustomer?.name ??
                        (widget.selectedCustomerId == null &&
                                widget.allowAnonymous
                            ? 'بيع مباشر'
                            : 'اختر العميل'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          selectedCustomer != null ||
                              (widget.selectedCustomerId == null &&
                                  widget.allowAnonymous)
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 6),
              Text(
                widget.errorText!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
