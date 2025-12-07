import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/supplier.dart';

/// محدد المورد - تصميم راقي ونظيف
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

class _SupplierSelectorState extends State<SupplierSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Supplier> _filteredSuppliers = [];

  @override
  void initState() {
    super.initState();
    _filteredSuppliers = widget.suppliers;
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
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

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_search,
                        color: Color(0xFF8B5CF6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'اختر المورد',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
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
                          Icons.close,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن مورد...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (query) {
                      setModalState(() => _filterSuppliers(query));
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _filteredSuppliers.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredSuppliers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final supplier = _filteredSuppliers[index];
                          final isSelected =
                              widget.selectedSupplierId ==
                              supplier.id?.toString();
                          return _buildSupplierTile(supplier, isSelected);
                        },
                      ),
              ),

              if (widget.onAddNewSupplier != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    12 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: _buildAddNewButton(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_off_outlined,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا يوجد موردين',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                color: isSelected ? Colors.white : const Color(0xFF8B5CF6),
                size: 22,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  if (supplier.phone != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          supplier.phone!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
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
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Color(0xFF16A34A),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'إضافة مورد جديد',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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

    return GestureDetector(
      onTap: widget.enabled ? _showSupplierBottomSheet : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.errorText != null
                ? const Color(0xFFDC2626)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selectedSupplier != null
                    ? const Color(0xFF8B5CF6).withOpacity(0.1)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: selectedSupplier != null
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedSupplier?.name ?? 'اختر المورد',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selectedSupplier != null
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
