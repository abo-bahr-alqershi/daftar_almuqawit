import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/sale.dart';
import '../../blocs/sales/quick_sale/quick_sale_bloc.dart';
import '../../blocs/sales/quick_sale/quick_sale_event.dart';
import '../../blocs/sales/quick_sale/quick_sale_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/qat_type_selector.dart';
import 'widgets/quantity_input.dart';
import 'widgets/payment_buttons.dart';

/// شاشة البيع السريع - تصميم Tesla/iOS متطور محسن
class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _totalAnimationController;
  late AnimationController _successAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _backgroundAnimationController;

  // Animations
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _totalScaleAnimation;
  late Animation<double> _successBounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _backgroundAnimation;

  // Controllers & State
  final ScrollController _scrollController = ScrollController();
  bool _isCalculating = false;
  bool _showSuccess = false;
  double _scrollOffset = 0.0;

  // Form Data
  double _quantity = 1.0;
  double _price = 0.0;
  String? _selectedQatTypeId;
  String? _selectedUnit;
  String _paymentMethod = 'نقدي';

  List<String> _availableUnits = [];
  Map<String, double?> _unitSellPrices = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    context.read<QatTypesBloc>().add(LoadQatTypes());
  }

  void _initializeAnimations() {
    // Header Animation
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Content Animation
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Total Animation
    _totalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Success Animation
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse Animation
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Background Animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Setup Animations
    _headerSlideAnimation = Tween<double>(begin: -150, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _totalScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _totalAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _successBounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.bounceOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimationController.forward();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    _totalAnimationController.dispose();
    _successAnimationController.dispose();
    _pulseAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQatTypeChanged(String? qatTypeId, List<dynamic> qatTypes) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedQatTypeId = qatTypeId;
      _selectedUnit = null;
      _availableUnits = [];
      _unitSellPrices = {};
      _price = 0.0;

      if (qatTypeId != null) {
        final selectedQatType = qatTypes.firstWhere(
          (qt) => qt.id.toString() == qatTypeId,
          orElse: () => null,
        );

        if (selectedQatType != null && selectedQatType.availableUnits != null) {
          _availableUnits = List<String>.from(selectedQatType.availableUnits);

          if (selectedQatType.unitPrices != null) {
            for (var unit in _availableUnits) {
              final unitPrice = selectedQatType.unitPrices[unit];
              _unitSellPrices[unit] = unitPrice?.sellPrice;
            }
          }

          if (_availableUnits.isNotEmpty) {
            _selectedUnit = _availableUnits.first;
            _onUnitChanged(_selectedUnit);
          }
        }
      }
    });

    _totalAnimationController.forward(from: 0);
  }

  void _onUnitChanged(String? unit) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedUnit = unit;
      if (unit != null && _unitSellPrices.containsKey(unit)) {
        final defaultPrice = _unitSellPrices[unit];
        if (defaultPrice != null && defaultPrice > 0) {
          _price = defaultPrice;
        }
      }
    });
    _totalAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ultra Modern Background
          _buildUltraModernBackground(),

          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern AppBar
              _buildUltraModernAppBar(),

              // Content Body
              SliverToBoxAdapter(
                child: BlocConsumer<QuickSaleBloc, QuickSaleState>(
                  listener: _handleQuickSaleState,
                  builder: (context, quickSaleState) {
                    return BlocBuilder<QatTypesBloc, QatTypesState>(
                      builder: (context, qatTypesState) {
                        if (qatTypesState is QatTypesLoading) {
                          return _buildModernLoadingState();
                        }

                        if (qatTypesState is QatTypesLoaded) {
                          return _buildMainContent(
                            qatTypesState,
                            quickSaleState,
                          );
                        }

                        return _buildModernErrorState();
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Success Overlay
          if (_showSuccess) _buildUltraSuccessOverlay(),

          // Floating Action Button
          if (_selectedQatTypeId != null && _selectedUnit != null)
            _buildFloatingActionButton(),
        ],
      ),
    );
  }

  Widget _buildUltraModernBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                AppColors.success.withOpacity(0.03),
                AppColors.primary.withOpacity(0.02),
                AppColors.background,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated Gradient Circles
              ...List.generate(3, (index) {
                final offset =
                    _backgroundAnimation.value + (index * math.pi / 3);
                return Positioned(
                  left:
                      100 * math.cos(offset) +
                      MediaQuery.of(context).size.width / 2,
                  top: 100 * math.sin(offset) + 200,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.success.withOpacity(0.05),
                          AppColors.success.withOpacity(0.01),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),

              // Glass Morphism Effect
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUltraModernAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: AnimatedBuilder(
        animation: Listenable.merge([_headerSlideAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _headerSlideAnimation.value),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.success.withOpacity(
                      0.95 - (_scrollOffset * 0.001).clamp(0, 0.3),
                    ),
                    AppColors.success.withOpacity(
                      0.85 - (_scrollOffset * 0.001).clamp(0, 0.3),
                    ),
                    AppColors.primary.withOpacity(
                      0.7 - (_scrollOffset * 0.001).clamp(0, 0.2),
                    ),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                    32 - (_scrollOffset * 0.1).clamp(0, 32),
                  ),
                  bottomRight: Radius.circular(
                    32 - (_scrollOffset * 0.1).clamp(0, 32),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(
                      0.3 - (_scrollOffset * 0.001).clamp(0, 0.3),
                    ),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  bottom: 16,
                  left: 60,
                  right: 16,
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flash_on_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'بيع سريع',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'إتمام فوري',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                background: _buildAppBarBackgroundPattern(),
              ),
            ),
          );
        },
      ),
      leading: _buildModernBackButton(),
      actions: [
        _buildModernActionButton(
          Icons.history_rounded,
          onPressed: _showRecentSales,
        ),
        _buildModernActionButton(
          Icons.info_outline_rounded,
          onPressed: _showHelp,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarBackgroundPattern() {
    return Stack(
      children: [
        // Animated Pattern
        ...List.generate(5, (index) {
          return Positioned(
            left: 50.0 + (index * 80),
            top: 60.0 + (index * 15),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 1500 + (index * 300)),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * math.pi / 4,
                  child: Opacity(
                    opacity: value * 0.2,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),

        // Lightning Effect
        Positioned(
          right: 40,
          top: 80,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return CustomPaint(
                size: const Size(100, 120),
                painter: _LightningPainter(
                  progress: value,
                  color: Colors.white.withOpacity(0.3),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButton(
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    QatTypesLoaded qatTypesState,
    QuickSaleState quickSaleState,
  ) {
    final qatTypeOptions = qatTypesState.qatTypes
        .map(
          (qt) => QatTypeOption(
            id: qt.id.toString(),
            name: qt.name,
            price: qt.defaultSellPrice,
          ),
        )
        .toList();

    return AnimatedBuilder(
      animation: _contentFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _contentFadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Welcome Card
              _buildUltraWelcomeCard(),

              const SizedBox(height: 32),

              // Qat Type Selection
              _buildModernQatTypeSection(
                qatTypeOptions,
                qatTypesState.qatTypes,
              ),

              if (_selectedQatTypeId != null) ...[
                const SizedBox(height: 28),

                // Unit Selector
                if (_availableUnits.isNotEmpty) _buildUltraUnitSelector(),

                const SizedBox(height: 28),

                // Quantity Input
                _buildModernQuantitySection(),

                const SizedBox(height: 28),

                // Price Card
                _buildUltraPriceCard(),

                const SizedBox(height: 28),

                // Payment Methods
                _buildUltraPaymentSection(quickSaleState),
              ],

              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUltraWelcomeCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX((1 - value) * 0.2)
            ..scale(0.8 + (value * 0.2)),
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.9),
                  AppColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عملية بيع سريعة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: Colors.white.withOpacity(0.9),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'إنجاز فوري',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernQatTypeSection(
    List<QatTypeOption> options,
    List<dynamic> qatTypes,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.grass_rounded,
            title: 'نوع القات',
            subtitle: 'اختر من الأنواع المتاحة',
            required: true,
            color: AppColors.success,
          ),
          const SizedBox(height: 20),
          QatTypeSelector(
            selectedQatTypeId: _selectedQatTypeId,
            onChanged: (id) => _onQatTypeChanged(id, qatTypes),
            qatTypes: options,
          ),
        ],
      ),
    );
  }

  Widget _buildUltraUnitSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.straighten_rounded,
            title: 'وحدة القياس',
            subtitle: 'حدد الوحدة المناسبة',
            color: AppColors.info,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surface,
                  AppColors.surface.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableUnits.map((unit) {
                final isSelected = _selectedUnit == unit;
                final price = _unitSellPrices[unit];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: isSelected ? 1 : 0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return GestureDetector(
                      onTap: () => _onUnitChanged(unit),
                      child: Transform.scale(
                        scale: 1.0 + (value * 0.05),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppColors.info,
                                      AppColors.info.withOpacity(0.8),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.background,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.info
                                  : AppColors.border.withOpacity(0.2),
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.info.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getUnitIcon(unit),
                                  size: 20,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.info,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                unit,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (price != null) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${price.toStringAsFixed(0)} ريال',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.success,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuantitySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: QuantityInput(
        value: _quantity,
        onChanged: (value) {
          setState(() => _quantity = value);
          _totalAnimationController.forward(from: 0);
        },
        label: _selectedUnit != null ? 'الكمية ($_selectedUnit)' : 'الكمية',
      ),
    );
  }

  Widget _buildUltraPriceCard() {
    final total = _quantity * _price;

    return AnimatedBuilder(
      animation: _totalScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _totalScaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surface,
                  AppColors.surface.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Calculation Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.background,
                        AppColors.background.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPriceItem(
                        label: 'السعر',
                        value: _price.toStringAsFixed(2),
                        unit: 'ريال',
                        icon: Icons.attach_money_rounded,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                      _buildPriceItem(
                        label: 'الكمية',
                        value: _quantity.toStringAsFixed(1),
                        unit: _selectedUnit ?? '',
                        icon: Icons.inventory_2_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Total Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الإجمالي',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'المبلغ المستحق',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: total),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                value.toStringAsFixed(2),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ريال',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceItem({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildUltraPaymentSection(QuickSaleState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.payment_rounded,
            title: 'طريقة الدفع',
            subtitle: 'اختر طريقة الدفع المناسبة',
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),

          // Payment Methods Grid
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentMethodCard(
                        'نقدي',
                        Icons.payments_rounded,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentMethodCard(
                        'آجل',
                        Icons.schedule_rounded,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentMethodCard(
                        'تحويل',
                        Icons.swap_horizontal_circle_rounded,
                        AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentMethodCard(
                        'بطاقة',
                        Icons.credit_card_rounded,
                        AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Confirm Button
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.9 + (value * 0.1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3 * value),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: AppButton.primary(
                    text: 'إتمام البيع',
                    fullWidth: true,
                    isLoading: state is QuickSaleLoading,
                    onPressed: () => _handleQuickSale(_paymentMethod),
                    icon: Icons.rocket_launch_rounded,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String label, IconData icon, Color color) {
    final isSelected = _paymentMethod == label;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _paymentMethod = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = AppColors.primary,
    bool required = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (required) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.danger,
                            AppColors.danger.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'مطلوب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    final total = _quantity * _price;

    return Positioned(
      bottom: 20,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${total.toStringAsFixed(2)} ريال',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUltraSuccessOverlay() {
    return AnimatedBuilder(
      animation: _successBounceAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.85),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Transform.scale(
                scale: _successBounceAnimation.value,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.6),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 100,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'تم البيع بنجاح',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'العملية مكتملة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
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

  Widget _buildModernLoadingState() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 2 * math.pi),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.flash_on_rounded,
                        color: AppColors.success,
                        size: 60,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'جاري التحميل',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'يتم تجهيز البيانات...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.danger.withOpacity(0.2),
                    AppColors.danger.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'حدث خطأ',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'تعذر تحميل البيانات',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.read<QatTypesBloc>().add(LoadQatTypes());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickSaleState(BuildContext context, QuickSaleState state) {
    if (state is QuickSaleSuccess) {
      _showSuccessAnimation();
    } else if (state is QuickSaleError) {
      _showErrorMessage(state.message);
    }
  }

  void _handleQuickSale(String paymentMethod) {
    if (_selectedQatTypeId == null) {
      _showErrorMessage('الرجاء اختيار نوع القات');
      return;
    }

    if (_selectedUnit == null) {
      _showErrorMessage('الرجاء اختيار الوحدة');
      return;
    }

    if (_quantity <= 0) {
      _showErrorMessage('الرجاء إدخال كمية صحيحة');
      return;
    }

    if (_price <= 0) {
      _showErrorMessage('الرجاء إدخال سعر صحيح');
      return;
    }

    context.read<QuickSaleBloc>().add(
      SubmitQuickSale(quantity: _quantity, price: _price),
    );
  }

  void _showSuccessAnimation() {
    setState(() => _showSuccess = true);
    _successAnimationController.forward();

    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.pop(context, true);
    });
  }

  void _showErrorMessage(String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showRecentSales() {
    // Show recent sales implementation
  }

  void _showHelp() {
    // Show help implementation
  }

  IconData _getUnitIcon(String unit) {
    switch (unit) {
      case 'ربطة':
        return Icons.shopping_bag_rounded;
      case 'كيس':
        return Icons.inventory_2_rounded;
      case 'كيلو':
        return Icons.scale_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

// Custom Painter for Lightning Effect
class _LightningPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LightningPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(progress * 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.3, 0);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    path.lineTo(size.width * 0.6, size.height * 0.25);
    path.lineTo(size.width * 0.35, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.55);
    path.lineTo(size.width * 0.3, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LightningPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
