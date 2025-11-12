import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/supplier.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../widgets/common/app_text_field.dart';

/// شاشة تعديل مورد - تصميم متطور
class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animationController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _areaController;
  late TextEditingController _notesController;
  
  late int _qualityRating;
  late String _trustLevel;
  bool _isLoading = false;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    
    _nameController = TextEditingController(text: widget.supplier.name);
    _phoneController = TextEditingController(text: widget.supplier.phone ?? '');
    _areaController = TextEditingController(text: widget.supplier.area ?? '');
    _notesController = TextEditingController(text: widget.supplier.notes ?? '');
    _qualityRating = widget.supplier.qualityRating;
    _trustLevel = widget.supplier.trustLevel;
    
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال اسم المورد';
    }
    if (value.trim().length < 2) {
      return 'اسم المورد يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 9) {
        return 'رقم الهاتف غير صحيح';
      }
    }
    return null;
  }

  void _handleSubmit() {
    HapticFeedback.mediumImpact();
    
    if (_formKey.currentState?.validate() ?? false) {
      final updatedSupplier = widget.supplier.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        qualityRating: _qualityRating,
        trustLevel: _trustLevel,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      context.read<SuppliersBloc>().add(UpdateSupplierEvent(updatedSupplier));
    }
  }

  void _handleDelete() {
    HapticFeedback.mediumImpact();
    _showDeleteConfirmation();
  }

  void _showDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DeleteConfirmationSheet(
        supplierName: widget.supplier.name,
        onConfirm: () {
          HapticFeedback.heavyImpact();
          context.read<SuppliersBloc>().add(DeleteSupplierEvent(widget.supplier.id!));
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocListener<SuppliersBloc, SuppliersState>(
          listener: (context, state) {
            if (state is SupplierOperationSuccess) {
              setState(() => _isLoading = false);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              Navigator.of(context).pop();
            } else if (state is SuppliersError) {
              setState(() => _isLoading = false);
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is SuppliersLoading) {
              setState(() => _isLoading = true);
            }
          },
          child: Stack(
            children: [
              // خلفية متدرجة
              _buildGradientBackground(),

              // المحتوى الرئيسي
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // AppBar مخصص
                  _buildModernAppBar(topPadding),

                  // المحتوى
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // بطاقات الإحصائيات
                        _buildStatsCards(),

                        const SizedBox(height: 24),

                        // النموذج
                        _buildForm(),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),

              // زر الحذف العائم
              if (!_isLoading) _buildFloatingDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
    height: 400,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withOpacity(0.08),
          AppColors.accent.withOpacity(0.05),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildModernAppBar(double topPadding) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 2,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // أيقونة المورد
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.info, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.business,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تعديل المورد',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.supplier.name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        // زر الحفظ
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.success, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            onPressed: _isLoading ? null : _handleSubmit,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'التقييم',
            '$_qualityRating/5',
            Icons.star,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'الثقة',
            _trustLevel,
            Icons.verified,
            _getTrustColor(_trustLevel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'الحالة',
            'نشط',
            Icons.check_circle,
            AppColors.success,
          ),
        ),
      ],
    ),
  );

  Widget _buildStatCard(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Color _getTrustColor(String trustLevel) {
    switch (trustLevel) {
      case 'ممتاز':
        return AppColors.success;
      case 'جيد':
        return AppColors.info;
      case 'متوسط':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildForm() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'معلومات المورد',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // اسم المورد
          AppTextField(
            controller: _nameController,
            label: 'اسم المورد',
            hint: 'أدخل اسم المورد',
            prefixIcon: Icons.person,
            validator: _validateName,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 20),

          // رقم الهاتف
          AppTextField.phone(
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: 'أدخل رقم الهاتف (اختياري)',
            validator: _validatePhone,
          ),

          const SizedBox(height: 20),

          // المنطقة
          AppTextField(
            controller: _areaController,
            label: 'المنطقة',
            hint: 'أدخل المنطقة (اختياري)',
            prefixIcon: Icons.location_on,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 24),

          // تقييم الجودة
          _buildRatingSection(),

          const SizedBox(height: 24),

          // مستوى الثقة
          _buildTrustLevelSection(),

          const SizedBox(height: 20),

          // ملاحظات
          AppTextField.multiline(
            controller: _notesController,
            label: 'ملاحظات',
            hint: 'أدخل ملاحظات إضافية (اختياري)',
            maxLines: 4,
          ),
        ],
      ),
    ),
  );

  Widget _buildRatingSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'تقييم الجودة',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _qualityRating = index + 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  index < _qualityRating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: index < _qualityRating 
                      ? AppColors.warning 
                      : AppColors.textHint,
                  size: 36,
                ),
              ),
            );
          }),
        ),
      ),
    ],
  );

  Widget _buildTrustLevelSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'مستوى الثقة',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _trustLevel,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            items: const [
              DropdownMenuItem(value: 'جديد', child: Text('جديد')),
              DropdownMenuItem(value: 'جيد', child: Text('جيد')),
              DropdownMenuItem(value: 'ممتاز', child: Text('ممتاز')),
              DropdownMenuItem(value: 'متوسط', child: Text('متوسط')),
            ],
            onChanged: (value) {
              if (value != null) {
                HapticFeedback.selectionClick();
                setState(() {
                  _trustLevel = value;
                });
              }
            },
          ),
        ),
      ),
    ],
  );

  Widget _buildFloatingDeleteButton() => Positioned(
    bottom: 20,
    left: 20,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: _handleDelete,
        backgroundColor: AppColors.danger,
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        label: const Text(
          'حذف المورد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 8,
        heroTag: 'delete_supplier',
      ),
    ),
  );
}

// Bottom Sheet للتأكيد على الحذف
class _DeleteConfirmationSheet extends StatelessWidget {
  final String supplierName;
  final VoidCallback onConfirm;

  const _DeleteConfirmationSheet({
    required this.supplierName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),
        
        // أيقونة التحذير
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_forever,
            color: AppColors.danger,
            size: 48,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'تأكيد الحذف',
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'هل أنت متأكد من حذف المورد؟',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            supplierName,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // أزرار الإجراءات
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'إلغاء',
                AppColors.textSecondary,
                () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'حذف',
                AppColors.danger,
                onConfirm,
                isPrimary: true,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
      ],
    ),
  );

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed, {
    required bool isPrimary,
  }) => Material(
    color: isPrimary ? color : Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: isPrimary ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
