import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/sales_tutorial_service.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/sales/quick_sale/quick_sale_bloc.dart';
import '../../blocs/sales/quick_sale/quick_sale_event.dart';
import '../../blocs/sales/quick_sale/quick_sale_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/app_text_field.dart';

/// شاشة البيع السريع - تصميم راقي وهادئ ورسمي
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
  final TextEditingController _notesController = TextEditingController();

  // مفاتيح التعليمات
  final _qatTypeFieldKey = GlobalKey();
  final _unitFieldKey = GlobalKey();
  final _quantityFieldKey = GlobalKey();
  final _priceFieldKey = GlobalKey();
  final _paymentMethodKey = GlobalKey();
  final _notesFieldKey = GlobalKey();
  final _saveButtonKey = GlobalKey();

  String? _selectedQatTypeId;
  String? _selectedUnit;
  String _paymentMethod = 'نقدي';
  QatType? _selectedQatType;

  List<String> _availableUnits = [];
  Map<String, double?> _unitSellPrices = {};

  @override
  void initState() {
    super.initState();
    context.read<QatTypesBloc>().add(LoadQatTypes());

    // اختيار الوحدة الافتراضية الأولى
    _selectedUnit = 'ربطة';

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
    _notesController.dispose();
    super.dispose();
  }

  void _onQatTypeChanged(String? qatTypeId, List<QatType> qatTypes) {
    setState(() {
      _selectedQatTypeId = qatTypeId;
      _selectedUnit = null;
      _availableUnits = [];
      _unitSellPrices = {};
      _priceController.clear();

      if (qatTypeId != null && qatTypes.isNotEmpty) {
        final selectedQatType = qatTypes.firstWhere(
          (qt) => qt.id.toString() == qatTypeId,
          orElse: () => qatTypes.first,
        );

        _selectedQatType = selectedQatType;

        debugPrint('🔍 Selected QatType: ${selectedQatType.name}');
        debugPrint('🔍 Available Units: ${selectedQatType.availableUnits}');
        debugPrint('🔍 Unit Prices: ${selectedQatType.unitPrices}');

        // إذا لم تكن هناك وحدات محددة، استخدم الوحدات الافتراضية
        if (selectedQatType.availableUnits != null &&
            selectedQatType.availableUnits!.isNotEmpty) {
          _availableUnits = List<String>.from(selectedQatType.availableUnits!);
          debugPrint('✅ Units loaded from QatType: $_availableUnits');
        } else {
          // وحدات افتراضية
          _availableUnits = ['ربطة', 'علاقية', 'كيلو'];
          debugPrint(
            '⚠️ No units in QatType, using default units: $_availableUnits',
          );
        }

        // تحميل الأسعار إذا كانت متوفرة
        if (selectedQatType.unitPrices != null) {
          for (final unit in _availableUnits) {
            final unitPrice = selectedQatType.unitPrices![unit];
            _unitSellPrices[unit] = unitPrice?.sellPrice;
          }
          debugPrint('✅ Prices loaded: $_unitSellPrices');
        } else {
          // استخدام السعر الافتراضي للبيع إذا كان متوفراً
          if (selectedQatType.defaultSellPrice != null) {
            for (final unit in _availableUnits) {
              _unitSellPrices[unit] = selectedQatType.defaultSellPrice;
            }
            debugPrint(
              '⚠️ Using default sell price for all units: ${selectedQatType.defaultSellPrice}',
            );
          }
        }

        // اختيار الوحدة الأولى تلقائياً
        if (_availableUnits.isNotEmpty) {
          _selectedUnit = _availableUnits.first;
          debugPrint('✅ Default unit selected: $_selectedUnit');
          _onUnitChanged(_selectedUnit);
        }
      }
    });
  }

  void _onUnitChanged(String? unit) {
    setState(() {
      _selectedUnit = unit;
      if (unit != null && _unitSellPrices.containsKey(unit)) {
        final defaultPrice = _unitSellPrices[unit];
        if (defaultPrice != null && defaultPrice > 0) {
          _priceController.text = defaultPrice.toString();
        }
      }
    });
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.sales.withOpacity(0.15),
                    AppColors.success.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sales.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: AppColors.sales,
                size: 20,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();

              SalesTutorialService.showQuickSaleTutorial(
                context: context,
                qatTypeFieldKey: _qatTypeFieldKey,
                unitFieldKey: _unitFieldKey,
                quantityFieldKey: _quantityFieldKey,
                priceFieldKey: _priceFieldKey,
                paymentMethodKey: _paymentMethodKey,
                notesFieldKey: _notesFieldKey,
                saveButtonKey: _saveButtonKey,
                onNext: () {},
                scrollController: _scrollController,
              );
            },
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.sales.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
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

          _buildAnimatedField(delay: 200, child: _buildUnitSelector()),

          const SizedBox(height: 20),

          _buildAnimatedField(delay: 300, child: _buildQuantityField()),

          const SizedBox(height: 20),

          _buildAnimatedField(delay: 400, child: _buildPriceField()),

          const SizedBox(height: 24),

          _buildAnimatedField(delay: 500, child: _buildPaymentMethodSelector()),

          const SizedBox(height: 24),

          _buildAnimatedField(delay: 600, child: _buildNotesField()),

          const SizedBox(height: 24),

          _buildAnimatedField(delay: 700, child: _buildTotalCard()),
        ],
      ),
    ),
  );

  Widget _buildQatTypeDropdown(List<QatType> qatTypes) {
    return Container(
      key: _qatTypeFieldKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نوع القات *',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedQatTypeId,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'اختر نوع القات',
                prefixIcon: Icon(Icons.grass_rounded),
              ),
              dropdownColor: AppColors.surface,
              iconEnabledColor: AppColors.sales,
              style: AppTextStyles.bodyMedium,
              items: qatTypes.map((qatType) {
                return DropdownMenuItem(
                  value: qatType.id.toString(),
                  child: Row(
                    children: [
                      Icon(Icons.grass, size: 18, color: AppColors.sales),
                      const SizedBox(width: 8),
                      Text(
                        qatType.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                HapticFeedback.selectionClick();
                _onQatTypeChanged(value, qatTypes);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء اختيار نوع القات';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    // إذا لم يتم اختيار نوع قات، استخدم الوحدات الافتراضية
    final displayUnits = _availableUnits.isEmpty
        ? ['ربطة', 'علاقية', 'كيلو']
        : _availableUnits;

    return Container(
      key: _unitFieldKey,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.straighten_rounded, color: AppColors.sales, size: 18),
              const SizedBox(width: 8),
              Text(
                'اختر الوحدة',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayUnits.map((unit) {
              final isSelected = _selectedUnit == unit;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUnit = unit;
                  });
                  _onUnitChanged(unit);
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.sales.withOpacity(0.15),
                              AppColors.sales.withOpacity(0.08),
                            ],
                          )
                        : null,
                    color: isSelected ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.sales.withOpacity(0.3)
                          : AppColors.border.withOpacity(0.15),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getUnitIcon(unit),
                        size: 16,
                        color: isSelected
                            ? AppColors.sales
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? AppColors.sales
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityField() {
    return Container(
      key: _quantityFieldKey,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.25)),
      ),
      child: TextFormField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: 'الكمية ($_selectedUnit)',
          hintText: 'أدخل الكمية',
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          prefixIcon: Icon(
            Icons.inventory_2_outlined,
            color: AppColors.info,
            size: 18,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال الكمية';
          }
          if (double.tryParse(value) == null || double.parse(value) <= 0) {
            return 'الرجاء إدخال كمية صحيحة';
          }
          return null;
        },
        onChanged: (value) {
          HapticFeedback.selectionClick();
          setState(() {});
        },
      ),
    );
  }

  Widget _buildPriceField() {
    return Container(
      key: _priceFieldKey,
      child: AppTextField.currency(
        controller: _priceController,
        label: 'السعر',
        hint: 'أدخل السعر',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال السعر';
          }
          if (double.tryParse(value) == null || double.parse(value) <= 0) {
            return 'الرجاء إدخال سعر صحيح';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = ['نقدي', 'آجل', 'تحويل', 'بطاقة'];

    return Column(
      key: _paymentMethodKey,
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

  Widget _buildNotesField() {
    return Container(
      key: _notesFieldKey,
      child: AppTextField.multiline(
        controller: _notesController,
        label: 'ملاحظات (اختياري)',
        hint: 'أضف أي ملاحظات إضافية',
        maxLines: 3,
      ),
    );
  }

  Widget _buildTotalCard() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = quantity * price;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'الإجمالي',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '${total.toStringAsFixed(2)} ريال',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
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
          key: _saveButtonKey,
          height: 52,
          decoration: BoxDecoration(
            gradient: isLoading
                ? LinearGradient(
                    colors: [
                      AppColors.border.withOpacity(0.3),
                      AppColors.border.withOpacity(0.2),
                    ],
                  )
                : const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _handleSubmit,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'حفظ البيع',
                            style: AppTextStyles.button.copyWith(
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
        borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.circular(24),
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

    // التحقق من اختيار نوع القات
    if (_selectedQatTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار نوع القات'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // التحقق من اختيار وحدة القياس
    if (_selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار وحدة القياس'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final quantity = double.parse(_quantityController.text);
    final price = double.parse(_priceController.text);
    final notes = _notesController.text.trim().isEmpty 
        ? null 
        : _notesController.text.trim();

    context.read<QuickSaleBloc>().add(
      SubmitQuickSale(
        qatTypeId: int.parse(_selectedQatTypeId!),
        unit: _selectedUnit!,
        quantity: quantity,
        price: price,
        notes: notes,
      ),
    );
  }

  IconData _getUnitIcon(String unit) {
    switch (unit) {
      case 'ربطة':
        return Icons.shopping_bag_rounded;
      case 'علاقية':
        return Icons.inventory_2_rounded;
      case 'كيلو':
        return Icons.category_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
