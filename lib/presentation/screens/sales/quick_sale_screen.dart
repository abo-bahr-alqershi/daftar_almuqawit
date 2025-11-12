import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/sales/quick_sale/quick_sale_bloc.dart';
import '../../blocs/sales/quick_sale/quick_sale_event.dart';
import '../../blocs/sales/quick_sale/quick_sale_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';

/// شاشة البيع السريع - تصميم راقي وهادئ
class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityController = TextEditingController(
    text: '1.0',
  );
  final TextEditingController _priceController = TextEditingController();

  String? _selectedQatTypeId;
  String? _selectedUnit;
  String _paymentMethod = 'نقدي';
  QatType? _selectedQatType;

  @override
  void initState() {
    super.initState();
    context.read<QatTypesBloc>().add(LoadQatTypes());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _fadeController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
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
            _buildGradientBackground(),

            BlocListener<QuickSaleBloc, QuickSaleState>(
              listener: (context, state) {
                if (state is QuickSaleSuccess) {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'تم حفظ البيع السريع بنجاح',
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
                } else if (state is QuickSaleError) {
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
                  _buildModernAppBar(topPadding),

                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: BlocBuilder<QatTypesBloc, QatTypesState>(
                            builder: (context, qatTypesState) {
                              if (qatTypesState is QatTypesLoading) {
                                return _buildLoadingState();
                              }

                              if (qatTypesState is QatTypesLoaded) {
                                return _buildForm(qatTypesState.qatTypes);
                              }

                              return _buildErrorState();
                            },
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
          AppColors.sales.withOpacity(0.08),
          AppColors.success.withOpacity(0.05),
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
                AppColors.sales.withOpacity(0.05),
                AppColors.success.withOpacity(0.03),
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
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.sales, AppColors.success],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sales.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.sales.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flash_on_rounded,
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
                              'بيع سريع',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'عملية بيع فورية',
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

  Widget _buildForm(List<QatType> qatTypes) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            _buildFormCard(qatTypes),

            const SizedBox(height: 24),

            _buildSaveButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(List<QatType> qatTypes) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: AppColors.sales.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.sales.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: AppColors.border.withOpacity(0.2), width: 1),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.sales.withOpacity(0.15),
                      AppColors.success.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 22,
                  color: AppColors.sales,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'بيانات البيع السريع',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildAnimatedField(
            delay: 100,
            child: _buildQatTypeDropdown(qatTypes),
          ),

          const SizedBox(height: 20),

          if (_selectedUnit != null) ...[
            _buildAnimatedField(
              delay: 200,
              child: _buildTextField(
                controller: _quantityController,
                label: 'الكمية ($_selectedUnit)',
                hint: 'أدخل الكمية',
                icon: Icons.inventory_2_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الكمية';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'الرجاء إدخال كمية صحيحة';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          _buildAnimatedField(
            delay: 300,
            child: _buildTextField(
              controller: _priceController,
              label: 'السعر',
              hint: 'أدخل السعر',
              icon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال السعر';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'الرجاء إدخال سعر صحيح';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildAnimatedField(delay: 400, child: _buildPaymentMethodSelector()),

          const SizedBox(height: 24),

          _buildAnimatedField(delay: 500, child: _buildTotalCard()),
        ],
      ),
    ),
  );

  Widget _buildQatTypeDropdown(List<QatType> qatTypes) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedQatTypeId,
        decoration: InputDecoration(
          labelText: 'نوع القات *',
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.grass_rounded,
            color: AppColors.success,
            size: 22,
          ),
        ),
        items: qatTypes.map((qatType) {
          return DropdownMenuItem<String>(
            value: qatType.id.toString(),
            child: Text(
              qatType.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedQatTypeId = value;
            _selectedQatType = qatTypes.firstWhere(
              (qt) => qt.id.toString() == value,
              orElse: () => qatTypes.first, // إرجاع أول عنصر إذا لم يجد
            );

            if (_selectedQatType?.availableUnits != null &&
                _selectedQatType!.availableUnits!.isNotEmpty) {
              _selectedUnit = _selectedQatType!.availableUnits!.first;
            } else {
              _selectedUnit = 'كيس';
            }

            if (_selectedQatType?.defaultSellPrice != null) {
              _priceController.text = _selectedQatType!.defaultSellPrice
                  .toString();
            }
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء اختيار نوع القات';
          }
          return null;
        },
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Icon(icon, color: AppColors.info, size: 22),
        ),
        validator: validator,
        onChanged: (value) {
          HapticFeedback.selectionClick();
          setState(() {});
        },
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = ['نقدي', 'آجل', 'تحويل', 'بطاقة'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.payment_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'طريقة الدفع',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: methods.map((method) {
            final isSelected = _paymentMethod == method;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _paymentMethod = method);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  method,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTotalCard() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = quantity * price;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.sales.withOpacity(0.1),
            AppColors.success.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sales.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$total ريال',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.sales,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
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

  Widget _buildSaveButton() => BlocBuilder<QuickSaleBloc, QuickSaleState>(
    builder: (context, state) {
      final isLoading = state is QuickSaleLoading;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(scale: 0.9 + (0.1 * value), child: child),
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
                  : [AppColors.sales, AppColors.success],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isLoading
                    ? Colors.transparent
                    : AppColors.sales.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: isLoading
                    ? Colors.transparent
                    : AppColors.sales.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _handleSubmit,
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
                            Icons.flash_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'حفظ البيع السريع',
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

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.sales.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل البيانات...',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.danger.withOpacity(0.2),
                  AppColors.danger.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'حدث خطأ',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'فشل تحميل البيانات المطلوبة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();

    final quantity = double.parse(_quantityController.text);
    final price = double.parse(_priceController.text);

    context.read<QuickSaleBloc>().add(
      SubmitQuickSale(quantity: quantity, price: price),
    );
  }
}
