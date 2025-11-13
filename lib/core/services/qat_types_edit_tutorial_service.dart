import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

/// خدمة التعليمات المخصصة لتعديل أنواع القات
class QatTypesEditTutorialService {
  static QatTypesEditTutorialService? _instance;
  static QatTypesEditTutorialService get instance => _instance ??= QatTypesEditTutorialService._();
  QatTypesEditTutorialService._();

  TutorialCoachMark? _tutorialCoachMark;
  
  /// لون أنواع القات الثابت
  static const Color qatTypesColor = Color(0xFF00BCD4);

  /// بدء تعليمات تعديل نوع قات
  void startEditTutorial(BuildContext context, {
    required GlobalKey listKey,
    required GlobalKey editButtonKey,
    required GlobalKey updateFieldsKey,
  }) {
    final targets = _createEditTargets(
      listKey: listKey,
      editButtonKey: editButtonKey,
      updateFieldsKey: updateFieldsKey,
    );

    _showTutorial(context, targets);
  }

  /// إنشاء أهداف تعليمات التعديل
  List<TargetFocus> _createEditTargets({
    required GlobalKey listKey,
    required GlobalKey editButtonKey,
    required GlobalKey updateFieldsKey,
  }) {
    return [
      // الهدف الأول: اختيار العنصر
      _createTarget(
        identify: "select_item",
        keyTarget: listKey,
        title: "اختيار النوع للتعديل 📋",
        description: "اختر نوع القات الذي تريد تعديله من القائمة",
        isInteractive: true,
      ),
      
      // الهدف الثاني: زر التعديل
      _createTarget(
        identify: "edit_button",
        keyTarget: editButtonKey,
        title: "زر التعديل ✏️",
        description: "اضغط على أيقونة التعديل لفتح نموذج التحرير",
        isInteractive: true,
      ),
      
      // الهدف الثالث: تحديث البيانات
      _createTarget(
        identify: "update_fields",
        keyTarget: updateFieldsKey,
        title: "تحديث البيانات 📝",
        description: "عدّل البيانات حسب الحاجة ثم احفظ التغييرات",
        isInteractive: true,
      ),
    ];
  }

  /// إنشاء هدف تعليمي
  TargetFocus _createTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required bool isInteractive,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      enableOverlayTab: !isInteractive,
      enableTargetTab: isInteractive,
      radius: 8,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return _buildContent(
              title: title,
              description: description,
              controller: controller,
            );
          },
        ),
      ],
    );
  }

  /// بناء محتوى التعليمات
  Widget _buildContent({
    required String title,
    required String description,
    required TutorialCoachMarkController controller,
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
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: qatTypesColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.skip(),
                child: const Text(
                  "تخطي",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => controller.next(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: qatTypesColor,
                  foregroundColor: Colors.white,
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
