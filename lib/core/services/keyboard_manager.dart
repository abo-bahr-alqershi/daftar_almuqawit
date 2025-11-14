// keyboard_manager.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'dart:async';
import 'qat_types_tutorial_service.dart';

/// حساب موضع محتوى التعليمات الأمثل
class SmartContentPositioning {
  static ContentAlign calculateOptimalPosition({
    required BuildContext context,
    required GlobalKey targetKey,
    required bool hasKeyboard,
    required double keyboardHeight,
  }) {
    try {
      final RenderBox? renderBox =
          targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return ContentAlign.bottom;

      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetSize = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;

      // حساب المساحات المتاحة
      final spaceAboveTarget = targetPosition.dy;
      final spaceBelowTarget =
          screenHeight - (targetPosition.dy + targetSize.height);

      // المساحة المطلوبة للمحتوى (تقديرياً)
      const contentHeight = 250.0;
      const keyboardClearance = 50.0; // مساحة إضافية فوق لوحة المفاتيح

      if (hasKeyboard && keyboardHeight > 0) {
        // مع لوحة المفاتيح
        final availableSpaceBelow =
            spaceBelowTarget - keyboardHeight - keyboardClearance;
        final availableSpaceAbove =
            spaceAboveTarget - 100; // ترك مساحة للـ app bar

        // إذا كانت المساحة أسفل الحقل كافية
        if (availableSpaceBelow >= contentHeight) {
          return ContentAlign.bottom;
        }
        // إذا كانت المساحة أعلى الحقل كافية
        else if (availableSpaceAbove >= contentHeight) {
          return ContentAlign.top;
        }
        // إذا لم تكن هناك مساحة كافية، ضع المحتوى في أفضل مكان ممكن
        else {
          return availableSpaceAbove > availableSpaceBelow
              ? ContentAlign.top
              : ContentAlign.bottom;
        }
      } else {
        // بدون لوحة مفاتيح - استخدم الموضع الافتراضي
        if (spaceBelowTarget >= contentHeight + 100) {
          return ContentAlign.bottom;
        } else if (spaceAboveTarget >= contentHeight + 100) {
          return ContentAlign.top;
        } else {
          // إذا كان الحقل في منتصف الشاشة
          return spaceBelowTarget > spaceAboveTarget
              ? ContentAlign.bottom
              : ContentAlign.top;
        }
      }
    } catch (e) {
      debugPrint('Error calculating position: $e');
      return ContentAlign.bottom;
    }
  }
}

/// مدير لوحة المفاتيح والتمرير المحسن
class EnhancedKeyboardScrollManager {
  static final EnhancedKeyboardScrollManager _instance =
      EnhancedKeyboardScrollManager._internal();
  factory EnhancedKeyboardScrollManager() => _instance;
  EnhancedKeyboardScrollManager._internal();

  Timer? _scrollAdjustTimer;

  /// تمرير ذكي يضمن رؤية الحقل ومحتوى التعليمات
  static Future<void> smartScrollForFieldAndContent({
    required BuildContext context,
    required GlobalKey targetKey,
    required ScrollController? scrollController,
    required ContentAlign contentPosition,
    required bool hasKeyboard,
    required double keyboardHeight,
  }) async {
    if (!context.mounted ||
        scrollController == null ||
        !scrollController.hasClients) {
      return;
    }

    try {
      final RenderBox? renderBox =
          targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetSize = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;
      final safeAreaTop = MediaQuery.of(context).padding.top;

      // حساب المساحة المطلوبة
      const contentHeight = 250.0; // ارتفاع محتوى التعليمات التقديري
      const fieldClearance = 20.0; // مساحة حول الحقل

      double targetScrollOffset = scrollController.offset;

      if (hasKeyboard) {
        // حساب المنطقة المرئية مع لوحة المفاتيح
        final visibleAreaTop = safeAreaTop + 50;
        final visibleAreaBottom = screenHeight - keyboardHeight - 50;
        final visibleAreaHeight = visibleAreaBottom - visibleAreaTop;

        if (contentPosition == ContentAlign.top) {
          // المحتوى فوق الحقل
          // نحتاج لرؤية: المحتوى + الحقل
          final requiredTop =
              targetPosition.dy - contentHeight - fieldClearance;
          final requiredBottom =
              targetPosition.dy + targetSize.height + fieldClearance;

          if (requiredTop < visibleAreaTop) {
            // نحتاج للتمرير لأعلى
            targetScrollOffset =
                scrollController.offset - (visibleAreaTop - requiredTop);
          } else if (requiredBottom > visibleAreaBottom) {
            // نحتاج للتمرير لأسفل
            targetScrollOffset =
                scrollController.offset + (requiredBottom - visibleAreaBottom);
          }
        } else {
          // المحتوى تحت الحقل
          // نحتاج لرؤية: الحقل + المحتوى
          final requiredTop = targetPosition.dy - fieldClearance;
          final requiredBottom =
              targetPosition.dy +
              targetSize.height +
              contentHeight +
              fieldClearance;

          // التأكد من أن الحقل والمحتوى مرئيان
          if (requiredBottom > visibleAreaBottom) {
            // حاول التمرير لإظهار كل شيء
            final scrollNeeded = requiredBottom - visibleAreaBottom;
            targetScrollOffset = scrollController.offset + scrollNeeded;

            // تحقق من أن الحقل لن يختفي من الأعلى
            final newFieldTop = targetPosition.dy - scrollNeeded;
            if (newFieldTop < visibleAreaTop) {
              // الحقل سيختفي، اضبط التمرير ليكون الحقل في الأعلى
              targetScrollOffset =
                  scrollController.offset -
                  (visibleAreaTop - targetPosition.dy) +
                  fieldClearance;
            }
          } else if (requiredTop < visibleAreaTop) {
            // الحقل مخفي في الأعلى
            targetScrollOffset =
                scrollController.offset - (visibleAreaTop - requiredTop);
          }
        }
      } else {
        // بدون لوحة مفاتيح - تمرير عادي
        const idealViewportPosition = 0.3; // موضع الحقل المثالي (30% من الأعلى)
        final idealFieldPosition = screenHeight * idealViewportPosition;
        final currentFieldPosition = targetPosition.dy;

        if ((currentFieldPosition - idealFieldPosition).abs() > 50) {
          targetScrollOffset =
              scrollController.offset +
              (currentFieldPosition - idealFieldPosition);
        }
      }

      // التأكد من أن التمرير ضمن الحدود
      targetScrollOffset = targetScrollOffset.clamp(
        scrollController.position.minScrollExtent,
        scrollController.position.maxScrollExtent,
      );

      // التمرير إذا لزم الأمر
      if ((targetScrollOffset - scrollController.offset).abs() > 5) {
        await scrollController.animateTo(
          targetScrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint('Error in smartScrollForFieldAndContent: $e');
    }
  }
}
