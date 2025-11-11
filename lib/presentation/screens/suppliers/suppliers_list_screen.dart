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

/// شاشة قائمة الموردين
/// تعرض جميع الموردين مع إمكانيات البحث والفلترة
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

  /// تحميل قائمة الموردين من BLoC
  void _loadSuppliers() {
    context.read<SuppliersBloc>().add(LoadSuppliers());
  }

  /// عرض شاشة إضافة مورد جديد
  void _showAddSupplierScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSupplierScreen(),
      ),
    ).then((_) => _loadSuppliers());
  }

  /// عرض تفاصيل المورد
  void _showSupplierDetails(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierDetailsScreen(supplier: supplier),
      ),
    ).then((_) => _loadSuppliers());
  }

  /// حذف مورد بعد تأكيد المستخدم
  Future<void> _deleteSupplier(Supplier supplier) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف المورد',
      message: 'هل أنت متأكد من حذف المورد "${supplier.name}"؟\nسيتم حذف جميع البيانات المرتبطة به.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && supplier.id != null) {
      context.read<SuppliersBloc>().add(DeleteSupplierEvent(supplier.id!));
    }
  }

  /// فلترة الموردين حسب البحث ومستوى الثقة والتقييم
  List<Supplier> _filterSuppliers(List<Supplier> suppliers) {
    var filtered = suppliers;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((supplier) {
        final query = _searchQuery.toLowerCase();
        return supplier.name.toLowerCase().contains(query) ||
            (supplier.phone?.toLowerCase().contains(query) ?? false) ||
            (supplier.area?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // تطبيق فلتر مستوى الثقة
    if (_selectedTrustLevel != 'الكل') {
      filtered = filtered.where((supplier) {
        return supplier.trustLevel == _selectedTrustLevel;
      }).toList();
    }

    // تطبيق فلتر التقييم
    if (_selectedQualityRating > 0) {
      filtered = filtered.where((supplier) {
        return supplier.qualityRating == _selectedQualityRating;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('الموردون', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadSuppliers,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط البحث
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: SupplierSearchBar(
                onChanged: (query) {
                  setState(() => _searchQuery = query);
                },
              ),
            ),

            // فلاتر مستوى الثقة والتقييم
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              child: SupplierFilterChips(
                selectedTrustLevel: _selectedTrustLevel,
                selectedQualityRating: _selectedQualityRating,
                onTrustLevelChanged: (trustLevel) {
                  setState(() => _selectedTrustLevel = trustLevel ?? '');
                },
                onQualityRatingChanged: (rating) {
                  setState(() => _selectedQualityRating = rating ?? 0);
                },
              ),
            ),

            const Divider(height: 1),

            // قائمة الموردين
            Expanded(
              child: BlocConsumer<SuppliersBloc, SuppliersState>(
                listener: (context, state) {
                  if (state is SuppliersError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.danger,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else if (state is SupplierOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SuppliersLoading) {
                    return const LoadingWidget(message: 'جاري تحميل الموردين...');
                  }

                  if (state is SuppliersError) {
                    return app_error.ErrorWidget(
                      message: state.message,
                      onRetry: _loadSuppliers,
                    );
                  }

                  if (state is SuppliersLoaded) {
                    final filteredSuppliers = _filterSuppliers(state.suppliers);

                    if (filteredSuppliers.isEmpty) {
                      return EmptyWidget(
                        title: _searchQuery.isEmpty
                            ? 'لا يوجد موردين مسجلين'
                            : 'لا توجد نتائج للبحث',
                        message: _searchQuery.isEmpty
                            ? 'ابدأ بإضافة موردين جدد'
                            : 'جرب البحث بكلمات مختلفة أو قم بتغيير الفلاتر',
                        icon: Icons.store_outlined,
                        actionLabel: _searchQuery.isEmpty ? 'إضافة مورد' : null,
                        onAction: _searchQuery.isEmpty ? _showAddSupplierScreen : null,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadSuppliers(),
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        itemCount: filteredSuppliers.length,
                        separatorBuilder: (context, index) => 
                            const SizedBox(height: AppDimensions.spaceM),
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

                  return const EmptyWidget(
                    title: 'لا يوجد بيانات',
                    message: 'لم يتم تحميل بيانات الموردين',
                    icon: Icons.store_outlined,
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddSupplierScreen,
          icon: const Icon(Icons.add),
          label: const Text('إضافة مورد'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
        ),
      ),
    );
  }
}
