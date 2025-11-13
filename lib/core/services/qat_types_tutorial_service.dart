import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import 'keyboard_manager.dart';

/// خدمة التعليمات التفاعلية لأنواع القات
class QatTypesTutorialService {
  static TutorialCoachMark? _tutorial;
  static Map<String, FocusNode> _focusNodes = {};
  static final KeyboardManager _keyboardManager = KeyboardManager();
  static bool _isTransitioning = false;

  /// تسجيل FocusNodes
  static void registerFocusNodes(Map<String, FocusNode> focusNodes) {
    _focusNodes = focusNodes;
  }

  /// دالة محسنة للتمرير مع مراعاة لوحة المفاتيح
  static Future<void> _scrollToTargetWithKeyboard(
    GlobalKey key,
    ScrollController? scrollController,
    BuildContext context,
  ) async {
    // انتظار استقرار الواجهة أولاً
    await Future.delayed(const Duration(milliseconds: 100));

    final targetContext = key.currentContext;
    if (targetContext == null) return;

    try {
      // حساب ارتفاع لوحة المفاتيح الحالي
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      // الحصول على RenderObject
      final RenderObject? renderObject = targetContext.findRenderObject();
      if (renderObject == null) return;

      // حساب الموضع المطلوب مع مراعاة لوحة المفاتيح
      if (scrollController != null && scrollController.hasClients) {
        final RenderAbstractViewport? viewport = RenderAbstractViewport.of(
          renderObject,
        );

        if (viewport != null) {
          // حساب الموضع مع مراعاة لوحة المفاتيح
          double alignment = 0.2; // الموضع الافتراضي

          // إذا كانت لوحة المفاتيح ظاهرة، اضبط الموضع
          if (keyboardHeight > 0) {
            // احسب المساحة المتاحة فوق لوحة المفاتيح
            alignment = 0.1; // موضع أعلى قليلاً عند ظهور لوحة المفاتيح
          }

          final RevealedOffset revealedOffset = viewport.getOffsetToReveal(
            renderObject,
            alignment,
            rect: null,
          );

          final targetOffset = revealedOffset.offset.clamp(
            scrollController.position.minScrollExtent,
            scrollController.position.maxScrollExtent,
          );

          // تمرير سلس
          await scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );

          // انتظار استقرار التمرير
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } else {
        // استخدام Scrollable.ensureVisible كخيار احتياطي
        await Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          alignment: keyboardHeight > 0 ? 0.1 : 0.2,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );

        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('Error in _scrollToTargetWithKeyboard: $e');
    }
  }

  /// دالة محسنة للانتقال بين الخطوات
  static Future<void> _transitionToNextStep({
    required BuildContext context,
    required int currentTarget,
    required List<GlobalKey> targetKeys,
    required List<String> fieldIds,
    required ScrollController? scrollController,
    required TutorialCoachMarkController controller,
    required bool isNext,
  }) async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    try {
      // 1. إخفاء لوحة المفاتيح أولاً إذا كانت ظاهرة
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 300));

      // 2. التمرير إلى الهدف التالي/السابق
      if (currentTarget >= 0 && currentTarget < targetKeys.length) {
        await _scrollToTargetWithKeyboard(
          targetKeys[currentTarget],
          scrollController,
          context,
        );
      }

      // 3. الانتقال للخطوة التالية/السابقة في التعليمات
      if (isNext) {
        controller.next();
      } else {
        controller.previous();
      }

      // 4. انتظار اكتمال انتقال التعليمات
      await Future.delayed(const Duration(milliseconds: 600));

      // 5. طلب التركيز للحقل الجديد إذا لزم
      if (currentTarget < fieldIds.length) {
        final focusNode = _focusNodes[fieldIds[currentTarget]];
        if (focusNode != null && context.mounted) {
          // طلب التركيز بعد استقرار التعليمات
          FocusScope.of(context).requestFocus(focusNode);

          // انتظار ظهور لوحة المفاتيح
          await Future.delayed(const Duration(milliseconds: 400));

          // تمرير إضافي بعد ظهور لوحة المفاتيح للتأكد من رؤية الحقل
          if (context.mounted && currentTarget < targetKeys.length) {
            await _scrollToTargetWithKeyboard(
              targetKeys[currentTarget],
              scrollController,
              context,
            );
          }
        }
      }
    } finally {
      _isTransitioning = false;
    }
  }

  /// دالة لطلب التركيز بشكل صحيح أثناء عرض التعليمات
  static void _requestFocusWithDelay(BuildContext context, String fieldId) {
    // تأخير صغير للتأكد من عرض التعليمات أولاً
    Timer(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;

      final focusNode = _focusNodes[fieldId];
      if (focusNode != null) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  static Future<void> showAddTutorial({
    required BuildContext context,
    required GlobalKey nameFieldKey,
    required GlobalKey priceFieldKey,
    required GlobalKey saveButtonKey,
    required VoidCallback onNext,
    ScrollController? scrollController,
    Map<String, FocusNode>? focusNodes,
  }) async {
    // تسجيل FocusNodes
    if (focusNodes != null) {
      registerFocusNodes(focusNodes);
    }

    // التأكد من إخفاء لوحة المفاتيح قبل البدء
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    // التمرير إلى الحقل الأول
    await _scrollToTargetWithKeyboard(nameFieldKey, scrollController, context);

    int currentTarget = 0;
    final targetKeys = [nameFieldKey, priceFieldKey, saveButtonKey];
    final fieldIds = ['name_field', 'price_field', 'save_button'];

    final targets = <TargetFocus>[];

    // الخطوة 1: حقل الاسم
    targets.add(
      TargetFocus(
        identify: "name_field",
        keyTarget: nameFieldKey,
        alignSkip: Alignment.topLeft,
        radius: 10,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              // طلب التركيز بعد عرض التعليمات
              _requestFocusWithDelay(context, 'name_field');

              return _buildStepContent(
                stepNumber: 1,
                totalSteps: 3,
                title: 'أدخل اسم نوع القات',
                description:
                    'الآن يمكنك الكتابة في الحقل أعلاه\nأدخل اسم نوع القات ثم اضغط "التالي"',
                onNext: () async {
                  currentTarget++;
                  await _transitionToNextStep(
                    context: context,
                    currentTarget: currentTarget,
                    targetKeys: targetKeys,
                    fieldIds: fieldIds,
                    scrollController: scrollController,
                    controller: controller,
                    isNext: true,
                  );
                },
                showSkip: true,
                onSkip: () {
                  FocusScope.of(context).unfocus();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 2: حقل السعر
    targets.add(
      TargetFocus(
        identify: "price_field",
        keyTarget: priceFieldKey,
        alignSkip: Alignment.topLeft,
        radius: 10,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              // طلب التركيز بعد عرض التعليمات
              _requestFocusWithDelay(context, 'price_field');

              return _buildStepContent(
                stepNumber: 2,
                totalSteps: 3,
                title: 'أدخل الأسعار',
                description:
                    'الآن يمكنك إدخال سعر الشراء في الحقل أعلاه\nأدخل السعر ثم اضغط "التالي"',
                onNext: () async {
                  currentTarget++;
                  await _transitionToNextStep(
                    context: context,
                    currentTarget: currentTarget,
                    targetKeys: targetKeys,
                    fieldIds: fieldIds,
                    scrollController: scrollController,
                    controller: controller,
                    isNext: true,
                  );
                },
                onPrevious: () async {
                  currentTarget--;
                  await _transitionToNextStep(
                    context: context,
                    currentTarget: currentTarget,
                    targetKeys: targetKeys,
                    fieldIds: fieldIds,
                    scrollController: scrollController,
                    controller: controller,
                    isNext: false,
                  );
                },
                showSkip: true,
                onSkip: () {
                  FocusScope.of(context).unfocus();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 3: زر الحفظ
    targets.add(
      TargetFocus(
        identify: "save_button",
        keyTarget: saveButtonKey,
        alignSkip: Alignment.topLeft,
        radius: 16,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              // إلغاء أي تركيز عند عرض زر الحفظ
              Timer(const Duration(milliseconds: 100), () {
                if (context.mounted) {
                  FocusScope.of(context).unfocus();
                }
              });

              return _buildStepContent(
                stepNumber: 3,
                totalSteps: 3,
                title: 'احفظ نوع القات',
                description:
                    'بعد إدخال جميع البيانات، اضغط على هذا الزر لحفظ نوع القات الجديد',
                onNext: () {
                  controller.skip();
                  onNext();
                },
                onPrevious: () async {
                  currentTarget--;
                  await _transitionToNextStep(
                    context: context,
                    currentTarget: currentTarget,
                    targetKeys: targetKeys,
                    fieldIds: fieldIds,
                    scrollController: scrollController,
                    controller: controller,
                    isNext: false,
                  );
                },
                isLastStep: true,
                showSkip: false,
              );
            },
          ),
        ],
      ),
    );

    _tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.textPrimary,
      opacityShadow: 0.90,
      paddingFocus: 2,
      alignSkip: Alignment.topLeft,
      textSkip: "تخطي",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      onFinish: () {
        FocusScope.of(context).unfocus();
        _tutorial = null;
        _focusNodes.clear();
        _isTransitioning = false;
      },
      onSkip: () {
        FocusScope.of(context).unfocus();
        _tutorial = null;
        _focusNodes.clear();
        _isTransitioning = false;
        return true;
      },
    );

    _tutorial!.show(context: context);
  }

  static Future<void> showEditTutorial({
    required BuildContext context,
    required GlobalKey nameFieldKey,
    required GlobalKey priceFieldKey,
    required GlobalKey saveButtonKey,
    required VoidCallback onNext,
    ScrollController? scrollController,
    Map<String, FocusNode>? focusNodes,
  }) async {
    // تسجيل FocusNodes
    if (focusNodes != null) {
      registerFocusNodes(focusNodes);
    }

    // التأكد من إخفاء لوحة المفاتيح قبل البدء
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    // التمرير إلى الحقل الأول
    await _scrollToTargetWithKeyboard(nameFieldKey, scrollController, context);

    int currentTarget = 0;
    final targetKeys = [nameFieldKey, priceFieldKey, saveButtonKey];
    final fieldIds = ['name_field', 'price_field', 'save_button'];

    final targets = <TargetFocus>[];

    // الخطوة 1: حقل الاسم
    targets.add(
      TargetFocus(
        identify: "name_field",
        keyTarget: nameFieldKey,
        alignSkip: Alignment.topLeft,
        radius: 10,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              // طلب التركيز بعد عرض التعليمات
              _requestFocusWithDelay(context, 'name_field');

              return _buildStepContent(
                stepNumber: 1,
                totalSteps: 3,
                title: 'تعديل اسم نوع القات',
                description:
                    'يمكنك تعديل اسم نوع القات في الحقل أعلاه ثم اضغط "التالي"',
                onNext: () async {
                  currentTarget++;
                  await _transitionToNextStep(
                    context: context,
                    currentTarget: currentTarget,
                    targetKeys: targetKeys,
                    fieldIds: fieldIds,
                    scrollController: scrollController,
                    controller: controller,
                    isNext: true,
                  );
                },
                showSkip: true,
                onSkip: () {
                  FocusScope.of(context).unfocus();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 2: حقل السعر
    targets.add(
      TargetFocus(
        identify: "price_field",
        keyTarget: priceFieldKey,
        alignSkip: Alignment.topLeft,
        radius: 10,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              // طلب التركيز بعد عرض التعليمات
              _requestFocusWithDelay(context, 'price_field');

              return _buildStepContent(
                stepNumber: 2,
                totalSteps: 3,
                title: 'تعديل الأسعار',
                description: 'يمكنك تعديل أسعار الشراء والبيع ثم اضغط "التالي"',
                onNext: () async {
                  currentTarget++;
                  await _transitionToNextStep(
                    context: context,
                    currentTarget: currentTarget,
                    targetKeys: targetKeys,
                    fieldIds: fieldIds,
                    scrollController: scrollController,
                    controller: controller,
                    isNext: true,
                  );
                },
                onPrevious: () async {
                  currentTarget--;
                  await _transitionToNextStep(
                    context: context,
                    currentTarget: currentTarget,
                    targetKeys: targetKeys,
                    fieldIds: fieldIds,
                    scrollController: scrollController,
                    controller: controller,
                    isNext: false,
                  );
                },
                showSkip: true,
                onSkip: () {
                  FocusScope.of(context).unfocus();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 3: زر الحفظ
    targets.add(
      TargetFocus(
        identify: "save_button",
        keyTarget: saveButtonKey,
        alignSkip: Alignment.topLeft,
        radius: 16,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              // إلغاء أي تركيز
              Timer(const Duration(milliseconds: 100), () {
                if (context.mounted) {
                  FocusScope.of(context).unfocus();
                }
              });

              return _buildStepContent(
                stepNumber: 3,
                totalSteps: 3,
                title: 'احفظ التعديلات',
                description:
                    'بعد إجراء التعديلات المطلوبة، اضغط على هذا الزر لحفظ التغييرات',
                onNext: () {
                  controller.skip();
                  onNext();
                },
                onPrevious: () async {
                  currentTarget--;
                  await _transitionToNextStep(
                    context: context,
                    currentTarget: currentTarget,
                    targetKeys: targetKeys,
                    fieldIds: fieldIds,
                    scrollController: scrollController,
                    controller: controller,
                    isNext: false,
                  );
                },
                isLastStep: true,
                showSkip: false,
              );
            },
          ),
        ],
      ),
    );

    _tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.textPrimary,
      opacityShadow: 0.90,
      paddingFocus: 2,
      alignSkip: Alignment.topLeft,
      textSkip: "تخطي",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      onFinish: () {
        FocusScope.of(context).unfocus();
        _tutorial = null;
        _focusNodes.clear();
        _isTransitioning = false;
      },
      onSkip: () {
        FocusScope.of(context).unfocus();
        _tutorial = null;
        _focusNodes.clear();
        _isTransitioning = false;
        return true;
      },
    );

    _tutorial!.show(context: context);
  }

  static Future<void> showMainTutorial({
    required BuildContext context,
    required GlobalKey addButtonKey,
    required GlobalKey searchFieldKey,
    required GlobalKey filterButtonKey,
    required GlobalKey listViewKey,
    required VoidCallback onNext,
    ScrollController? scrollController,
  }) async {
    // التأكد من إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    // التمرير إلى العنصر الأول
    await _scrollToTargetWithKeyboard(addButtonKey, scrollController, context);

    int currentTarget = 0;
    final targetKeys = [
      addButtonKey,
      searchFieldKey,
      filterButtonKey,
      listViewKey,
    ];

    final targets = <TargetFocus>[];

    // الخطوة 1: زر الإضافة
    targets.add(
      TargetFocus(
        identify: "add_button",
        keyTarget: addButtonKey,
        alignSkip: Alignment.topLeft,
        radius: 30,
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                stepNumber: 1,
                totalSteps: 4,
                title: 'إضافة نوع قات جديد',
                description:
                    'اضغط على هذا الزر لإضافة نوع جديد من القات إلى المخزون',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _scrollToTargetWithKeyboard(
                      targetKeys[currentTarget],
                      scrollController,
                      context,
                    );
                  }
                  controller.next();
                },
                showSkip: true,
                onSkip: () {
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 2: حقل البحث
    targets.add(
      TargetFocus(
        identify: "search_field",
        keyTarget: searchFieldKey,
        alignSkip: Alignment.topLeft,
        radius: 10,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                stepNumber: 2,
                totalSteps: 4,
                title: 'البحث في الأنواع',
                description:
                    'استخدم هذا الحقل للبحث عن أنواع القات المختلفة بسرعة',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _scrollToTargetWithKeyboard(
                      targetKeys[currentTarget],
                      scrollController,
                      context,
                    );
                  }
                  controller.next();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _scrollToTargetWithKeyboard(
                      targetKeys[currentTarget],
                      scrollController,
                      context,
                    );
                  }
                  controller.previous();
                },
                showSkip: true,
                onSkip: () {
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 3: زر التصفية
    targets.add(
      TargetFocus(
        identify: "filter_button",
        keyTarget: filterButtonKey,
        alignSkip: Alignment.topLeft,
        radius: 16,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                stepNumber: 3,
                totalSteps: 4,
                title: 'تصفية حسب الجودة',
                description:
                    'استخدم هذا الزر لتصفية أنواع القات حسب درجة الجودة',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _scrollToTargetWithKeyboard(
                      targetKeys[currentTarget],
                      scrollController,
                      context,
                    );
                  }
                  controller.next();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _scrollToTargetWithKeyboard(
                      targetKeys[currentTarget],
                      scrollController,
                      context,
                    );
                  }
                  controller.previous();
                },
                showSkip: true,
                onSkip: () {
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 4: قائمة الأنواع
    targets.add(
      TargetFocus(
        identify: "list_view",
        keyTarget: listViewKey,
        alignSkip: Alignment.topLeft,
        radius: 16,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        enableTargetTab: false,
        paddingFocus: 2,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                stepNumber: 4,
                totalSteps: 4,
                title: 'قائمة أنواع القات',
                description:
                    'هنا تظهر جميع أنواع القات\nاضغط على أي بطاقة لعرض التفاصيل والتعديل',
                onNext: () {
                  controller.skip();
                  onNext();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _scrollToTargetWithKeyboard(
                      targetKeys[currentTarget],
                      scrollController,
                      context,
                    );
                  }
                  controller.previous();
                },
                isLastStep: true,
                showSkip: false,
              );
            },
          ),
        ],
      ),
    );

    _tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.textPrimary,
      opacityShadow: 0.90,
      paddingFocus: 2,
      alignSkip: Alignment.topLeft,
      textSkip: "تخطي",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      onFinish: () {
        _tutorial = null;
      },
      onSkip: () {
        _tutorial = null;
        return true;
      },
    );

    _tutorial!.show(context: context);
  }

  static Widget _buildStepContent({
    required int stepNumber,
    required int totalSteps,
    required String title,
    required String description,
    required VoidCallback onNext,
    VoidCallback? onPrevious,
    VoidCallback? onSkip,
    bool isLastStep = false,
    bool showSkip = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // مؤشر الخطوة
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.success],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'الخطوة $stepNumber من $totalSteps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showSkip) ...[
                const Spacer(),
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'تخطي الكل',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // العنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isLastStep ? Icons.check_circle : Icons.touch_app,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // الوصف
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // الأزرار
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر السابق
              if (onPrevious != null)
                TextButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('السابق'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                )
              else
                const SizedBox.shrink(),

              // زر التالي
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLastStep ? 'فهمت' : 'التالي',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isLastStep) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_back, size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void dispose() {
    _tutorial = null;
    _focusNodes.clear();
    _keyboardManager.dispose();
    _isTransitioning = false;
  }
}
