import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

class SalesManagementTutorialService {
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
                      color: AppColors.sales.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.point_of_sale_rounded,
                      color: AppColors.sales,
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
                      backgroundColor: AppColors.sales,
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
      'البيع السريع': AppColors.sales,
      'تحديث': AppColors.info,
      'ملخص المبيعات': AppColors.info,
      'تصفية المبيعات': AppColors.warning,
      'قائمة المبيعات': AppColors.sales,
      'بيع جديد': AppColors.success,
      'المدفوعة': AppColors.success,
      'غير المدفوعة': AppColors.danger,
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
    required GlobalKey salesListKey,
    required GlobalKey fabKey,
    required GlobalKey quickSaleButtonKey,
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
      quickSaleButtonKey,
      refreshButtonKey,
      statsCardKey,
      filterChipsKey,
      salesListKey,
      fabKey,
    ];

    final totalSteps = targetKeys.length;
    final targets = <TargetFocus>[];

    // زر البيع السريع
    targets.add(
      TargetFocus(
        identify: 'sales_quick_sale',
        keyTarget: quickSaleButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: quickSaleButtonKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 1,
                totalSteps: totalSteps,
                title: 'زر البيع السريع',
                description:
                    'زر "البيع السريع" يستخدم لتسجيل فاتورة خفيفة وبسيطة. اضغط هنا عندما تريد بيع سريع بدون إدخال كل تفاصيل الفاتورة.',
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

    // زر تحديث قائمة المبيعات
    targets.add(
      TargetFocus(
        identify: 'sales_refresh',
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
                title: 'تحديث المبيعات',
                description:
                    'إذا شعرت أن الأرقام أو قائمة المبيعات غير محدثة، اضغط هنا لعمل "تحديث" وإعادة تحميل بيانات المبيعات من النظام.',
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

    // بطاقة إحصائيات المبيعات
    targets.add(
      TargetFocus(
        identify: 'sales_stats',
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
                title: 'ملخص أداء المبيعات',
                description:
                    'في هذه البطاقة يظهر "ملخص المبيعات" بشكل مختصر: إجمالي المبيعات، عدد الفواتير، والربح التقريبي. نظرة سريعة هنا تكفي لتعرف وضع البيع اليومي.',
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

    // أزرار تصفية المبيعات
    targets.add(
      TargetFocus(
        identify: 'sales_filters',
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
                title: 'تصفية قائمة المبيعات',
                description:
                    'من هذه الأزرار يمكنك "تصفية المبيعات" في "قائمة المبيعات": عرض اليوم فقط، الفواتير "المدفوعة"، "غير المدفوعة"، أو عمليات "البيع السريع".',
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

    // قائمة المبيعات
    targets.add(
      TargetFocus(
        identify: 'sales_list',
        keyTarget: salesListKey,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: salesListKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 5,
                totalSteps: totalSteps,
                title: 'قائمة عمليات البيع',
                description:
                    'هنا تظهر "قائمة المبيعات". كل سطر يمثل فاتورة مع التاريخ، المبلغ، وحالة الدفع، ويمكنك الدخول للتفاصيل أو تنفيذ الإجراءات المتاحة.',
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

    // زر إضافة بيع جديد
    targets.add(
      TargetFocus(
        identify: 'sales_add_fab',
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
                stepNumber: 6,
                totalSteps: totalSteps,
                title: 'إضافة عملية بيع جديدة',
                description:
                    'هذا الزر لعمل "بيع جديد". اضغط هنا لفتح نموذج فاتورة كاملة عندما تريد تسجيل عملية بيع عادية بكل تفاصيلها.',
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
      onFinish: () => _tutorial = null,
      onSkip: () {
        _tutorial = null;
        return true;
      },
    );

    _tutorial!.show(context: context, rootOverlay: true);
  }
}
