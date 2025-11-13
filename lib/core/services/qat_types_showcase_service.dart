import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

/// خدمة التعليمات المحسّنة باستخدام TutorialCoachMark
/// تسمح بالتفاعل الكامل مع الحقول أثناء عرض التعليمات
class QatTypesShowcaseService {
  static QatTypesShowcaseService? _instance;
  static QatTypesShowcaseService get instance =>
      _instance ??= QatTypesShowcaseService._();
  QatTypesShowcaseService._();

  /// لون أنواع القات الثابت
  static const Color qatTypesColor = Color(0xFF00BCD4);

  TutorialCoachMark? _tutorialCoachMark;

  /// بدء تعليمات إضافة نوع قات جديد
  void startAddTutorial(
    BuildContext context, {
    required GlobalKey nameFieldKey,
    required GlobalKey priceFieldKey,
    required GlobalKey saveButtonKey,
  }) {
    // استخدام PostFrameCallback لضمان أن جميع العناصر جاهزة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // تأخير إضافي بسيط لضمان اكتمال البناء
      Future.delayed(const Duration(milliseconds: 300), () {
        if (nameFieldKey.currentContext != null &&
            priceFieldKey.currentContext != null &&
            saveButtonKey.currentContext != null) {
          final targets = _createAddTargets(
            nameFieldKey: nameFieldKey,
            priceFieldKey: priceFieldKey,
            saveButtonKey: saveButtonKey,
          );

          _tutorialCoachMark = TutorialCoachMark(
            targets: targets,
            colorShadow: qatTypesColor,
            textSkip: "تخطي",
            paddingFocus: 8,
            opacityShadow: 0.8,
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            onFinish: () {
              debugPrint('✅ تم إنهاء التعليمات بنجاح');
            },
            onSkip: () {
              debugPrint('⏭️ تم تخطي التعليمات');
              return true;
            },
          );

          _tutorialCoachMark?.show(context: context);
          debugPrint('✅ تم بدء التعليمات بنجاح');
        } else {
          debugPrint('⚠️ بعض المفاتيح غير مرتبطة بالعناصر بعد');
        }
      });
    });
  }

  /// إنشاء أهداف التعليمات
  List<TargetFocus> _createAddTargets({
    required GlobalKey nameFieldKey,
    required GlobalKey priceFieldKey,
    required GlobalKey saveButtonKey,
  }) {
    return [
      // الهدف 1: حقل الاسم
      TargetFocus(
        identify: "nameField",
        keyTarget: nameFieldKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: 'حقل اسم نوع القات 📝',
                description:
                    'اكتب هنا اسم نوع القات\n(مثال: قيفي رووس، عنسي عوارض)',
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
                isLast: false,
              );
            },
          ),
        ],
      ),

      // الهدف 2: حقل السعر
      TargetFocus(
        identify: "priceField",
        keyTarget: priceFieldKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: 'حقل سعر الشراء 💰',
                description: 'أدخل سعر شراء هذا النوع\n(مثال: 1500، 2000)',
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
                isLast: false,
              );
            },
          ),
        ],
      ),

      // الهدف 3: زر الحفظ
      TargetFocus(
        identify: "saveButton",
        keyTarget: saveButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                title: 'زر الحفظ ✅',
                description:
                    'بعد إدخال البيانات، انقر هنا لحفظ نوع القات الجديد',
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
                isLast: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// بناء محتوى التعليمات
  Widget _buildTutorialContent({
    required String title,
    required String description,
    required VoidCallback onNext,
    required VoidCallback onSkip,
    required bool isLast,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // العنوان
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: qatTypesColor,
            ),
          ),
          const SizedBox(height: 12),

          // الوصف
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // الأزرار
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onSkip,
                child: const Text(
                  'تخطي',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: qatTypesColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isLast ? 'إنهاء' : 'التالي'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// إيقاف التعليمات
  void stopTutorial() {
    _tutorialCoachMark?.finish();
    _tutorialCoachMark = null;
  }
}
