import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/sales_tutorial_service.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_event.dart';
import '../../blocs/sales/sales_state.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import 'widgets/sale_form.dart';

/// شاشة تعديل بيع موجود - تصميم راقي
class EditSaleScreen extends StatefulWidget {
  final Sale sale;

  const EditSaleScreen({
    super.key,
    required this.sale,
  });

  @override
  State<EditSaleScreen> createState() => _EditSaleScreenState();
}

class _EditSaleScreenState extends State<EditSaleScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  
  final GlobalKey<SaleFormState> _formKey = GlobalKey<SaleFormState>();

  @override
  void initState() {
    super.initState();
    
    context.read<CustomersBloc>().add(LoadCustomers());
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
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

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
    super.dispose();
  }

  void _handleSubmit(Map<String, dynamic> saleData) {
    HapticFeedback.mediumImpact();
    
    final updatedSale = Sale(
      id: widget.sale.id,
      date: saleData['date'] as String,
      time: saleData['time'] as String,
      customerId: saleData['customerId'] as int?,
      customerName: saleData['customerName'] as String?,
      qatTypeId: saleData['qatTypeId'] as int,
      qatTypeName: saleData['qatTypeName'] as String?,
      quantity: saleData['quantity'] as double,
      unit: saleData['unit'] as String,
      unitPrice: saleData['unitPrice'] as double,
      totalAmount: saleData['totalAmount'] as double,
      discount: saleData['discount'] as double? ?? 0.0,
      paymentStatus: saleData['paymentStatus'] as String? ?? 
          _calculatePaymentStatus(
            saleData['totalAmount'] as double,
            saleData['paidAmount'] as double? ?? saleData['totalAmount'] as double,
          ),
      paymentMethod: saleData['paymentMethod'] as String,
      paidAmount: saleData['paidAmount'] as double? ?? saleData['totalAmount'] as double,
      remainingAmount: (saleData['totalAmount'] as double) - 
                       (saleData['paidAmount'] as double? ?? saleData['totalAmount'] as double),
      invoiceNumber: saleData['invoiceNumber'] as String?,
      notes: saleData['notes'] as String?,
      isQuickSale: widget.sale.isQuickSale,
      status: widget.sale.status,
      createdAt: widget.sale.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    
    context.read<SalesBloc>().add(UpdateSaleEvent(updatedSale));
  }

  /// حساب حالة الدفع
  String _calculatePaymentStatus(double totalAmount, double paidAmount) {
    if (paidAmount >= totalAmount) {
      return 'مدفوع';
    } else if (paidAmount > 0) {
      return 'مدفوع جزئياً';
    } else {
      return 'غير مدفوع';
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
            _buildGradientBackground(),

            BlocListener<SalesBloc, SalesState>(
              listener: (context, state) {
                if (state is SaleOperationSuccess) {
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
                } else if (state is SalesError) {
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
                          child: BlocBuilder<CustomersBloc, CustomersState>(
                            builder: (context, customersState) {
                              return BlocBuilder<QatTypesBloc, QatTypesState>(
                                builder: (context, qatTypesState) {
                                  final customers = customersState is CustomersLoaded
                                      ? customersState.customers
                                      : <Customer>[];

                                  final qatTypes = qatTypesState is QatTypesLoaded
                                      ? qatTypesState.qatTypes
                                      : <QatType>[];

                                  return SaleForm(
                                    key: _formKey,
                                    initialData: {
                                      'id': widget.sale.id,
                                      'customerId': widget.sale.customerId,
                                      'qatTypeId': widget.sale.qatTypeId,
                                      'quantity': widget.sale.quantity,
                                      'unit': widget.sale.unit,
                                      'price': widget.sale.unitPrice,
                                      'discount': widget.sale.discount,
                                      'paymentMethod': widget.sale.paymentMethod,
                                      'totalAmount': widget.sale.totalAmount,
                                      'paidAmount': widget.sale.paidAmount,
                                      'dueDate': widget.sale.dueDate,
                                      'notes': widget.sale.notes,
                                    },
                                    customers: customers,
                                    qatTypes: qatTypes,
                                    onSubmit: _handleSubmit,
                                    onCancel: () => Navigator.pop(context),
                                  );
                                },
                              );
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
                border: Border.all(
                  color: AppColors.sales.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: AppColors.sales,
                size: 20,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              final formState = _formKey.currentState;
              if (formState != null && formState.mounted) {
                final keys = formState.tutorialKeys;
                
                SalesTutorialService.showAddTutorial(
                  context: context,
                  invoiceNumberFieldKey: keys['invoiceNumber']!,
                  dateFieldKey: keys['date']!,
                  customerFieldKey: keys['customer']!,
                  qatTypeFieldKey: keys['qatType']!,
                  unitFieldKey: keys['unit']!,
                  quantityFieldKey: keys['quantity']!,
                  priceFieldKey: keys['price']!,
                  paymentMethodKey: keys['paymentMethod']!,
                  discountFieldKey: keys['discount']!,
                  notesFieldKey: keys['notes']!,
                  saveButtonKey: keys['saveButton']!,
                  onNext: () {},
                  scrollController: _scrollController,
                );
              }
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
                            BoxShadow(
                              color: AppColors.sales.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
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
                              'تعديل بيع',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تحديث بيانات عملية البيع',
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
}
