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
import 'widgets/supplier_stats_card.dart';
import 'widgets/supplier_card.dart';
import 'suppliers_list_screen.dart';
import 'add_supplier_screen.dart';
import 'supplier_details_screen.dart';

/// شاشة الموردين الرئيسية
/// تعرض إحصائيات الموردين وقائمة سريعة بأحدث الموردين
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  /// تحميل قائمة الموردين
  void _loadSuppliers() {
    context.read<SuppliersBloc>().add(LoadSuppliers());
  }

  /// الانتقال إلى شاشة القائمة الكاملة
  void _navigateToFullList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SuppliersListScreen(),
      ),
    );
  }

  /// الانتقال إلى شاشة إضافة مورد
  void _navigateToAddSupplier() {
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

  /// حساب إحصائيات الموردين
  Map<String, dynamic> _calculateStats(List<Supplier> suppliers) {
    int totalSuppliers = suppliers.length;
    int trustedSuppliers = suppliers.where((s) => 
      s.trustLevel == 'ممتاز' || s.trustLevel == 'جيد'
    ).length;
    
    double totalPurchases = suppliers.fold(0.0, (sum, s) => sum + s.totalPurchases);
    double totalDebt = suppliers.fold(0.0, (sum, s) => sum + s.totalDebtToHim);
    
    double averageRating = suppliers.isEmpty 
        ? 0.0 
        : suppliers.fold(0.0, (sum, s) => sum + s.qualityRating) / suppliers.length;

    return {
      'totalSuppliers': totalSuppliers,
      'trustedSuppliers': trustedSuppliers,
      'totalPurchases': totalPurchases,
      'totalDebt': totalDebt,
      'averageRating': averageRating,
    };
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
              icon: const Icon(Icons.list),
              onPressed: _navigateToFullList,
              tooltip: 'عرض القائمة الكاملة',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadSuppliers,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: BlocBuilder<SuppliersBloc, SuppliersState>(
          builder: (context, state) {
            if (state is SuppliersLoading) {
              return const LoadingWidget(message: 'جاري تحميل البيانات...');
            }

            if (state is SuppliersError) {
              return app_error.ErrorWidget(
                message: state.message,
                onRetry: _loadSuppliers,
              );
            }

            if (state is SuppliersLoaded) {
              if (state.suppliers.isEmpty) {
                return EmptyWidget(
                  title: 'لا يوجد موردين',
                  message: 'ابدأ بإضافة موردين جدد لإدارة المشتريات',
                  icon: Icons.store_outlined,
                  actionLabel: 'إضافة مورد',
                  onAction: _navigateToAddSupplier,
                );
              }

              final stats = _calculateStats(state.suppliers);
              final recentSuppliers = state.suppliers.take(5).toList();

              return RefreshIndicator(
                onRefresh: () async => _loadSuppliers(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // بطاقة الإحصائيات
                      SupplierStatsCard(
                        totalSuppliers: stats['totalSuppliers'],
                        totalPurchases: stats['totalPurchases'],
                        totalDebt: stats['totalDebt'],
                        trustedSuppliers: stats['trustedSuppliers'],
                        averageRating: stats['averageRating'],
                      ),

                      // عنوان القائمة
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingL,
                          AppDimensions.paddingM,
                          AppDimensions.paddingL,
                          AppDimensions.paddingS,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'أحدث الموردين',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _navigateToFullList,
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('عرض الكل'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // قائمة أحدث الموردين
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingL,
                          vertical: AppDimensions.paddingS,
                        ),
                        itemCount: recentSuppliers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppDimensions.spaceM),
                        itemBuilder: (context, index) {
                          final supplier = recentSuppliers[index];
                          return SupplierCard(
                            supplier: supplier,
                            onTap: () => _showSupplierDetails(supplier),
                            onDelete: null,
                          );
                        },
                      ),

                      const SizedBox(height: AppDimensions.spaceXL),
                    ],
                  ),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToAddSupplier,
          icon: const Icon(Icons.add),
          label: const Text('إضافة مورد'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
        ),
      ),
    );
  }
}
