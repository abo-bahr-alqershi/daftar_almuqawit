import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

class SuppliersManagementTutorialService {
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الخطوة $stepNumber من $totalSteps',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (showSkip && onSkip != null)
                    GestureDetector(
                      onTap: onSkip,
                      child: const Text(
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
                style: const TextStyle(
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
                      backgroundColor: AppColors.primary,
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
      'الموردين': AppColors.primary,
      'قائمة الموردين': AppColors.primary,
      'المشتريات': AppColors.purchases,
      'تقييم الجودة': AppColors.info,
      'مستوى الثقة': AppColors.warning,
      'موثوق': AppColors.success,
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

  static Future<void> showScreenTutorial({
    required BuildContext context,
    required GlobalKey statsCardKey,
    required GlobalKey filterChipsKey,
    required GlobalKey suppliersListKey,
    required GlobalKey fabKey,
    required GlobalKey fullListButtonKey,
    required GlobalKey searchButtonKey,
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
      fullListButtonKey,
      searchButtonKey,
      refreshButtonKey,
      statsCardKey,
      filterChipsKey,
      suppliersListKey,
      fabKey,
    ];

    final totalSteps = targetKeys.length;
    final targets = <TargetFocus>[];

    // زر عرض قائمة الموردين الكاملة
    targets.add(
      TargetFocus(
        identify: 'suppliers_full_list_button',
        keyTarget: fullListButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: fullListButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 1,
                totalSteps: totalSteps,
                title: 'عرض قائمة الموردين الكاملة',
                description:
                    'من هنا يمكنك فتح شاشة قائمة الموردين الكاملة مع تفاصيل أكثر وتنقل أسهل بين الموردين. مفيد عندما يكون لديك عدد كبير من الموردين وتريد استعراضهم بشكل جدولي.',
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

    // زر البحث عن مورد
    targets.add(
      TargetFocus(
        identify: 'suppliers_search_button',
        keyTarget: searchButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: searchButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 2,
                totalSteps: totalSteps,
                title: 'البحث عن مورد محدد',
                description:
                    'استخدم هذا الزر للبحث عن مورد حسب الاسم، الهاتف، أو المنطقة. يساعدك على الوصول السريع للمورد الذي تريد التعامل معه أو مراجعته.',
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

    // زر تحديث قائمة الموردين
    targets.add(
      TargetFocus(
        identify: 'suppliers_refresh_button',
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
                stepNumber: 3,
                totalSteps: totalSteps,
                title: 'تحديث بيانات الموردين',
                description:
                    'يتم من هنا إعادة تحميل بيانات الموردين من النظام للتأكد من ظهور آخر عمليات الشراء أو التعديلات.',
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

    // بطاقة ملخص الموردين والمشتريات
    targets.add(
      TargetFocus(
        identify: 'suppliers_stats_card',
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
                stepNumber: 4,
                totalSteps: totalSteps,
                title: 'نظرة عامة على الموردين والمشتريات',
                description:
                    'تعرض هذه البطاقة إجمالي عدد الموردين، إجمالي قيمة المشتريات منهم، ومتوسط تقييم الجودة. من هنا يمكنك تقييم قوة شبكة الموردين لديك بسرعة.',
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

    // شريط تصنيف الموردين
    targets.add(
      TargetFocus(
        identify: 'suppliers_filters',
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
                stepNumber: 5,
                totalSteps: totalSteps,
                title: 'تصنيف الموردين حسب الجودة والحالة',
                description:
                    'من هنا يمكنك تصفية الموردين حسب مستوى الثقة والجودة (موثوق، جيد، متوسط، ضعيف) أو حسب حالة الدين عليه. يساعدك هذا على اختيار أفضل الموردين والتعامل معهم.',
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

    // كروت قائمة الموردين (أول مورد)
    targets.add(
      TargetFocus(
        identify: 'suppliers_list_first_card',
        keyTarget: suppliersListKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: suppliersListKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 6,
                totalSteps: totalSteps,
                title: 'بطاقة بيانات المورد',
                description:
                    'يمثل كل كرت هنا مورداً واحداً مع معلوماته الأساسية مثل الاسم، المنطقة، التقييم، والديون. يمكنك الضغط على الكرت لفتح تفاصيل المورد ومعرفة تاريخ التعامل معه.',
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

    // زر إضافة مورد جديد
    targets.add(
      TargetFocus(
        identify: 'suppliers_add_fab',
        keyTarget: fabKey,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 7,
                totalSteps: totalSteps,
                title: 'إضافة مورد جديد',
                description:
                    'هذا هو زر إضافة مورد جديد. من هنا يمكنك تسجيل مورد جديد مع بياناته وتقييمه. كلما كانت بيانات الموردين مرتبة، سهلت عليك إدارة المشتريات والديون.',
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
