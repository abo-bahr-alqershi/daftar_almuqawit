import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

/// شاشة تعديل بيع موجود - تصميم راقي واحترافي
class EditSaleScreen extends StatefulWidget {
  final Sale sale;

  const EditSaleScreen({super.key, required this.sale});

  @override
  State<EditSaleScreen> createState() => _EditSaleScreenState();
}

class _EditSaleScreenState extends State<EditSaleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  final GlobalKey<SaleFormState> _formKey = GlobalKey<SaleFormState>();

  @override
  void initState() {
    super.initState();

    context.read<CustomersBloc>().add(LoadCustomers());
    context.read<QatTypesBloc>().add(LoadQatTypes());

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
      paymentStatus:
          saleData['paymentStatus'] as String? ??
          _calculatePaymentStatus(
            saleData['totalAmount'] as double,
            saleData['paidAmount'] as double? ??
                saleData['totalAmount'] as double,
          ),
      paymentMethod: saleData['paymentMethod'] as String,
      paidAmount:
          saleData['paidAmount'] as double? ??
          saleData['totalAmount'] as double,
      remainingAmount:
          (saleData['totalAmount'] as double) -
          (saleData['paidAmount'] as double? ??
              saleData['totalAmount'] as double),
      invoiceNumber: saleData['invoiceNumber'] as String?,
      notes: saleData['notes'] as String?,
      isQuickSale: widget.sale.isQuickSale,
      status: widget.sale.status,
      createdAt: widget.sale.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    context.read<SalesBloc>().add(UpdateSaleEvent(updatedSale));
  }

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
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: BlocListener<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is SaleOperationSuccess) {
              HapticFeedback.heavyImpact();
              _showSuccessMessage(state.message);
              Navigator.of(context).pop();
            } else if (state is SalesError) {
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                        _buildFormContent(),
                        const SizedBox(height: 100),
                      ],
                    ),
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
        color: const Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showTutorial();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFFF59E0B),
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
                      Icons.edit_rounded,
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
                        const Text(
                          'تعديل البيع',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'فاتورة #${widget.sale.invoiceNumber ?? widget.sale.id}',
                          style: const TextStyle(
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withOpacity(0.08),
            const Color(0xFFF59E0B).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعديل بيانات الفاتورة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'قم بتحديث البيانات المطلوبة ثم اضغط حفظ',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return BlocBuilder<CustomersBloc, CustomersState>(
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
                'invoiceNumber': widget.sale.invoiceNumber,
              },
              customers: customers,
              qatTypes: qatTypes,
              onSubmit: _handleSubmit,
              onCancel: () => Navigator.pop(context),
            );
          },
        );
      },
    );
  }

  void _showTutorial() {
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
