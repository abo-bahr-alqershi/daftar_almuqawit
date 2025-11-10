import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/supplier.dart';

/// محدد المورد
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
                    child: Text('اختر المورد', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن مورد...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: _filterSuppliers,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredSuppliers.isEmpty
                  ? const Center(child: Text('لا يوجد موردين'))
                  : ListView.separated(
                      itemCount: _filteredSuppliers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final supplier = _filteredSuppliers[index];
                        final isSelected = widget.selectedSupplierId == supplier.id;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                            child: Icon(Icons.person, color: isSelected ? Colors.white : AppColors.primary),
                          ),
                          title: Text(supplier.name),
                          subtitle: Text(supplier.phone ?? ''),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                          onTap: () {
                            widget.onChanged(supplier.id?.toString());
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
            if (widget.onAddNewSupplier != null) ...[
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.add, color: Colors.white)),
                title: Text('إضافة مورد جديد', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onAddNewSupplier?.call();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSupplier = widget.suppliers.where((s) => s.id == widget.selectedSupplierId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المورد', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.enabled ? _showSupplierBottomSheet : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.enabled ? AppColors.surface : AppColors.disabled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.errorText != null ? AppColors.danger : AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(selectedSupplier?.name ?? 'اختر المورد')),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(widget.errorText!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger)),
        ],
      ],
    );
  }
}
