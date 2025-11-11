import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/supplier.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_widget.dart';
import 'edit_supplier_screen.dart';

/// شاشة تفاصيل المورد
class SupplierDetailsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailsScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  bool _isDeleting = false;

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المورد "${widget.supplier.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleDelete();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete() {
    if (widget.supplier.id != null) {
      context.read<SuppliersBloc>().add(DeleteSupplierEvent(widget.supplier.id!));
    }
  }

  void _navigateToEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSupplierScreen(supplier: widget.supplier),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تفاصيل المورد'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEdit,
              tooltip: 'تعديل',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
              tooltip: 'حذف',
            ),
          ],
        ),
        body: BlocListener<SuppliersBloc, SuppliersState>(
          listener: (context, state) {
            if (state is SupplierOperationSuccess) {
              setState(() => _isDeleting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.of(context).pop();
            } else if (state is SuppliersError) {
              setState(() => _isDeleting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            } else if (state is SuppliersLoading) {
              setState(() => _isDeleting = true);
            }
          },
          child: _isDeleting
              ? const Center(child: LoadingWidget())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // رأس البطاقة
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          children: [
                            // أيقونة المورد
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.textOnDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // اسم المورد
                            Text(
                              widget.supplier.name,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // تقييم النجوم
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < widget.supplier.qualityRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppColors.warning,
                                  size: 24,
                                );
                              }),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // مستوى الثقة
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textOnDark.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.supplier.trustLevel,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textOnDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // معلومات الاتصال
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات الاتصال',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // رقم الهاتف
                            _DetailCard(
                              icon: Icons.phone,
                              title: 'رقم الهاتف',
                              value: widget.supplier.phone ?? 'غير محدد',
                              color: AppColors.info,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // المنطقة
                            _DetailCard(
                              icon: Icons.location_on,
                              title: 'المنطقة',
                              value: widget.supplier.area ?? 'غير محدد',
                              color: AppColors.success,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // الإحصائيات المالية
                            Text(
                              'الإحصائيات المالية',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: 'إجمالي المشتريات',
                                    value: widget.supplier.totalPurchases,
                                    color: AppColors.purchases,
                                    icon: Icons.shopping_cart,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    title: 'إجمالي الديون له',
                                    value: widget.supplier.totalDebtToHim,
                                    color: AppColors.debt,
                                    icon: Icons.attach_money,
                                  ),
                                ),
                              ],
                            ),
                            
                            // ملاحظات
                            if (widget.supplier.notes != null &&
                                widget.supplier.notes!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              
                              Text(
                                'ملاحظات',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  widget.supplier.notes!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // أزرار الإجراءات
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton.primary(
                                    text: 'تعديل',
                                    onPressed: _navigateToEdit,
                                    icon: Icons.edit,
                                    fullWidth: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppButton.danger(
                                    text: 'حذف',
                                    onPressed: _showDeleteConfirmation,
                                    icon: Icons.delete,
                                    fullWidth: true,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// بطاقة معلومات
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة إحصائية
class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(2)} ريال',
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
