import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/sales/sale_form_bloc.dart';
import '../../blocs/sales/sale_form_event.dart';
import '../../blocs/sales/sale_form_state.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import 'widgets/sale_form.dart';

/// شاشة إضافة عملية بيع - تصميم راقي هادئ
class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersBloc>().add(LoadCustomers());
      context.read<QatTypesBloc>().add(LoadQatTypes());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return BlocProvider(
      create: (_) => SaleFormBloc(),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              _buildGradientBackground(),

              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildModernAppBar(topPadding),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard(),
                          const SizedBox(height: 24),

                          BlocConsumer<SaleFormBloc, SaleFormState>(
                            listener: (context, state) {
                              if (state is SaleFormSuccess) {
                                _showSuccessMessage();
                                Navigator.pop(context, true);
                              } else if (state is SaleFormError) {
                                _showErrorMessage(state.message);
                              }
                            },
                            builder: (context, state) {
                              if (state is SaleFormLoading) {
                                return _buildLoadingState();
                              }

                              // جلب البيانات من الـ Blocs
                              return BlocBuilder<CustomersBloc, CustomersState>(
                                builder: (context, customersState) {
                                  return BlocBuilder<
                                    QatTypesBloc,
                                    QatTypesState
                                  >(
                                    builder: (context, qatTypesState) {
                                      // استخراج قوائم العملاء وأنواع القات
                                      final customers =
                                          customersState is CustomersLoaded
                                          ? customersState.customers
                                          : <Customer>[];

                                      final qatTypes =
                                          qatTypesState is QatTypesLoaded
                                          ? qatTypesState.qatTypes
                                          : <QatType>[];

                                      return SaleForm(
                                        customers: customers,
                                        qatTypes: qatTypes,
                                        onSubmit: (data) {
                                          // يمكن معالجة البيانات هنا وإرسالها إلى الـ Bloc
                                          // حالياً نستخدم SaveSale بدون معاملات
                                          context.read<SaleFormBloc>().add(
                                            SaveSale(),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ); // إغلاق BlocProvider
  }

  Widget _buildGradientBackground() => Container(
    height: 400,
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: const Icon(
            Icons.arrow_back,
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
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(70, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.sales, AppColors.success],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إضافة بيع جديد',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'أدخل تفاصيل عملية البيع',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
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

  Widget _buildInfoCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.info.withOpacity(0.1),
                    AppColors.info.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.info,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'املأ جميع الحقول المطلوبة لإتمام عملية البيع',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
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

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'جاري حفظ البيع...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('تم إضافة البيع بنجاح'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
