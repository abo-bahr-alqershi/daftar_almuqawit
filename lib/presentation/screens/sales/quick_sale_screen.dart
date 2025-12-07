import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/sales_tutorial_service.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/sales/quick_sale/quick_sale_bloc.dart';
import '../../blocs/sales/quick_sale/quick_sale_event.dart';
import '../../blocs/sales/quick_sale/quick_sale_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/app_text_field.dart';

/// شاشة البيع السريع - تصميم راقي واحترافي
class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityController = TextEditingController(
    text: '1.0',
  );
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Tutorial Keys
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
    _selectedUnit = 'ربطة';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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

        if (selectedQatType.availableUnits != null &&
            selectedQatType.availableUnits!.isNotEmpty) {
          _availableUnits = List<String>.from(selectedQatType.availableUnits!);
        } else {
          _availableUnits = ['ربطة', 'علاقية', 'كيلو'];
        }

        if (selectedQatType.unitPrices != null) {
          for (final unit in _availableUnits) {
            final unitPrice = selectedQatType.unitPrices![unit];
            _unitSellPrices[unit] = unitPrice?.sellPrice;
          }
        } else if (selectedQatType.defaultSellPrice != null) {
          for (final unit in _availableUnits) {
            _unitSellPrices[unit] = selectedQatType.defaultSellPrice;
          }
        }

        if (_availableUnits.isNotEmpty) {
          _selectedUnit = _availableUnits.first;
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
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: BlocListener<QuickSaleBloc, QuickSaleState>(
          listener: (context, state) {
            if (state is QuickSaleSuccess) {
              HapticFeedback.heavyImpact();
              _showSuccessMessage('تم حفظ البيع السريع بنجاح');
              Navigator.of(context).pop();
            } else if (state is QuickSaleError) {
              HapticFeedback.heavyImpact();
              _showErrorMessage(state.message);
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _animationController.value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          30 * (1 - _animationController.value),
                        ),
                        child: child,
                      ),
                    );
                  },
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(opacity),
      actions: [_buildHelpButton(opacity), const SizedBox(width: 8)],
      flexibleSpace: FlexibleSpaceBar(background: _buildHeaderContent()),
    );
  }

  Widget _buildBackButton(double opacity) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: opacity < 0.5 ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: opacity < 0.5
                    ? const Color(0xFFE5E7EB)
                    : Colors.transparent,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpButton(double opacity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF10B981),
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FA), Color(0xFFF8F9FA)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'بيع سريع',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'عملية بيع فورية بخطوات مختصرة',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
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
    );
  }

  Widget _buildForm(List<QatType> qatTypes) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildFormCard(qatTypes),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(List<QatType> qatTypes) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'بيانات البيع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Qat Type
          _buildQatTypeDropdown(qatTypes),

          const SizedBox(height: 18),

          // Unit Selector
          _buildUnitSelector(),

          const SizedBox(height: 18),

          // Quantity
          _buildQuantityField(),

          const SizedBox(height: 18),

          // Price
          _buildPriceField(),

          const SizedBox(height: 24),

          // Payment Method
          _buildPaymentMethodSelector(),

          const SizedBox(height: 24),

          // Notes
          _buildNotesField(),

          const SizedBox(height: 24),

          // Total
          _buildTotalCard(),
        ],
      ),
    );
  }

  Widget _buildQatTypeDropdown(List<QatType> qatTypes) {
    return Container(
      key: _qatTypeFieldKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نوع القات *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedQatTypeId,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: 'اختر نوع القات',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: Icon(
                  Icons.grass_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
              items: qatTypes.map((qatType) {
                return DropdownMenuItem(
                  value: qatType.id.toString(),
                  child: Text(qatType.name),
                );
              }).toList(),
              onChanged: (value) {
                HapticFeedback.selectionClick();
                _onQatTypeChanged(value, qatTypes);
              },
              validator: (value) =>
                  value == null ? 'الرجاء اختيار نوع القات' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    final displayUnits = _availableUnits.isEmpty
        ? ['ربطة', 'علاقية', 'كيلو']
        : _availableUnits;

    return Container(
      key: _unitFieldKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الوحدة',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: displayUnits.map((unit) {
              final isSelected = _selectedUnit == unit;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _onUnitChanged(unit);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10B981) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getUnitIcon(unit),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedUnit != null ? 'الكمية ($_selectedUnit)' : 'الكمية',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: 'أدخل الكمية',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: Icon(
                  Icons.inventory_2_rounded,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'الرجاء إدخال الكمية';
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'الرجاء إدخال كمية صحيحة';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
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
          if (value == null || value.isEmpty) return 'الرجاء إدخال السعر';
          if (double.tryParse(value) == null || double.parse(value) <= 0) {
            return 'الرجاء إدخال سعر صحيح';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = ['نقدي', 'آجل', 'تحويل', 'محفظة إلكترونية'];

    return Container(
      key: _paymentMethodKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'طريقة الدفع',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: methods.map((method) {
              final isSelected = _paymentMethod == method;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _paymentMethod = method);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    method,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF10B981).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'الإجمالي',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          Text(
            '${total.toStringAsFixed(0)} ر.ي',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<QuickSaleBloc, QuickSaleState>(
      builder: (context, state) {
        final isLoading = state is QuickSaleLoading;

        return Container(
          key: _saveButtonKey,
          child: Material(
            color: isLoading
                ? const Color(0xFFD1D5DB)
                : const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: isLoading ? null : _handleSubmit,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'حفظ البيع',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: const Color(0xFFF59E0B).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'فشل تحميل البيانات المطلوبة',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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

    if (_selectedQatTypeId == null) {
      _showErrorMessage('يرجى اختيار نوع القات');
      return;
    }

    if (_selectedUnit == null) {
      _showErrorMessage('يرجى اختيار وحدة القياس');
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
        return Icons.scale_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
