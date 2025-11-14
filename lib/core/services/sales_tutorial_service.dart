import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

/// خدمة التعليمات المحسنة لشاشات المبيعات مع Transitions احترافية
class SalesTutorialService {
  static TutorialCoachMark? _tutorial;
  static bool _isTransitioning = false;
  
  /// معاملات التوقيت المحسّنة والآمنة للانتقالات السلسة
  static const _timing = (
    initialDelay: Duration(milliseconds: 200),
    scrollDuration: Duration(milliseconds: 350),
    scrollSettling: Duration(milliseconds: 180),
    transitionGap: Duration(milliseconds: 100),
  );

  /// حساب الموضع المثالي للمحتوى مع معالجة دقيقة واحترافية شاملة
  static CustomTargetContentPosition _calculatePosition({
    required BuildContext context,
    required GlobalKey targetKey,
    required double contentHeight,
  }) {
    try {
      final renderBox =
          targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        debugPrint('⚠️ RenderBox is null, using fallback position');
        return CustomTargetContentPosition(top: 120);
      }

      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetSize = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      final safeAreaTop = MediaQuery.of(context).padding.top;
      final safeAreaBottom = MediaQuery.of(context).padding.bottom;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      final targetTop = targetPosition.dy;
      final targetBottom = targetPosition.dy + targetSize.height;
      final targetHeight = targetSize.height;
      final targetLeft = targetPosition.dx;

      final safetyMargin = 15.0;
      final usableScreenTop = safeAreaTop + safetyMargin;
      final usableScreenBottom =
          screenHeight - keyboardHeight - safeAreaBottom - safetyMargin;
      final usableHeight = usableScreenBottom - usableScreenTop;

      final spaceAbove = targetTop - usableScreenTop;
      final spaceBelow = usableScreenBottom - targetBottom;
      final totalAvailableSpace = spaceAbove + spaceBelow;

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🎯 Target Analysis:');
      debugPrint(
        '   Position: top=$targetTop, bottom=$targetBottom, left=$targetLeft',
      );
      debugPrint('   Size: width=${targetSize.width}, height=$targetHeight');
      debugPrint('📱 Screen Info:');
      debugPrint('   Total height=$screenHeight, width=$screenWidth');
      debugPrint(
        '   Keyboard=$keyboardHeight, SafeTop=$safeAreaTop, SafeBottom=$safeAreaBottom',
      );
      debugPrint('📏 Space Analysis:');
      debugPrint('   Above target: $spaceAbove px');
      debugPrint('   Below target: $spaceBelow px');
      debugPrint('   Content needs: $contentHeight px');
      debugPrint('   Total available: $totalAvailableSpace px');
      debugPrint(
        '   Usable area: $usableScreenTop → $usableScreenBottom ($usableHeight px)',
      );

      if (spaceBelow >= contentHeight + 30) {
        final position = (targetBottom + 12).clamp(
          usableScreenTop,
          usableScreenBottom - contentHeight,
        );
        debugPrint(
          '✅ Strategy: BELOW - Enough space (${spaceBelow.toStringAsFixed(0)} px)',
        );
        debugPrint('   Content at: $position px (clamped to safe area)');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return CustomTargetContentPosition(top: position);
      }

      if (spaceAbove >= contentHeight + 30) {
        final position = (targetTop - contentHeight - 12).clamp(
          usableScreenTop,
          usableScreenBottom - contentHeight,
        );
        debugPrint(
          '✅ Strategy: ABOVE - Enough space (${spaceAbove.toStringAsFixed(0)} px)',
        );
        debugPrint('   Content at: $position px (clamped to safe area)');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return CustomTargetContentPosition(top: position);
      }

      debugPrint('⚠️ Limited space - Using smart positioning...');

      final belowRatio = totalAvailableSpace > 0
          ? spaceBelow / totalAvailableSpace
          : 0;
      final aboveRatio = totalAvailableSpace > 0
          ? spaceAbove / totalAvailableSpace
          : 0;

      debugPrint(
        '   Space ratio - Below: ${(belowRatio * 100).toStringAsFixed(1)}%, Above: ${(aboveRatio * 100).toStringAsFixed(1)}%',
      );

      if (spaceBelow >= spaceAbove) {
        final idealPosition = targetBottom + 10;
        final position = idealPosition.clamp(
          usableScreenTop,
          usableScreenBottom - contentHeight,
        );

        debugPrint(
          '✅ Strategy: BELOW (constrained) - ${spaceBelow.toStringAsFixed(0)} px available',
        );
        debugPrint('   Ideal: $idealPosition, Final: $position (clamped)');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return CustomTargetContentPosition(top: position);
      }

      final idealPosition = targetTop - contentHeight - 10;
      final position = idealPosition.clamp(
        usableScreenTop,
        usableScreenBottom - contentHeight,
      );

      debugPrint(
        '✅ Strategy: ABOVE (constrained) - ${spaceAbove.toStringAsFixed(0)} px available',
      );
      debugPrint('   Ideal: $idealPosition, Final: $position (clamped)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return CustomTargetContentPosition(top: position);
    } catch (e) {
      debugPrint('❌ Error calculating position: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return CustomTargetContentPosition(top: 120);
    }
  }

  /// تمرير استباقي ذكي محسّن مع معالجة احترافية لجميع السيناريوهات
  static Future<void> _preScroll({
    required BuildContext context,
    required GlobalKey targetKey,
    required ScrollController? scrollController,
    required double contentHeight,
  }) async {
    if (scrollController == null || !scrollController.hasClients) {
      debugPrint('⚠️ No scroll controller available');
      return;
    }

    try {
      final renderBox =
          targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        debugPrint('⚠️ RenderBox not available for scroll calculation');
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
      final elementHeight = targetSize.height;
      final currentScrollOffset = scrollController.offset;

      final topMargin = 100.0;
      final bottomMargin = contentHeight + 100;

      final usableScreenTop = safeAreaTop + topMargin;
      final usableScreenBottom =
          screenHeight - keyboardHeight - safeAreaBottom - bottomMargin;
      final usableHeight = usableScreenBottom - usableScreenTop;

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📜 Pre-Scroll Analysis (Enhanced):');
      debugPrint(
        '   Element: top=$elementTop, bottom=$elementBottom, height=$elementHeight',
      );
      debugPrint('   Current scroll: $currentScrollOffset');
      debugPrint(
        '   Usable area: $usableScreenTop → $usableScreenBottom ($usableHeight px)',
      );
      debugPrint('   Content needs: $contentHeight px + margins');

      double scrollDelta = 0;
      String strategy = '';

      if (elementTop < usableScreenTop) {
        scrollDelta = elementTop - usableScreenTop - 40;
        strategy = 'SCROLL UP - Element too high';
        debugPrint('⬆️ $strategy');
        debugPrint('   Element at $elementTop, target at $usableScreenTop');
      } else if (elementBottom > usableScreenBottom) {
        scrollDelta = elementTop - usableScreenTop - 40;
        strategy = 'SCROLL DOWN - Element too low (CRITICAL)';
        debugPrint('⬇️ $strategy');
        debugPrint(
          '   Element bottom at $elementBottom, usable bottom at $usableScreenBottom',
        );
        debugPrint('   Required scroll: $scrollDelta px');
      } else {
        final spaceBelow =
            screenHeight - elementBottom - keyboardHeight - safeAreaBottom;
        final spaceAbove = elementTop - safeAreaTop;

        debugPrint('   Space check: below=$spaceBelow, above=$spaceAbove');

        if (spaceBelow < contentHeight + 40) {
          scrollDelta = max(
            (contentHeight + 50 - spaceBelow) * 0.7,
            elementTop - usableScreenTop - 40,
          );
          strategy = 'FINE TUNE - Creating space below';
          debugPrint('🔧 $strategy');
          debugPrint(
            '   Need ${contentHeight + 40} px, have $spaceBelow below',
          );
          debugPrint('   Calculated delta: $scrollDelta px');
        } else {
          strategy = 'NO SCROLL - Element in optimal position';
          debugPrint('✅ $strategy');
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
          debugPrint('📍 Executing scroll:');
          debugPrint('   From: $currentScrollOffset → To: $targetOffset');
          debugPrint('   Delta: ${targetOffset - currentScrollOffset}');
          debugPrint('   Bounds: min=$minScroll, max=$maxScroll');

          await scrollController.animateTo(
            targetOffset,
            duration: _timing.scrollDuration,
            curve: Curves.easeInOutCubic,
          );

          await Future.delayed(_timing.scrollSettling);

          debugPrint('✅ Scroll animation completed');
        } else {
          debugPrint('⚠️ Scroll delta too small ($actualDelta px), skipping');
        }
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in pre-scroll: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// تعليمات إضافة عملية بيع
  static Future<void> showAddTutorial({
    required BuildContext context,
    required GlobalKey invoiceNumberFieldKey,
    required GlobalKey dateFieldKey,
    required GlobalKey customerFieldKey,
    required GlobalKey qatTypeFieldKey,
    required GlobalKey unitFieldKey,
    required GlobalKey quantityFieldKey,
    required GlobalKey priceFieldKey,
    required GlobalKey paymentMethodKey,
    required GlobalKey discountFieldKey,
    required GlobalKey notesFieldKey,
    required GlobalKey saveButtonKey,
    required VoidCallback onNext,
    ScrollController? scrollController,
  }) async {
    await Future.delayed(_timing.initialDelay);

    const contentHeight = 235.0;

    await _preScroll(
      context: context,
      targetKey: invoiceNumberFieldKey,
      scrollController: scrollController,
      contentHeight: contentHeight,
    );

    final targetKeys = [
      invoiceNumberFieldKey,    // 0
      dateFieldKey,             // 1
      customerFieldKey,         // 2
      qatTypeFieldKey,          // 3
      unitFieldKey,             // 4
      quantityFieldKey,         // 5
      priceFieldKey,            // 6
      paymentMethodKey,         // 7
      discountFieldKey,         // 8
      notesFieldKey,            // 9
      saveButtonKey,            // 10
    ];

    final targets = <TargetFocus>[];

    targets.add(
      TargetFocus(
        identify: 'invoice_number_field',
        keyTarget: invoiceNumberFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        paddingFocus: 8,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: invoiceNumberFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 1,
                totalSteps: 11,
                title: 'رقم الفاتورة التلقائي',
                description:
                    'رقم تسلسلي يُولّد تلقائياً لكل عملية بيع\nيساعد في تتبع وتنظيم المبيعات بدقة',
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
        identify: 'date_field',
        keyTarget: dateFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        paddingFocus: 8,
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
                stepNumber: 2,
                totalSteps: 11,
                title: 'تاريخ البيع',
                description:
                    'حدد تاريخ عملية البيع\nيمكنك اختيار تاريخ اليوم أو تاريخ سابق',
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
        identify: 'customer_field',
        keyTarget: customerFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: customerFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 3,
                totalSteps: 11,
                title: 'اختيار العميل',
                description:
                    'حدد العميل الذي تبيع له (اختياري)\nيمكنك تخطي هذا الحقل للبيع المباشر',
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
        identify: 'qat_type_field',
        keyTarget: qatTypeFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: qatTypeFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 4,
                totalSteps: 11,
                title: 'نوع القات',
                description:
                    'اختر نوع القات المراد بيعه\nيظهر اسم النوع ودرجة جودته',
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
        identify: 'unit_field',
        keyTarget: unitFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: unitFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 5,
                totalSteps: 11,
                title: 'وحدة القياس',
                description:
                    'اختر وحدة القياس المناسبة\n(ربطة، كيس، كرتون، قطعة)',
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
        identify: 'quantity_field',
        keyTarget: quantityFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: quantityFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 6,
                totalSteps: 11,
                title: 'كمية البيع',
                description: 'أدخل الكمية المباعة\nيجب أن تكون رقم موجب',
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
        identify: 'price_field',
        keyTarget: priceFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: priceFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 7,
                totalSteps: 11,
                title: 'سعر الوحدة',
                description:
                    'أدخل سعر الوحدة الواحدة\nسيتم حساب الإجمالي تلقائياً',
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

    targets.add(
      TargetFocus(
        identify: 'payment_method_field',
        keyTarget: paymentMethodKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        paddingFocus: 10,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: paymentMethodKey,
              contentHeight: contentHeight,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 8,
                totalSteps: 11,
                title: 'طريقة الدفع',
                description:
                    'اختر طريقة الدفع المستخدمة\n(نقدي، آجل، تحويل، أو بطاقة)',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[8],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
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
        identify: 'discount_field',
        keyTarget: discountFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: discountFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 9,
                totalSteps: 11,
                title: 'الخصم',
                description:
                    'أدخل قيمة الخصم إن وجدت\nيمكنك تركه فارغاً للمتابعة بدون خصم',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[9],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[7],
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
        identify: 'notes_field',
        keyTarget: notesFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
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
                stepNumber: 10,
                totalSteps: 11,
                title: 'الملاحظات',
                description:
                    'أضف أي ملاحظات إضافية (اختياري)\nمثل تفاصيل خاصة بالعملية',
                onNext: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[10],
                    scrollController: scrollController,
                    contentHeight: contentHeight,
                  );
                  controller.next();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[8],
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
        identify: 'save_button',
        keyTarget: saveButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 11,
                totalSteps: 11,
                title: 'حفظ العملية',
                description:
                    'اضغط هنا لحفظ عملية البيع\nتأكد من دقة جميع المعلومات قبل الحفظ',
                onNext: () {
                  controller.skip();
                  onNext();
                },
                onPrevious: () async {
                  await _preScroll(
                    context: context,
                    targetKey: targetKeys[9],
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

    _tutorial!.show(context: context, rootOverlay: true);
  }

  /// تعليمات البيع السريع
  static Future<void> showQuickSaleTutorial({
    required BuildContext context,
    required GlobalKey qatTypeFieldKey,
    required GlobalKey unitFieldKey,
    required GlobalKey quantityFieldKey,
    required GlobalKey priceFieldKey,
    required GlobalKey paymentMethodKey,
    required GlobalKey notesFieldKey,
    required GlobalKey saveButtonKey,
    required VoidCallback onNext,
    ScrollController? scrollController,
  }) async {
    await Future.delayed(_timing.initialDelay);

    const contentHeight = 235.0;

    await _preScroll(
      context: context,
      targetKey: qatTypeFieldKey,
      scrollController: scrollController,
      contentHeight: contentHeight,
    );

    final targetKeys = [
      qatTypeFieldKey,      // 0
      unitFieldKey,         // 1
      quantityFieldKey,     // 2
      priceFieldKey,        // 3
      paymentMethodKey,     // 4
      notesFieldKey,        // 5
      saveButtonKey,        // 6
    ];

    final targets = <TargetFocus>[];

    targets.add(
      TargetFocus(
        identify: 'qat_type_field',
        keyTarget: qatTypeFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: qatTypeFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 1,
                totalSteps: 7,
                title: 'نوع القات',
                description:
                    'اختر نوع القات المراد بيعه\nيظهر اسم النوع ودرجة جودته',
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
        identify: 'unit_field',
        keyTarget: unitFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: unitFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 2,
                totalSteps: 7,
                title: 'وحدة القياس',
                description:
                    'اختر وحدة القياس المناسبة\n(ربطة، كيس، كرتون، قطعة)',
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
        identify: 'quantity_field',
        keyTarget: quantityFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: quantityFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 3,
                totalSteps: 7,
                title: 'كمية البيع',
                description: 'أدخل الكمية المباعة\nيجب أن تكون رقم موجب',
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
        identify: 'price_field',
        keyTarget: priceFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: priceFieldKey,
              contentHeight: contentHeight,
            ),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 4,
                totalSteps: 7,
                title: 'سعر الوحدة',
                description:
                    'أدخل سعر الوحدة الواحدة\nسيتم حساب الإجمالي تلقائياً',
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
        identify: 'payment_method_field',
        keyTarget: paymentMethodKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        paddingFocus: 10,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: _calculatePosition(
              context: context,
              targetKey: paymentMethodKey,
              contentHeight: contentHeight,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 5,
                totalSteps: 7,
                title: 'طريقة الدفع',
                description:
                    'اختر طريقة الدفع المستخدمة\n(نقدي، آجل، تحويل، أو بطاقة)',
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
        identify: 'notes_field',
        keyTarget: notesFieldKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
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
                totalSteps: 7,
                title: 'الملاحظات',
                description:
                    'أضف أي ملاحظات إضافية (اختياري)\nمثل تفاصيل خاصة بالعملية',
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
        identify: 'save_button',
        keyTarget: saveButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildStepContent(
                context: context,
                stepNumber: 7,
                totalSteps: 7,
                title: 'حفظ البيع السريع',
                description:
                    'اضغط هنا لحفظ عملية البيع\nتأكد من دقة جميع المعلومات قبل الحفظ',
                onNext: () {
                  controller.skip();
                  onNext();
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

    _tutorial!.show(context: context, rootOverlay: true);
  }

  /// بناء محتوى الخطوة بتصميم مرن وديناميكي محسّن
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
        final screenHeight = MediaQuery.of(context).size.height;
        final maxWidth = MediaQuery.of(context).size.width - 32;
        final contentWidth = maxWidth.clamp(300.0, 400.0);

        final dynamicMaxHeight = screenHeight < 700
            ? 280.0
            : screenHeight < 850
            ? 300.0
            : 320.0;

        return Container(
          width: contentWidth,
          constraints: BoxConstraints(
            minHeight: 180,
            maxHeight: dynamicMaxHeight,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.sales, AppColors.success],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'الخطوة $stepNumber من $totalSteps',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (showSkip && onSkip != null)
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        minimumSize: const Size(45, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'تخطي',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.sales.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      isLastStep
                          ? Icons.check_circle_rounded
                          : Icons.touch_app_rounded,
                      color: AppColors.sales,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onPrevious != null)
                    OutlinedButton(
                      onPressed: onPrevious,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'السابق',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sales,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLastStep ? 'إنهاء' : 'التالي',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isLastStep ? Icons.check : Icons.arrow_forward,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
