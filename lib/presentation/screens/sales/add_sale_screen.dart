import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/sale.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_event.dart';
import '../../blocs/sales/sales_state.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/sale_form.dart';

/// شاشة إضافة عملية بيع - تصميم Tesla/iOS متطور
class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _progressAnimation;

  double _formProgress = 0;
  int _currentStep = 0;
  final int _totalSteps = 5;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadRequiredData();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _formFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeIn),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _headerAnimationController.forward();
    _formAnimationController.forward();
  }

  void _loadRequiredData() {
    context.read<CustomersBloc>().add(LoadCustomers());
    context.read<QatTypesBloc>().add(LoadQatTypes());
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _formAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _updateProgress(double progress) {
    setState(() {
      _formProgress = progress;
      _currentStep = (progress * _totalSteps).round();
    });
    _progressAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        // خلفية متحركة
        _buildAnimatedBackground(),

        // المحتوى الرئيسي
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar مخصص
            _buildModernAppBar(),

            // المحتوى
            SliverToBoxAdapter(
              child: BlocConsumer<SalesBloc, SalesState>(
                listener: (context, state) {
                  if (state is SalesSuccess) {
                    _showSuccessAnimation();
                  } else if (state is SalesError) {
                    _showErrorMessage(state.message);
                  }
                },
                builder: (context, salesState) {
                  if (salesState is SalesLoading) {
                    return _buildSavingState();
                  }

                  return BlocBuilder<CustomersBloc, CustomersState>(
                    builder: (context, customersState) =>
                        BlocBuilder<QatTypesBloc, QatTypesState>(
                          builder: (context, qatTypesState) {
                            if (customersState is CustomersLoading ||
                                qatTypesState is QatTypesLoading) {
                              return _buildLoadingState();
                            }

                            if (customersState is CustomersLoaded &&
                                qatTypesState is QatTypesLoaded) {
                              return AnimatedBuilder(
                                animation: _formFadeAnimation,
                                builder: (context, child) => FadeTransition(
                                  opacity: _formFadeAnimation,
                                  child: SaleForm(
                                    customers: customersState.customers,
                                    qatTypes: qatTypesState.qatTypes,
                                    onSubmit: _handleSubmit,
                                    onCancel: _handleCancel,
                                    // onProgressChanged: _updateProgress,
                                  ),
                                ),
                              );
                            }

                            return _buildErrorState();
                          },
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildAnimatedBackground() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withOpacity(0.03),
          AppColors.accent.withOpacity(0.01),
          AppColors.background,
        ],
      ),
    ),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        color: Colors.transparent,
        child: CustomPaint(painter: _AddSaleBackgroundPainter()),
      ),
    ),
  );

  Widget _buildModernAppBar() => SliverAppBar(
    expandedHeight: 220,
    pinned: true,
    backgroundColor: Colors.transparent,
    flexibleSpace: AnimatedBuilder(
      animation: _headerSlideAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _headerSlideAnimation.value),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FlexibleSpaceBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'إضافة بيع',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            background: Stack(
              children: [_buildAppBarBackground(), _buildProgressIndicator()],
            ),
          ),
        ),
      ),
    ),
    leading: _buildBackButton(),
    actions: [
      _buildActionButton(Icons.info_outline, onPressed: _showHelp),
      const SizedBox(width: 8),
    ],
  );

  Widget _buildBackButton() => Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
      onPressed: () {
        HapticFeedback.lightImpact();
        _handleCancel();
      },
    ),
  );

  Widget _buildActionButton(IconData icon, {required VoidCallback onPressed}) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 22),
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
        ),
      );

  Widget _buildAppBarBackground() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.1), Colors.transparent],
      ),
    ),
    child: Stack(
      children: [
        // Animated Shapes
        ...List.generate(
          3,
          (index) => Positioned(
            left: 50.0 + (index * 100),
            top: 100.0 + (index * 20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 1000 + (index * 200)),
              builder: (context, value, child) => Transform.rotate(
                angle: value * math.pi / 4,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1 * value),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildProgressIndicator() => Positioned(
    bottom: 40,
    left: 20,
    right: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'خطوة $_currentStep من $_totalSteps',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(_formProgress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) => FractionallySizedBox(
              widthFactor: _formProgress * _progressAnimation.value,
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildStepIndicators(),
      ],
    ),
  );

  Widget _buildStepIndicators() {
    final steps = ['العميل', 'المنتج', 'الكمية', 'السعر', 'الدفع'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < _currentStep;
        final isActive = index == _currentStep;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.primary,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? AppColors.primary : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState() => SizedBox(
    height: 600,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) => Transform.rotate(
              angle: value * 2 * math.pi,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.accent.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.shopping_cart,
                    color: AppColors.primary,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل البيانات...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSavingState() => SizedBox(
    height: 600,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              Icon(Icons.save, color: AppColors.primary, size: 50),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'جاري حفظ البيانات...',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى الانتظار',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildErrorState() => Container(
    height: 600,
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.danger.withOpacity(0.1),
                  AppColors.danger.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'حدث خطأ',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'تعذر تحميل البيانات المطلوبة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadRequiredData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );

  void _handleSubmit(Map<String, dynamic> data) {
    HapticFeedback.mediumImpact();
    context.read<SalesBloc>().add(
      AddSaleEvent(
        Sale(
          date: data['date'],
          time: data['time'],
          customerId: data['customerId'],
          qatTypeId: data['qatTypeId'],
          quantity: data['quantity'],
          unit: data['unit'] ?? 'كيس',
          unitPrice: data['unitPrice'],
          totalAmount: data['totalAmount'],
          discount: data['discount'],
          paymentMethod: data['paymentMethod'],
          notes: data['notes'],
        ),
      ),
    );
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    showDialog(context: context, builder: (context) => _buildCancelDialog());
  }

  Widget _buildCancelDialog() => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Row(
      children: [
        Icon(Icons.warning, color: AppColors.warning),
        SizedBox(width: 12),
        Text('تأكيد الإلغاء'),
      ],
    ),
    content: Text(
      'هل أنت متأكد من إلغاء إضافة البيع؟\nسيتم فقدان جميع البيانات المدخلة.',
      style: AppTextStyles.bodyMedium,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('متابعة'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
        child: const Text('إلغاء البيع'),
      ),
    ],
  );

  void _showSuccessAnimation() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Go back
    });
  }

  Widget _buildSuccessDialog() => Center(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 80),
              SizedBox(height: 16),
              Text(
                'تم الحفظ بنجاح',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _showErrorMessage(String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showHelp() {
    showDialog(context: context, builder: (context) => _buildHelpDialog());
  }

  Widget _buildHelpDialog() => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.help_outline, color: AppColors.info, size: 48),
          const SizedBox(height: 16),
          Text(
            'مساعدة',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'لإضافة عملية بيع جديدة:\n'
            '1. اختر العميل أو اترك الحقل فارغاً للبيع المباشر\n'
            '2. حدد نوع القات والوحدة\n'
            '3. أدخل الكمية والسعر\n'
            '4. اختر طريقة الدفع\n'
            '5. اضغط على حفظ البيع',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('فهمت'),
          ),
        ],
      ),
    ),
  );
}

// رسام الخلفية
class _AddSaleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // رسم الأشكال الهندسية
    for (var i = 0; i < 4; i++) {
      paint.color = AppColors.primary.withOpacity(0.02 - (i * 0.004));

      final rect = Rect.fromCenter(
        center: Offset(
          size.width * (0.2 + i * 0.2),
          size.height * (0.3 + i * 0.1),
        ),
        width: 100 + (i * 30),
        height: 100 + (i * 30),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(20)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
