import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

class SuppliersTutorialService {
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
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      color: AppColors.info,
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
                      backgroundColor: AppColors.info,
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
      'المورد': AppColors.info,
      'الموردين': AppColors.info,
      'منطقة المورد': AppColors.primary,
      'تقييم الجودة': AppColors.info,
      'مستوى الثقة': AppColors.warning,
      'حفظ بيانات المورد': AppColors.success,
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
    required GlobalKey nameFieldKey,
    required GlobalKey phoneFieldKey,
    required GlobalKey areaFieldKey,
    required GlobalKey ratingSectionKey,
    required GlobalKey trustLevelKey,
    required GlobalKey notesFieldKey,
    required GlobalKey saveButtonKey,
    required ScrollController? scrollController,
    VoidCallback? onFinish,
  }) async {
    await Future.delayed(_timing.initialDelay);

    const contentHeight = 220.0;

    await _preScroll(
      context: context,
      targetKey: nameFieldKey,
      scrollController: scrollController,
      contentHeight: contentHeight,
    );

    final targetKeys = [
      nameFieldKey,
      phoneFieldKey,
      areaFieldKey,
      ratingSectionKey,
      trustLevelKey,
      notesFieldKey,
      saveButtonKey,
    ];

    final targets = <TargetFocus>[];

    targets.add(
      TargetFocus(
        identify: 'supplier_name',
        keyTarget: nameFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: nameFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 1,
                totalSteps: targetKeys.length,
                title: 'اسم المورد',
                description:
                    'أدخل اسم المورد الرئيسي كما سيظهر في التقارير والمعاملات.',
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

    targets.add(
      TargetFocus(
        identify: 'supplier_phone',
        keyTarget: phoneFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: phoneFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 2,
                totalSteps: targetKeys.length,
                title: 'رقم الهاتف',
                description:
                    'رقم للتواصل مع المورد.يمكنك تركه فارغاً إذا لم يكن متوفراً.',
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

    targets.add(
      TargetFocus(
        identify: 'supplier_area',
        keyTarget: areaFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: areaFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 3,
                totalSteps: targetKeys.length,
                title: 'منطقة المورد',
                description:
                    'يمكنك تحديد المنطقة أو الحي لتسهيل البحث وتنظيم الموردين.',
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

    targets.add(
      TargetFocus(
        identify: 'supplier_rating',
        keyTarget: ratingSectionKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: ratingSectionKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 4,
                totalSteps: targetKeys.length,
                title: 'تقييم الجودة',
                description:
                    'قيّم جودة القات أو الخدمة من 1 إلى 5يساعد في معرفة أفضل الموردين.',

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

    targets.add(
      TargetFocus(
        identify: 'supplier_trust',
        keyTarget: trustLevelKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: trustLevelKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 5,
                totalSteps: targetKeys.length,
                title: 'مستوى الثقة',
                description:
                    'حدد مدى ثقتك في هذا المورد (جديد، موثوق، متوسط...)يؤثر في قرارات الشراء والدين.',

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

    targets.add(
      TargetFocus(
        identify: 'supplier_notes',
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
                stepNumber: 6,
                totalSteps: targetKeys.length,
                title: 'ملاحظات عن المورد',
                description:
                    'اكتب أي معلومات إضافية تهمك عن هذا المورد مثل مواعيد التوريد أو شروط خاصة.',
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

    targets.add(
      TargetFocus(
        identify: 'supplier_save',
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
                stepNumber: 7,
                totalSteps: targetKeys.length,
                title: 'حفظ بيانات المورد',
                description:
                    'بعد التأكد من صحة جميع البيانات اضغط هنا لحفظ المورد في النظام.',
                onNext: () {
                  controller.skip();
                  onFinish?.call();
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
}
