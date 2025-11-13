import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';

/// خدمة التعليمات المخصصة لحذف أنواع القات
class QatTypesDeleteTutorialService {
  static QatTypesDeleteTutorialService? _instance;
  static QatTypesDeleteTutorialService get instance => _instance ??= QatTypesDeleteTutorialService._();
  QatTypesDeleteTutorialService._();

  TutorialCoachMark? _tutorialCoachMark;
  
  /// لون أنواع القات الثابت
  static const Color qatTypesColor = Color(0xFF00BCD4);

  /// بدء تعليمات حذف نوع قات
  void startDeleteTutorial(BuildContext context, {
    required GlobalKey listKey,
    required GlobalKey deleteButtonKey,
    required GlobalKey confirmDialogKey,
  }) {
    final targets = _createDeleteTargets(
      listKey: listKey,
      deleteButtonKey: deleteButtonKey,
      confirmDialogKey: confirmDialogKey,
    );

    _showTutorial(context, targets);
  }

  /// إنشاء أهداف تعليمات الحذف
  List<TargetFocus> _createDeleteTargets({
    required GlobalKey listKey,
    required GlobalKey deleteButtonKey,
    required GlobalKey confirmDialogKey,
  }) {
    return [
      // الهدف الأول: اختيار العنصر للحذف
      _createTarget(
        identify: "select_item_delete",
        keyTarget: listKey,
        title: "اختيار النوع للحذف ⚠️",
        description: "اختر نوع القات الذي تريد حذفه من النظام\nكن حذراً - هذا الإجراء لا يمكن التراجع عنه",
        isInteractive: true,
      ),
      
      // الهدف الثاني: زر الحذف
      _createTarget(
        identify: "delete_button",
        keyTarget: deleteButtonKey,
        title: "زر الحذف 🗑️",
        description: "اضغط على أيقونة الحذف لإزالة النوع من النظام",
        isInteractive: true,
      ),
      
      // الهدف الثالث: تأكيد الحذف
      _createTarget(
        identify: "confirm_dialog",
        keyTarget: confirmDialogKey,
        title: "تأكيد الحذف ✅",
        description: "ستظهر رسالة تأكيد قبل الحذف النهائي\nتأكد من اختيارك قبل المتابعة",
        isInteractive: false,
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
              isWarning: identify.contains('delete'),
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
    bool isWarning = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isWarning ? Border.all(color: Colors.red.withOpacity(0.3), width: 2) : null,
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
          if (isWarning) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "تحذير: عملية حذف",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.red : qatTypesColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
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
                  backgroundColor: isWarning ? Colors.red : qatTypesColor,
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
      colorShadow: Colors.red, // لون تحذيري للحذف
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
