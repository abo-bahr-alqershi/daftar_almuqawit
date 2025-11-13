import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

/// خدمة التعليمات المخصصة لعمليات أنواع القات
/// تم تصميمها بدقة عالية لضمان التفاعل السليم
class QatTypesTutorialService {
  static QatTypesTutorialService? _instance;
  static QatTypesTutorialService get instance =>
      _instance ??= QatTypesTutorialService._();
  QatTypesTutorialService._();

  TutorialCoachMark? _tutorialCoachMark;

  /// لون أنواع القات الثابت
  static const Color qatTypesColor = Color(0xFF00BCD4);

  /// بدء تعليمات إضافة نوع قات جديد
  void startAddTutorial(
    BuildContext context, {
    required GlobalKey formContainerKey,
    required GlobalKey nameFieldKey,
    required GlobalKey priceFieldKey,
    required GlobalKey saveButtonKey,
  }) {
    final targets = _createAddTargets(
      formContainerKey: formContainerKey,
      nameFieldKey: nameFieldKey,
      priceFieldKey: priceFieldKey,
      saveButtonKey: saveButtonKey,
    );

    _showTutorial(context, targets);
  }

  /// إنشاء أهداف تعليمات الإضافة
  List<TargetFocus> _createAddTargets({
    required GlobalKey formContainerKey,
    required GlobalKey nameFieldKey,
    required GlobalKey priceFieldKey,
    required GlobalKey saveButtonKey,
  }) {
    return [
      // الهدف الأول: مقدمة
      _createIntroTarget(formContainerKey),

      // الهدف الثاني: حقل الاسم - تفاعلي
      _createInteractiveTarget(
        identify: "name_field",
        keyTarget: nameFieldKey,
        title: "حقل اسم نوع القات 📝",
        description:
            "انقر هنا واكتب اسم نوع القات\n(مثال: قيفي رووس، عنسي عوارض)",
        isInteractive: true,
      ),

      // الهدف الثالث: حقل السعر - تفاعلي
      _createInteractiveTarget(
        identify: "price_field",
        keyTarget: priceFieldKey,
        title: "حقل سعر الشراء 💰",
        description: "انقر هنا وأدخل سعر شراء هذا النوع\n(مثال: 1500، 2000)",
        isInteractive: true,
      ),

      // الهدف الرابع: زر الحفظ - تفاعلي
      _createInteractiveTarget(
        identify: "save_button",
        keyTarget: saveButtonKey,
        title: "زر الحفظ ✅",
        description: "انقر هنا لحفظ نوع القات الجديد في النظام",
        isInteractive: true,
      ),
    ];
  }

  /// إنشاء هدف المقدمة (غير تفاعلي)
  TargetFocus _createIntroTarget(GlobalKey keyTarget) {
    return TargetFocus(
      identify: "intro",
      keyTarget: keyTarget,
      enableOverlayTab: true, // السماح بالنقر على الخلفية
      enableTargetTab: false, // منع النقر على العنصر
      radius: 15,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return _buildIntroContent(controller);
          },
        ),
      ],
    );
  }

  /// إنشاء هدف تفاعلي
  TargetFocus _createInteractiveTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required bool isInteractive,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      enableOverlayTab: false, // منع النقر على الخلفية للعناصر التفاعلية
      enableTargetTab: true, // السماح بالنقر على العنصر
      radius: 8,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return _buildInteractiveContent(
              title: title,
              description: description,
              controller: controller,
              isInteractive: isInteractive,
            );
          },
        ),
      ],
    );
  }

  /// بناء محتوى المقدمة
  Widget _buildIntroContent(TutorialCoachMarkController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة الترحيب
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: qatTypesColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waving_hand,
              color: qatTypesColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // العنوان
          const Text(
            "مرحباً بك في وضع التعلم! 👋",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: qatTypesColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // الوصف
          const Text(
            "سنتعلم معاً كيفية إضافة نوع قات جديد خطوة بخطوة.\nستتمكن من التفاعل مع الحقول مباشرة!",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // زر البدء
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.next(),
              style: ElevatedButton.styleFrom(
                backgroundColor: qatTypesColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "ابدأ التعلم",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // زر التخطي
          TextButton(
            onPressed: () => controller.skip(),
            child: const Text(
              "تخطي التعليمات",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء محتوى تفاعلي
  Widget _buildInteractiveContent({
    required String title,
    required String description,
    required TutorialCoachMarkController controller,
    required bool isInteractive,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: qatTypesColor,
            ),
          ),
          const SizedBox(height: 8),

          // الوصف
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // تعليمات التفاعل
          if (isInteractive) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "يمكنك التفاعل مع هذا العنصر مباشرة!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // أزرار التحكم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.skip(),
                child: const Text(
                  "تخطي",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () => controller.next(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: qatTypesColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("التالي"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// عرض التعليمات
  void _showTutorial(BuildContext context, List<TargetFocus> targets) {
    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: qatTypesColor,
      textSkip: "تخطي",
      paddingFocus: 8,
      opacityShadow: 0.6,
      imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      hideSkip: false,
      useSafeArea: true,
      onFinish: () {
        _tutorialCoachMark = null;
      },
      onSkip: () {
        _tutorialCoachMark = null;
        return true;
      },
    );

    _tutorialCoachMark?.show(context: context);
  }

  /// إيقاف التعليمات
  void stopTutorial() {
    _tutorialCoachMark?.finish();
    _tutorialCoachMark = null;
  }

  /// التحقق من وجود تعليمات نشطة
  bool get isActive => _tutorialCoachMark != null;
}
