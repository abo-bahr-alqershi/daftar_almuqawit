import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

/// شاشة البيع السريع
/// 
/// تسمح ببيع سريع دون الحاجة لإدخال تفاصيل كثيرة
class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen> {
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
    context.read<QatTypesBloc>().add(LoadQatTypes());
  }
  
  void _onQatTypeChanged(String? qatTypeId, List<dynamic> qatTypes) {
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
  }
  
  void _onUnitChanged(String? unit) {
    setState(() {
      _selectedUnit = unit;
      if (unit != null && _unitSellPrices.containsKey(unit)) {
        final defaultPrice = _unitSellPrices[unit];
        if (defaultPrice != null && defaultPrice > 0) {
          _price = defaultPrice;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.white),
            const SizedBox(width: 8),
            const Text('بيع سريع'),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
      body: BlocConsumer<QuickSaleBloc, QuickSaleState>(
        listener: (context, state) {
          if (state is QuickSaleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت عملية البيع بنجاح')),
            );
            Navigator.of(context).pop();
          } else if (state is QuickSaleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, quickSaleState) {
          return BlocBuilder<QatTypesBloc, QatTypesState>(
            builder: (context, qatTypesState) {
              if (qatTypesState is QatTypesLoading) {
                return const LoadingWidget();
              }

              if (qatTypesState is QatTypesLoaded) {
                final qatTypeOptions = qatTypesState.qatTypes.map((qt) => 
                  QatTypeOption(
                    id: qt.id.toString(),
                    name: qt.name,
                    price: qt.defaultSellPrice,
                  )
                ).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),

                      QatTypeSelector(
                        selectedQatTypeId: _selectedQatTypeId,
                        onChanged: (qatTypeId) => _onQatTypeChanged(qatTypeId, qatTypesState.qatTypes),
                        qatTypes: qatTypeOptions,
                      ),
                      const SizedBox(height: 24),
                      
                      if (_availableUnits.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.straighten, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'اختر الوحدة',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableUnits.map((unit) {
                                  final isSelected = _selectedUnit == unit;
                                  return ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getUnitIcon(unit),
                                          size: 18,
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(unit),
                                      ],
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        _onUnitChanged(unit);
                                      }
                                    },
                                    backgroundColor: AppColors.surface,
                                    selectedColor: AppColors.success,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      QuantityInput(
                        value: _quantity,
                        onChanged: (value) => setState(() => _quantity = value),
                        label: _selectedUnit != null ? 'الكمية ($_selectedUnit)' : 'الكمية',
                      ),
                      const SizedBox(height: 24),

                      _buildPriceCard(),
                      const SizedBox(height: 24),

                      const SizedBox(height: 8),

                      AppButton.primary(
                        text: 'تأكيد البيع',
                        fullWidth: true,
                        isLoading: quickSaleState is QuickSaleLoading,
                        onPressed: () => _handleQuickSale(_paymentMethod),
                        icon: Icons.check_circle,
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('حدث خطأ في تحميل البيانات'));
            },
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بيع سريع',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'عملية بيع سريعة بدون تفاصيل إضافية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    final total = _quantity * _price;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedUnit != null ? 'سعر $_selectedUnit' : 'السعر',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${_price.toStringAsFixed(2)} ريال',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} ريال',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleQuickSale(String paymentMethod) {
    if (_selectedQatTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار نوع القات')),
      );
      return;
    }
    
    if (_selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الوحدة')),
      );
      return;
    }

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال كمية صحيحة')),
      );
      return;
    }

    if (_price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال سعر صحيح')),
      );
      return;
    }

    context.read<QuickSaleBloc>().add(
      SubmitQuickSale(
        quantity: _quantity,
        price: _price,
      ),
    );
  }
  
  IconData _getUnitIcon(String unit) {
    switch (unit) {
      case 'ربطة':
        return Icons.shopping_bag;
      case 'كيس':
        return Icons.inventory_2;
      case 'كيلو':
        return Icons.scale;
      default:
        return Icons.category;
    }
  }
}
