import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

class ExpensesTutorialService {
  static TutorialCoachMark? _tutorial;

  static const _timing = (
    initialDelay: Duration(milliseconds: 200),
    scrollDuration: Duration(milliseconds: 350),
    scrollSettling: Duration(milliseconds: 180),
  );

  static CustomTargetContentPosition _calculatePosition({
    required BuildContext context,
    required GlobalKey targetKey,
    required double contentHeight,
  }) {
    try {
      final renderBox =
          targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        return CustomTargetContentPosition(top: 120);
      }

      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetSize = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;
      final safeAreaTop = MediaQuery.of(context).padding.top;
      final safeAreaBottom = MediaQuery.of(context).padding.bottom;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      final targetTop = targetPosition.dy;
      final targetBottom = targetPosition.dy + targetSize.height;

      const safetyMargin = 15.0;
      final usableScreenTop = safeAreaTop + safetyMargin;
      final usableScreenBottom =
          screenHeight - keyboardHeight - safeAreaBottom - safetyMargin;

      final spaceAbove = targetTop - usableScreenTop;
      final spaceBelow = usableScreenBottom - targetBottom;

      if (spaceBelow >= contentHeight + 30) {
        final position = (targetBottom + 12).clamp(
          usableScreenTop,
          usableScreenBottom - contentHeight,
        );
        return CustomTargetContentPosition(top: position);
      }

      if (spaceAbove >= contentHeight + 30) {
        final position = (targetTop - contentHeight - 12).clamp(
          usableScreenTop,
          usableScreenBottom - contentHeight,
        );
        return CustomTargetContentPosition(top: position);
      }

      if (spaceBelow >= spaceAbove) {
        final idealPosition = targetBottom + 10;
        final position = idealPosition.clamp(
          usableScreenTop,
          usableScreenBottom - contentHeight,
        );
        return CustomTargetContentPosition(top: position);
      }

      final idealPosition = targetTop - contentHeight - 10;
      final position = idealPosition.clamp(
        usableScreenTop,
        usableScreenBottom - contentHeight,
      );
      return CustomTargetContentPosition(top: position);
    } catch (_) {
      return CustomTargetContentPosition(top: 120);
    }
  }

  static Future<void> _preScroll({
    required BuildContext context,
    required GlobalKey targetKey,
    required ScrollController? scrollController,
    required double contentHeight,
  }) async {
    if (scrollController == null || !scrollController.hasClients) {
      return;
    }

    try {
      final renderBox =
          targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        return;
      }

      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetSize = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;
      final safeAreaTop = MediaQuery.of(context).padding.top;
      final safeAreaBottom = MediaQuery.of(context).padding.bottom;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      final elementTop = targetPosition.dy;
      final elementBottom = targetPosition.dy + targetSize.height;
      final currentScrollOffset = scrollController.offset;

      const topMargin = 100.0;
      final bottomMargin = contentHeight + 100;

      final usableScreenTop = safeAreaTop + topMargin;
      final usableScreenBottom =
          screenHeight - keyboardHeight - safeAreaBottom - bottomMargin;

      double scrollDelta = 0;

      if (elementTop < usableScreenTop) {
        scrollDelta = elementTop - usableScreenTop - 40;
      } else if (elementBottom > usableScreenBottom) {
        scrollDelta = elementTop - usableScreenTop - 40;
      } else {
        final spaceBelow =
            screenHeight - elementBottom - keyboardHeight - safeAreaBottom;
        if (spaceBelow < contentHeight + 40) {
          scrollDelta = max(
            (contentHeight + 50 - spaceBelow) * 0.7,
            elementTop - usableScreenTop - 40,
          );
        }
      }

      if (scrollDelta.abs() > 10) {
        final minScroll = scrollController.position.minScrollExtent;
        final maxScroll = scrollController.position.maxScrollExtent;
        final targetOffset = (currentScrollOffset + scrollDelta).clamp(
          minScroll,
          maxScroll,
        );

        final actualDelta = (targetOffset - currentScrollOffset).abs();
        if (actualDelta > 5) {
          await scrollController.animateTo(
            targetOffset,
            duration: _timing.scrollDuration,
            curve: Curves.easeInOutCubic,
          );
          await Future.delayed(_timing.scrollSettling);
        }
      }
    } catch (_) {}
  }

  static Widget _buildStepContent({
    required BuildContext context,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          width: width,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.expense,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الخطوة $stepNumber من $totalSteps',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (showSkip && onSkip != null)
                    GestureDetector(
                      onTap: onSkip,
                      child: Text(
                        'تخطي',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildHighlightedDescription(description),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onPrevious != null)
                    TextButton(
                      onPressed: onPrevious,
                      child: const Text('السابق'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expense,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isLastStep ? 'إنهاء' : 'التالي'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildHighlightedDescription(String text) {
    const baseStyle = TextStyle(
      fontSize: 14,
      height: 1.5,
      color: AppColors.textSecondary,
    );

    final keywordStyles = <String, Color>{
      'المصروفات': AppColors.expense,
      'مصروف': AppColors.expense,
      'ملخص المصروفات': AppColors.info,
      'مصروف متكرر': AppColors.warning,
      'قائمة المصروفات': AppColors.info,
      'حفظ المصروف': AppColors.success,
      'اليوم': AppColors.primary,
      'الأسبوع': AppColors.primary,
      'الشهر': AppColors.primary,
    };

    final spans = <TextSpan>[];
    var index = 0;

    while (index < text.length) {
      int nearestStart = text.length;
      String? matched;
      Color? matchedColor;

      keywordStyles.forEach((keyword, color) {
        final i = text.indexOf(keyword, index);
        if (i != -1 && i < nearestStart) {
          nearestStart = i;
          matched = keyword;
          matchedColor = color;
        }
      });

      if (matched == null) {
        spans.add(TextSpan(text: text.substring(index), style: baseStyle));
        break;
      }

      if (nearestStart > index) {
        spans.add(
          TextSpan(text: text.substring(index, nearestStart), style: baseStyle),
        );
      }

      spans.add(
        TextSpan(
          text: matched,
          style: baseStyle.copyWith(
            color: matchedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

      index = nearestStart + matched!.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      textDirection: TextDirection.rtl,
    );
  }

  static Future<void> showFormTutorial({
    required BuildContext context,
    required GlobalKey categorySectionKey,
    required GlobalKey amountFieldKey,
    required GlobalKey descriptionFieldKey,
    required GlobalKey paymentMethodKey,
    required GlobalKey dateFieldKey,
    required GlobalKey recurringSwitchKey,
    required GlobalKey notesFieldKey,
    required GlobalKey saveButtonKey,
    required ScrollController? scrollController,
    VoidCallback? onFinish,
  }) async {
    await Future.delayed(_timing.initialDelay);

    const contentHeight = 220.0;

    await _preScroll(
      context: context,
      targetKey: categorySectionKey,
      scrollController: scrollController,
      contentHeight: contentHeight,
    );

    final targetKeys = [
      categorySectionKey,
      amountFieldKey,
      descriptionFieldKey,
      paymentMethodKey,
      dateFieldKey,
      recurringSwitchKey,
      notesFieldKey,
      saveButtonKey,
    ];

    final targets = <TargetFocus>[];

    // الفئة
    targets.add(
      TargetFocus(
        identify: 'expense_category',
        keyTarget: categorySectionKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: categorySectionKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 1,
                totalSteps: targetKeys.length,
                title: 'اختيار فئة المصروف',
                description:
                    'اختر نوع المصروف (رواتب، إيجار، كهرباء، ...). يساعد ذلك في تحليل المصروفات لاحقاً.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[1],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // المبلغ
    targets.add(
      TargetFocus(
        identify: 'expense_amount',
        keyTarget: amountFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: amountFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 2,
                totalSteps: targetKeys.length,
                title: 'مبلغ المصروف',
                description:
                    'أدخل المبلغ الإجمالي للمصروف كما سيظهر في التقارير.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[2],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[0],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // الوصف
    targets.add(
      TargetFocus(
        identify: 'expense_description',
        keyTarget: descriptionFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: descriptionFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 3,
                totalSteps: targetKeys.length,
                title: 'وصف المصروف',
                description:
                    'اكتب وصفاً واضحاً للمصروف مثل: إيجار المحل، فاتورة الكهرباء لشهر معين.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[3],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[1],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // طريقة الدفع
    targets.add(
      TargetFocus(
        identify: 'expense_payment_method',
        keyTarget: paymentMethodKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: paymentMethodKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 4,
                totalSteps: targetKeys.length,
                title: 'طريقة الدفع',
                description:
                    'حدد كيف تم دفع هذا المصروف (نقد، محفظة، حوالة) لمتابعة طرق الدفع.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[4],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[2],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // التاريخ
    targets.add(
      TargetFocus(
        identify: 'expense_date',
        keyTarget: dateFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: dateFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 5,
                totalSteps: targetKeys.length,
                title: 'تاريخ المصروف',
                description:
                    'اختر التاريخ الذي تم فيه دفع المصروف ليظهر في التقارير اليومية والشهرية.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[5],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[3],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // التكرار
    targets.add(
      TargetFocus(
        identify: 'expense_recurring',
        keyTarget: recurringSwitchKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: recurringSwitchKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 6,
                totalSteps: targetKeys.length,
                title: 'مصروف متكرر',
                description:
                    'فعل هذا الخيار إذا كان المصروف يتكرر شهرياً مثل الإيجار أو الفواتير الثابتة.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[6],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[4],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // الملاحظات
    targets.add(
      TargetFocus(
        identify: 'expense_notes',
        keyTarget: notesFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: notesFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 7,
                totalSteps: targetKeys.length,
                title: 'ملاحظات إضافية',
                description:
                    'اكتب أي تفاصيل إضافية تهمك عن هذا المصروف، مثل سبب خاص أو ملاحظة محاسبية.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[7],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[5],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // زر الحفظ
    targets.add(
      TargetFocus(
        identify: 'expense_save',
        keyTarget: saveButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 8,
                totalSteps: targetKeys.length,
                title: 'حفظ المصروف',
                description:
                    'بعد التأكد من صحة جميع البيانات اضغط هنا لحفظ المصروف في النظام.',
                onNext: () {
                  controller.skip();
                  onFinish?.call();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[6],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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
      opacityShadow: 0.9,
      paddingFocus: 2,
      alignSkip: Alignment.topLeft,
      textSkip: 'تخطي',
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

    _tutorial!.show(context: context, rootOverlay: true);
  }

  static Future<void> showScreenTutorial({
    required BuildContext context,
    required GlobalKey statsCardKey,
    required GlobalKey filterChipsKey,
    required GlobalKey expensesListKey,
    required GlobalKey addExpenseButtonKey,
    required GlobalKey toggleViewButtonKey,
    required GlobalKey refreshButtonKey,
    required ScrollController scrollController,
    VoidCallback? onFinish,
  }) async {
    await Future.delayed(_timing.initialDelay);

    const contentHeight = 260.0;

    await _preScroll(
      context: context,
      targetKey: statsCardKey,
      scrollController: scrollController,
      contentHeight: contentHeight,
    );

    final targetKeys = [
      toggleViewButtonKey,
      refreshButtonKey,
      statsCardKey,
      filterChipsKey,
      expensesListKey,
      addExpenseButtonKey,
    ];

    final totalSteps = targetKeys.length;
    final targets = <TargetFocus>[];

    // زر عرض الرسم البياني/القائمة
    targets.add(
      TargetFocus(
        identify: 'expenses_toggle_view',
        keyTarget: toggleViewButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: toggleViewButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 1,
                totalSteps: totalSteps,
                title: 'التبديل بين القائمة والرسم البياني',
                description:
                    'من هنا يمكنك التبديل بين عرض قائمة المصروفات أو عرضها كرسم بياني حسب الفئة لتحليل أفضل.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[1],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // زر تحديث المصروفات
    targets.add(
      TargetFocus(
        identify: 'expenses_refresh',
        keyTarget: refreshButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: refreshButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 2,
                totalSteps: totalSteps,
                title: 'تحديث قائمة المصروفات',
                description:
                    'استخدم هذا الزر لإعادة تحميل بيانات المصروفات من النظام والتأكد من ظهور آخر العمليات.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[2],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[0],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // بطاقة ملخص المصروفات
    targets.add(
      TargetFocus(
        identify: 'expenses_stats',
        keyTarget: statsCardKey,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: statsCardKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 3,
                totalSteps: totalSteps,
                title: 'ملخص المصروفات',
                description:
                    'هذه البطاقة توضح إجمالي المصروفات، أهم الفئات، وبعض المؤشرات السريعة عن حركة المصروفات في الفترة الحالية.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[3],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[1],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // فلاتر الفترة الزمنية
    targets.add(
      TargetFocus(
        identify: 'expenses_filters_chips',
        keyTarget: filterChipsKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: filterChipsKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 4,
                totalSteps: totalSteps,
                title: 'تصفية المصروفات حسب المدة',
                description:
                    'يمكنك من هنا عرض مصروفات اليوم فقط، أو هذا الأسبوع، أو هذا الشهر، أو كل المصروفات المسجلة.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[4],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[2],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // قائمة المصروفات
    targets.add(
      TargetFocus(
        identify: 'expenses_list',
        keyTarget: expensesListKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: expensesListKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 5,
                totalSteps: totalSteps,
                title: 'تفاصيل كل مصروف',
                description:
                    'في هذه القائمة تظهر كل عملية مصروف مع فئتها، المبلغ، التاريخ، وإمكانية عرض التفاصيل أو الحذف.',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[5],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[3],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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

    // زر إضافة مصروف جديد
    targets.add(
      TargetFocus(
        identify: 'expenses_add_button',
        keyTarget: addExpenseButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 6,
                totalSteps: totalSteps,
                title: 'إضافة مصروف جديد',
                description:
                    'من هذا الزر يمكنك فتح شاشة إضافة مصروف جديد وتسجيل كل تفاصيله مثل الفئة، المبلغ، وطريقة الدفع.',
                onNext: () {
                  controller.skip();
                  onFinish?.call();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[4],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
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
      opacityShadow: 0.9,
      paddingFocus: 2,
      alignSkip: Alignment.topLeft,
      textSkip: 'تخطي',
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      onFinish: () {
        _tutorial = null;
        onFinish?.call();
      },
      onSkip: () {
        _tutorial = null;
        return true;
      },
    );

    _tutorial!.show(context: context, rootOverlay: true);
  }
}
