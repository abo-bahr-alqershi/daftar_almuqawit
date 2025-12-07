import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/purchases_tutorial_service.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/purchases/purchases_bloc.dart';
import '../../blocs/purchases/purchases_event.dart';
import '../../blocs/purchases/purchases_state.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import 'widgets/purchase_form.dart';

/// شاشة تعديل مشترى موجود - تصميم راقي ونظيف
class EditPurchaseScreen extends StatefulWidget {
  final Purchase purchase;

  const EditPurchaseScreen({super.key, required this.purchase});

  @override
  State<EditPurchaseScreen> createState() => _EditPurchaseScreenState();
}

class _EditPurchaseScreenState extends State<EditPurchaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final GlobalKey<PurchaseFormState> _formKey = GlobalKey<PurchaseFormState>();

  @override
  void initState() {
    super.initState();

    context.read<SuppliersBloc>().add(LoadSuppliers());
    context.read<QatTypesBloc>().add(LoadQatTypes());

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit(Purchase purchase) {
    HapticFeedback.mediumImpact();
    context.read<PurchasesBloc>().add(UpdatePurchaseEvent(purchase));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: BlocListener<PurchasesBloc, PurchasesState>(
          listener: (context, state) {
            if (state is PurchaseOperationSuccess || state is PurchaseUpdated) {
              HapticFeedback.heavyImpact();
              _showSnackBar(
                state is PurchaseOperationSuccess
                    ? state.message
                    : 'تم تحديث عملية الشراء بنجاح',
                isError: false,
              );
              Navigator.of(context).pop();
            } else if (state is PurchasesError) {
              HapticFeedback.heavyImpact();
              _showSnackBar(state.message, isError: true);
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final opacity = (_scrollOffset / 60).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showTutorial();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.help_outline,
                size: 20,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.05),
                const Color(0xFFF8F9FA),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 8, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_note,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'تعديل عملية الشراء',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.purchase.qatTypeName ?? 'تحديث البيانات',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SuppliersBloc, SuppliersState>(
      builder: (context, suppliersState) {
        return BlocBuilder<QatTypesBloc, QatTypesState>(
          builder: (context, qatTypesState) {
            if (suppliersState is SuppliersLoading ||
                qatTypesState is QatTypesLoading) {
              return _buildLoadingState();
            }

            if (suppliersState is SuppliersLoaded &&
                qatTypesState is QatTypesLoaded) {
              return PurchaseForm(
                key: _formKey,
                purchase: widget.purchase,
                suppliers: suppliersState.suppliers,
                qatTypes: qatTypesState.qatTypes,
                onSubmit: _handleSubmit,
                onCancel: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              );
            }

            return _buildErrorState();
          },
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
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF8B5CF6).withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'فشل تحميل البيانات المطلوبة',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<SuppliersBloc>().add(LoadSuppliers());
              context.read<QatTypesBloc>().add(LoadQatTypes());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTutorial() {
    final formState = _formKey.currentState;
    if (formState != null && formState.mounted) {
      final keys = formState.tutorialKeys;

      PurchasesTutorialService.showAddTutorial(
        context: context,
        invoiceNumberFieldKey: keys['invoiceNumber']!,
        supplierFieldKey: keys['supplier']!,
        dateFieldKey: keys['date']!,
        qatTypeFieldKey: keys['qatType']!,
        quantityFieldKey: keys['quantity']!,
        unitFieldKey: keys['unit']!,
        priceFieldKey: keys['price']!,
        paymentMethodKey: keys['paymentMethod']!,
        paidAmountKey: keys['paidAmount']!,
        saveButtonKey: keys['saveButton']!,
        scrollController: _scrollController,
        onNext: () {
          _showSnackBar('تمت التعليمات بنجاح 🎉', isError: false);
        },
      );
    } else {
      _showSnackBar('يرجى انتظار تحميل النموذج أولاً', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }
}
