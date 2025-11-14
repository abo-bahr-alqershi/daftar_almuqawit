import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import './widgets/qat_type_form.dart';
import '../../../core/services/qat_types_tutorial_service.dart';

/// شاشة إضافة نوع قات - تصميم راقي هادئ
class AddQatTypeScreen extends StatefulWidget {
  const AddQatTypeScreen({super.key});

  @override
  State<AddQatTypeScreen> createState() => _AddQatTypeScreenState();
}

class _AddQatTypeScreenState extends State<AddQatTypeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<QatTypeFormState>();
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // مفاتيح التعليمات التفاعلية
  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _qualityFieldKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();

  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null &&
          args['showTutorial'] == true &&
          args['operation'] == 'add') {
        setState(() {
          _showTutorial = true;
        });
        _startTutorial();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    QatTypesTutorialService.dispose();
    super.dispose();
  }

  void _startTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // انتظار لضمان رسم كامل العناصر قبل التمرير
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && _showTutorial) {
        await QatTypesTutorialService.showAddTutorial(
          context: context,
          nameFieldKey: _nameFieldKey,
          qualityFieldKey: _qualityFieldKey,
          saveButtonKey: _saveButtonKey,
          scrollController: _scrollController,
          onNext: () {
            setState(() {
              _showTutorial = false;
            });
          },
        );
      }
    });
  }

  Future<void> _submitQatType() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    final formData = _formKey.currentState!.getFormData();

    context.read<QatTypesBloc>().add(
      AddQatTypeEvent(
        QatType(
          name: formData['name'],
          qualityGrade: formData['qualityGrade'],
          defaultBuyPrice: formData['defaultBuyPrice'],
          defaultSellPrice: formData['defaultSellPrice'],
          icon: formData['icon'],
          availableUnits: formData['availableUnits'],
          unitPrices: formData['unitPrices'],
        ),
      ),
    );
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

            CustomScrollView(
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
                      child: BlocConsumer<QatTypesBloc, QatTypesState>(
                        listener: (context, state) {
                          if (state is QatTypeOperationSuccess) {
                            HapticFeedback.heavyImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(state.message),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            Navigator.of(context).pop(true);
                          } else if (state is QatTypesError) {
                            HapticFeedback.heavyImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(state.message),
                                  ],
                                ),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is QatTypesLoading;

                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: QatTypeForm(
                              key: _formKey,
                              onSubmit: _submitQatType,
                              onCancel: () => Navigator.of(context).pop(),
                              isLoading: isLoading,
                              nameFieldKey: _nameFieldKey,
                              qualityFieldKey: _qualityFieldKey,
                              saveButtonKey: _saveButtonKey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
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
          AppColors.primary.withOpacity(0.08),
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
        IconButton(
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
              Icons.help_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _showTutorial = true;
            });
            _startTutorial();
          },
          tooltip: 'عرض التعليمات',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.05),
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
                            colors: [AppColors.primary, AppColors.success],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
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
                              'إضافة نوع قات',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'أضف نوع جديد للمخزون',
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
