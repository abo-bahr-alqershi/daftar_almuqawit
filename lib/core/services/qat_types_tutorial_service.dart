import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';


/// خدمة التعليمات المحسنة مع التحكم الكامل في الموضع
class QatTypesTutorialService {
  static TutorialCoachMark? _tutorial;
  static OverlayEntry? _customOverlay;
  
  /// حل احترافي: استخدام CustomTargetContentPosition للتحكم الدقيق
  static CustomTargetContentPosition _calculateExactPosition({
    required BuildContext context,
    required GlobalKey targetKey,
    required double contentHeight,
  }) {
    try {
      final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        return CustomTargetContentPosition(bottom: 100);
      }
      
      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetSize = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;
      final safeAreaTop = MediaQuery.of(context).padding.top;
      final safeAreaBottom = MediaQuery.of(context).padding.bottom;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      
      // حساب المساحات المتاحة
      final spaceAbove = targetPosition.dy - safeAreaTop;
      final spaceBelow = screenHeight - targetPosition.dy - targetSize.height - keyboardHeight - safeAreaBottom;
      
      // إذا كانت المساحة تحت العنصر كافية
      if (spaceBelow >= contentHeight + 50) {
        // ضع المحتوى تحت العنصر مباشرة
        return CustomTargetContentPosition(
          top: targetPosition.dy + targetSize.height + 20,
        );
      }
      // إذا كانت المساحة فوق العنصر كافية
      else if (spaceAbove >= contentHeight + 50) {
        // ضع المحتوى فوق العنصر
        return CustomTargetContentPosition(
          bottom: screenHeight - targetPosition.dy + 20,
        );
      }
      // إذا لم تكن هناك مساحة كافية، ضع المحتوى في أفضل مكان ممكن
      else {
        // ضع المحتوى في منتصف الشاشة المتاحة
        final availableCenter = (screenHeight - keyboardHeight) / 2;
        return CustomTargetContentPosition(
          top: availableCenter - (contentHeight / 2),
        );
      }
    } catch (e) {
      debugPrint('Error calculating position: $e');
      return CustomTargetContentPosition(bottom: 100);
    }
  }


  /// تمرير استباقي قبل عرض التعليمات
  static Future<void> _preScrollToEnsureVisibility({
    required BuildContext context,
    required GlobalKey targetKey,
    required ScrollController? scrollController,
    required double estimatedContentHeight,
  }) async {
    if (scrollController == null || !scrollController.hasClients) return;
    
    try {
      final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      
      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetSize = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;
      final safeAreaTop = MediaQuery.of(context).padding.top;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      
      // حساب الموضع المطلوب للعنصر
      final elementTop = targetPosition.dy;
      final elementBottom = targetPosition.dy + targetSize.height;
      
      // المنطقة المرئية المطلوبة (مع مساحة للمحتوى)
      final requiredTop = safeAreaTop + 50;
      final requiredBottom = screenHeight - keyboardHeight - estimatedContentHeight - 50;
      
      double scrollDelta = 0;
      
      // إذا كان العنصر أعلى من المطلوب
      if (elementTop < requiredTop) {
        scrollDelta = elementTop - requiredTop;
      }
      // إذا كان العنصر أسفل من المطلوب
      else if (elementBottom > requiredBottom) {
        scrollDelta = elementBottom - requiredBottom;
      }
      
      // إذا كنا بحاجة للتمرير
      if (scrollDelta.abs() > 5) {
        final targetOffset = (scrollController.offset + scrollDelta).clamp(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        );
        
        await scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
        
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint('Error in pre-scroll: $e');
    }
  }


  /// عرض تعليمات الإضافة بطريقة محسنة
  static Future<void> showAddTutorial({
    required BuildContext context,
    required GlobalKey nameFieldKey,
    required GlobalKey qualityFieldKey,
    required GlobalKey saveButtonKey,
    required VoidCallback onNext,
    ScrollController? scrollController,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // ارتفاع محتوى التعليمات التقديري
    const contentHeight = 280.0;
    
    // التمرير الاستباقي للعنصر الأول
    await _preScrollToEnsureVisibility(
      context: context,
      targetKey: nameFieldKey,
      scrollController: scrollController,
      estimatedContentHeight: contentHeight,
    );


    int currentTarget = 0;
    final targetKeys = [nameFieldKey, qualityFieldKey, saveButtonKey];


    final targets = <TargetFocus>[];


    // الخطوة 1: حقل الاسم
    targets.add(
      TargetFocus(
        identify: 'name_field',
        keyTarget: nameFieldKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: nameFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: nameFieldKey,
                scrollController: scrollController,
                stepNumber: 1,
                totalSteps: 3,
                title: 'حقل اسم نوع القات',
                description: 'هذا هو حقل إدخال اسم نوع القات\nاكتب هنا اسم النوع (مثل: قيفي رووس)\nالنظام سيحدد جميع الوحدات تلقائياً',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.next();
                },
                showSkip: true,
                onSkip: () => controller.skip(),
              );
            },
          ),
        ],
      ),
    );


    // الخطوة 2: حاوية الجودة
    targets.add(
      TargetFocus(
        identify: 'quality_field',
        keyTarget: qualityFieldKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: qualityFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: qualityFieldKey,
                scrollController: scrollController,
                stepNumber: 2,
                totalSteps: 3,
                title: 'اختيار درجة الجودة',
                description: 'هنا يمكنك اختيار درجة جودة القات\nاختر من الدرجات المتاحة (ممتاز، جيد جداً، جيد، متوسط، عادي)',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.next();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.previous();
                },
                showSkip: true,
                onSkip: () => controller.skip(),
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
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: saveButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: saveButtonKey,
                scrollController: scrollController,
                stepNumber: 3,
                totalSteps: 3,
                title: 'زر حفظ نوع القات',
                description: 'بعد إدخال اسم النوع واختيار الجودة\nاضغط على هذا الزر لحفظ نوع القات الجديد\n(سيتم تحديد كافة الوحدات تلقائياً)',
                onNext: () {
                  controller.skip();
                  onNext();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
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
      onFinish: () => _tutorial = null,
      onSkip: () {
        _tutorial = null;
        return true;
      },
    );


    _tutorial!.show(context: context);
  }

  /// عرض تعليمات التعديل بطريقة محسنة
  static Future<void> showEditTutorial({
    required BuildContext context,
    required GlobalKey nameFieldKey,
    required GlobalKey qualityFieldKey,
    required GlobalKey saveButtonKey,
    required VoidCallback onNext,
    ScrollController? scrollController,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // ارتفاع محتوى التعليمات التقديري
    const contentHeight = 280.0;
    
    // التمرير الاستباقي للعنصر الأول
    await _preScrollToEnsureVisibility(
      context: context,
      targetKey: nameFieldKey,
      scrollController: scrollController,
      estimatedContentHeight: contentHeight,
    );

    int currentTarget = 0;
    final targetKeys = [nameFieldKey, qualityFieldKey, saveButtonKey];

    final targets = <TargetFocus>[];

    // الخطوة 1: حقل الاسم
    targets.add(
      TargetFocus(
        identify: 'name_field',
        keyTarget: nameFieldKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: nameFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: nameFieldKey,
                scrollController: scrollController,
                stepNumber: 1,
                totalSteps: 3,
                title: 'تعديل اسم نوع القات',
                description: 'هنا يمكنك تعديل اسم نوع القات\nغيّر الاسم حسب الحاجة',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.next();
                },
                showSkip: true,
                onSkip: () => controller.skip(),
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 2: حاوية الجودة
    targets.add(
      TargetFocus(
        identify: 'quality_field',
        keyTarget: qualityFieldKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: qualityFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: qualityFieldKey,
                scrollController: scrollController,
                stepNumber: 2,
                totalSteps: 3,
                title: 'اختيار درجة الجودة',
                description: 'هنا يمكنك تعديل درجة جودة القات\nاختر الدرجة المناسبة من القائمة المتاحة',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.next();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.previous();
                },
                showSkip: true,
                onSkip: () => controller.skip(),
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
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: saveButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: saveButtonKey,
                scrollController: scrollController,
                stepNumber: 3,
                totalSteps: 3,
                title: 'حفظ التعديلات',
                description: 'بعد الانتهاء من التعديل\nاضغط على هذا الزر لحفظ التغييرات',
                onNext: () {
                  controller.skip();
                  onNext();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
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
      onFinish: () => _tutorial = null,
      onSkip: () {
        _tutorial = null;
        return true;
      },
    );

    _tutorial!.show(context: context);
  }


  /// محتوى محسن مع مراقبة ديناميكية للموضع
  static Widget _buildEnhancedStepContent({
    required BuildContext context,
    required GlobalKey targetKey,
    required ScrollController? scrollController,
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
    // مراقبة التمرير الديناميكية
    if (scrollController != null && scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // تحقق من أن المحتوى مرئي بالكامل
        final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final screenHeight = MediaQuery.of(context).size.height;
          
          // إذا كان المحتوى قريباً جداً من أسفل الشاشة
          if (position.dy > screenHeight - 400) {
            // قم بتمرير إضافي صغير
            final currentOffset = scrollController.offset;
            final targetOffset = currentOffset + 150;
            
            if (targetOffset <= scrollController.position.maxScrollExtent) {
              await scrollController.animateTo(
                targetOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        }
      });
    }
    
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 340,
        maxHeight: 300,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // مؤشر التقدم
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.success],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$stepNumber من $totalSteps',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (showSkip && onSkip != null)
                    TextButton(
                      onPressed: onSkip,
                      child: const Text(
                        'تخطي',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),


              // العنوان
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),


              // الوصف
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),


              // أزرار التحكم
              Row(
                children: [
                  if (onPrevious != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onPrevious,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'السابق',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                  if (onPrevious != null) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isLastStep ? 'إنهاء' : 'التالي',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  
  /// عرض تعليمات الشاشة الرئيسية
  static Future<void> showMainTutorial({
    required BuildContext context,
    required GlobalKey addButtonKey,
    required GlobalKey searchFieldKey,
    required GlobalKey filterButtonKey,
    required GlobalKey listViewKey,
    required VoidCallback onNext,
    ScrollController? scrollController,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    const contentHeight = 280.0;
    
    // التمرير الاستباقي للعنصر الأول
    await _preScrollToEnsureVisibility(
      context: context,
      targetKey: addButtonKey,
      scrollController: scrollController,
      estimatedContentHeight: contentHeight,
    );

    int currentTarget = 0;
    final targetKeys = [addButtonKey, searchFieldKey, filterButtonKey, listViewKey];

    final targets = <TargetFocus>[];

    // الخطوة 1: زر الإضافة
    targets.add(
      TargetFocus(
        identify: "add_button",
        keyTarget: addButtonKey,
        alignSkip: Alignment.topLeft,
        radius: 28,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: addButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: addButtonKey,
                scrollController: scrollController,
                stepNumber: 1,
                totalSteps: 4,
                title: 'إضافة نوع قات جديد',
                description: 'اضغط على هذا الزر لإضافة نوع قات جديد\nسيفتح لك نموذج الإدخال',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.next();
                },
                showSkip: true,
                onSkip: () => controller.skip(),
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
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: searchFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: searchFieldKey,
                scrollController: scrollController,
                stepNumber: 2,
                totalSteps: 4,
                title: 'البحث في أنواع القات',
                description: 'استخدم هذا الحقل للبحث عن أي نوع قات بالاسم أو الجودة',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.next();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.previous();
                },
                showSkip: true,
                onSkip: () => controller.skip(),
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 3: زر الترشيح
    targets.add(
      TargetFocus(
        identify: "filter_button",
        keyTarget: filterButtonKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: filterButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: filterButtonKey,
                scrollController: scrollController,
                stepNumber: 3,
                totalSteps: 4,
                title: 'ترشيح أنواع القات',
                description: 'يمكنك ترشيح القائمة حسب الجودة أو السعر أو التاريخ',
                onNext: () async {
                  currentTarget++;
                  if (currentTarget < targetKeys.length) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.next();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
                    );
                  }
                  controller.previous();
                },
                showSkip: true,
                onSkip: () => controller.skip(),
              );
            },
          ),
        ],
      ),
    );

    // الخطوة 4: قائمة أنواع القات
    targets.add(
      TargetFocus(
        identify: "list_view",
        keyTarget: listViewKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculateExactPosition(
              context: context,
              targetKey: listViewKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildEnhancedStepContent(
                context: context,
                targetKey: listViewKey,
                scrollController: scrollController,
                stepNumber: 4,
                totalSteps: 4,
                title: 'قائمة أنواع القات',
                description: 'هنا تظهر جميع أنواع القات المسجلة\nاضغط على أي نوع للتعديل أو اسحب لليسار للحذف',
                onNext: () {
                  controller.skip();
                  onNext();
                },
                onPrevious: () async {
                  currentTarget--;
                  if (currentTarget >= 0) {
                    await _preScrollToEnsureVisibility(
                      context: context,
                      targetKey: targetKeys[currentTarget],
                      scrollController: scrollController,
                      estimatedContentHeight: contentHeight,
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
      onFinish: () => _tutorial = null,
      onSkip: () {
        _tutorial = null;
        return true;
      },
    );

    _tutorial!.show(context: context);
  }

  static void dispose() {
    _tutorial = null;
    _customOverlay?.remove();
    _customOverlay = null;
  }
}
