import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/supplier.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/supplier_card.dart';
import 'widgets/supplier_search_bar.dart';
import 'widgets/supplier_filter_chips.dart';
import 'add_supplier_screen.dart';
import 'supplier_details_screen.dart';

class SuppliersListScreen extends StatefulWidget {
  const SuppliersListScreen({super.key});

  @override
  State<SuppliersListScreen> createState() => _SuppliersListScreenState();
}

class _SuppliersListScreenState extends State<SuppliersListScreen> {
  String _searchQuery = '';
  String _selectedTrustLevel = 'الكل';
  int _selectedQualityRating = 0;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  void _loadSuppliers() {
    context.read<SuppliersBloc>().add(LoadSuppliers());
  }

  void _showAddSupplierScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
    ).then((_) => _loadSuppliers());
  }

  void _showSupplierDetails(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierDetailsScreen(supplier: supplier),
      ),
    ).then((_) => _loadSuppliers());
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف المورد',
      message: 'هل أنت متأكد من حذف المورد "${supplier.name}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && supplier.id != null) {
      context.read<SuppliersBloc>().add(DeleteSupplierEvent(supplier.id!));
    }
  }

  List<Supplier> _filterSuppliers(List<Supplier> suppliers) {
    var filtered = suppliers;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((supplier) {
        final query = _searchQuery.toLowerCase();
        return supplier.name.toLowerCase().contains(query) ||
            (supplier.phone?.toLowerCase().contains(query) ?? false) ||
            (supplier.area?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_selectedTrustLevel != 'الكل') {
      filtered = filtered
          .where((s) => s.trustLevel == _selectedTrustLevel)
          .toList();
    }

    if (_selectedQualityRating > 0) {
      filtered = filtered
          .where((s) => s.qualityRating == _selectedQualityRating)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchSection(),
            _buildFilterSection(),
            Expanded(child: _buildSuppliersList()),
          ],
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'الموردون',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_outlined, size: 22),
          color: const Color(0xFF6B7280),
          onPressed: _loadSuppliers,
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (query) => setState(() => _searchQuery = query),
          decoration: const InputDecoration(
            hintText: 'البحث عن مورد...',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل', _selectedTrustLevel == 'الكل', () {
              setState(() => _selectedTrustLevel = 'الكل');
            }),
            const SizedBox(width: 8),
            _buildFilterChip('ممتاز', _selectedTrustLevel == 'ممتاز', () {
              setState(() => _selectedTrustLevel = 'ممتاز');
            }),
            const SizedBox(width: 8),
            _buildFilterChip('جيد', _selectedTrustLevel == 'جيد', () {
              setState(() => _selectedTrustLevel = 'جيد');
            }),
            const SizedBox(width: 8),
            _buildFilterChip('متوسط', _selectedTrustLevel == 'متوسط', () {
              setState(() => _selectedTrustLevel = 'متوسط');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildSuppliersList() {
    return BlocConsumer<SuppliersBloc, SuppliersState>(
      listener: (context, state) {
        if (state is SuppliersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is SupplierOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SuppliersLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1),
              strokeWidth: 2,
            ),
          );
        }

        if (state is SuppliersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: const Color(0xFFDC2626).withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loadSuppliers,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state is SuppliersLoaded) {
          final filteredSuppliers = _filterSuppliers(state.suppliers);

          if (filteredSuppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 56,
                    color: const Color(0xFF9CA3AF).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? 'لا يوجد موردين' : 'لا توجد نتائج',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'ابدأ بإضافة موردين جدد'
                        : 'جرب البحث بكلمات أخرى',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadSuppliers(),
            color: const Color(0xFF6366F1),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredSuppliers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final supplier = filteredSuppliers[index];
                return SupplierCard(
                  supplier: supplier,
                  onTap: () => _showSupplierDetails(supplier),
                  onDelete: () => _deleteSupplier(supplier),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddSupplierScreen,
      backgroundColor: const Color(0xFF6366F1),
      elevation: 2,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
