import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customer_form_bloc.dart';
import '../../blocs/customers/customer_form_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// شاشة إضافة عميل جديد - تصميم متطور
class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    context.read<CustomerFormBloc>().add(ResetCustomerForm());
    
    // Animation Controller للأنيميشن الرئيسي
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Animation Controller للتلاشي
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Fade Animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Slide Animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Scale Animation
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // بدء الأنيميشن
    _animationController.forward();
    _fadeController.forward();
    
    // مستمع للتمرير
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    HapticFeedback.mediumImpact();
    
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
        customerType: 'عادي',
        creditLimit: 0,
        totalPurchases: 0,
        currentDebt: 0,
        isBlocked: false,
      );

      context.read<CustomersBloc>().add(AddCustomerEvent(customer));
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // خلفية متدرجة ديناميكية
            _buildGradientBackground(),
            
            // المحتوى الرئيسي
            BlocListener<CustomersBloc, CustomersState>(
              listener: (context, state) {
                if (state is CustomerOperationSuccess) {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                } else if (state is CustomersError) {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // AppBar مخصص مع تأثيرات
                  _buildModernAppBar(topPadding),
                  
                  // محتوى النموذج
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 20),
                                  
                                  // بطاقة المعلومات الأساسية
                                  _buildInfoCard(),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // زر الحفظ
                                  _buildSaveButton(),
                                  
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
    height: 500,
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
            color: opacity < 0.5 
                ? AppColors.surface.withOpacity(0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withOpacity(opacity < 0.5 ? 0.5 : 0),
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.accent.withOpacity(0.03),
              ],
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
                      // أيقونة مميزة
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'إضافة عميل جديد',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'أدخل معلومات العميل بدقة',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
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
    );
  }

  Widget _buildInfoCard() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surface,
          AppColors.surface.withOpacity(0.95),
        ],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.primary.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: AppColors.border.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.accent.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'معلومات العميل الأساسية',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // حقل الاسم
          _buildAnimatedField(
            delay: 100,
            child: AppTextField(
              controller: _nameController,
              label: 'اسم العميل *',
              hint: 'أدخل اسم العميل',
              prefixIcon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم العميل';
                }
                return null;
              },
              onChanged: (value) {
                HapticFeedback.selectionClick();
                context.read<CustomerFormBloc>().add(
                  CustomerNameChanged(value),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // حقل الهاتف
          _buildAnimatedField(
            delay: 200,
            child: AppTextField.phone(
              controller: _phoneController,
              label: 'رقم الهاتف *',
              hint: 'أدخل رقم الهاتف',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                return null;
              },
              onChanged: (value) {
                HapticFeedback.selectionClick();
                context.read<CustomerFormBloc>().add(
                  CustomerPhoneChanged(value),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // حقل العنوان
          _buildAnimatedField(
            delay: 300,
            child: AppTextField(
              controller: _addressController,
              label: 'العنوان',
              hint: 'أدخل عنوان العميل',
              prefixIcon: Icons.location_on_outlined,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                context.read<CustomerFormBloc>().add(
                  CustomerAddressChanged(value),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // حقل الملاحظات
          _buildAnimatedField(
            delay: 400,
            child: AppTextField.multiline(
              controller: _notesController,
              label: 'ملاحظات',
              hint: 'أدخل ملاحظات إضافية',
              maxLines: 3,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAnimatedField({
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildSaveButton() => BlocBuilder<CustomersBloc, CustomersState>(
    builder: (context, state) {
      final isLoading = state is CustomersLoading;
      
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.9 + (0.1 * value),
              child: child,
            ),
          );
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading 
                  ? [
                      AppColors.textHint.withOpacity(0.5),
                      AppColors.textHint.withOpacity(0.3),
                    ]
                  : [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isLoading
                    ? Colors.transparent
                    : AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: isLoading
                    ? Colors.transparent
                    : AppColors.primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _saveCustomer,
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'حفظ العميل',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
