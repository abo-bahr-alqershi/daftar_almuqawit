import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// خدمة التعليمات الإرشادية التفاعلية
/// تدير عرض التعليمات باستخدام tutorial_coach_mark
class TutorialService {
  TutorialService._();
  static final TutorialService _instance = TutorialService._();
  static TutorialService get instance => _instance;

  TutorialCoachMark? _tutorialCoachMark;

  /// ألوان ثابتة لكل إدارة
  static const Map<String, Color> departmentColors = {
    'qat_types': Color(0xFF00BCD4), // لون أنواع القات
    'suppliers': AppColors.primary, // لون الموردين
    'customers': AppColors.accent, // لون العملاء
    'sales': AppColors.success, // لون المبيعات
    'purchases': AppColors.info, // لون المشتريات
    'inventory': Color(0xFF00BCD4), // لون المخزون
    'debts': AppColors.warning, // لون الديون
    'expenses': AppColors.danger, // لون المصروفات
  };

  /// بدء تعليمات أنواع القات
  void startQatTypesTutorial(BuildContext context, {
    required String operation, // 'add', 'edit', 'delete'
    required List<TargetFocus> targets,
  }) {
    final color = departmentColors['qat_types']!;
    
    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: color,
      textSkip: "تخطي",
      paddingFocus: 5,  // ✅ تقليل الحشو
      opacityShadow: 0.5, // ✅ تقليل الشفافية
      imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // ✅ تقليل التشويش
      hideSkip: false,
      useSafeArea: true,
      onFinish: () {
        _tutorialCoachMark = null;
      },
      onSkip: () {
        _tutorialCoachMark = null;
        return true;
      },
      // ✅ إزالة onClickTarget و onClickOverlay لتجنب التداخل
    );

    _tutorialCoachMark?.show(context: context);
  }

  /// إنشاء هدف تعليمي بسيط وفعال
  static TargetFocus createSimpleTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required Color color,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    bool allowInteraction = true, // ✅ معامل جديد للتحكم
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      enableOverlayTab: !allowInteraction, // ✅ عكس القيمة
      enableTargetTab: allowInteraction,   // ✅ السماح بالتفاعل حسب الحاجة
      radius: 10,
      shape: shape,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (!allowInteraction) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => controller.skip(),
                          child: const Text('تخطي'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => controller.next(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('التالي'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// إنشاء أهداف تعليمية لعمليات أنواع القات
  static List<TargetFocus> createQatTypesTargets({
    required String operation,
    required Map<String, GlobalKey> keys,
  }) {
    
    final color = departmentColors['qat_types']!;
    final List<TargetFocus> targets = [];

    switch (operation) {
      case 'add':
        targets.addAll([
          // ✅ للعناوين والمعلومات - بدون تفاعل
          createSimpleTarget(
            identify: "intro",
            keyTarget: keys['add_button']!,
            title: "مرحباً بك! 👋",
            description: "سنتعلم كيفية إضافة نوع قات جديد",
            color: color,
            allowInteraction: false, // لا حاجة للتفاعل
          ),
          
          // ✅ لحقول الإدخال - مع التفاعل
          createSimpleTarget(
            identify: "name_field",
            keyTarget: keys['name_field']!,
            title: "اسم نوع القات 📝",
            description: "اكتب الاسم هنا مباشرة (مثل: قيفي رووس)",
            color: color,
            allowInteraction: true, // ✅ السماح بالكتابة
          ),
          
          createSimpleTarget(
            identify: "price_field",
            keyTarget: keys['price_field']!,
            title: "سعر الشراء 💰",
            description: "أدخل السعر هنا مباشرة",
            color: color,
            allowInteraction: true, // ✅ السماح بالكتابة
          ),
          
          // ✅ للأزرار - مع التفاعل
          createSimpleTarget(
            identify: "save_button",
            keyTarget: keys['save_button']!,
            title: "حفظ البيانات ✅",
            description: "اضغط هنا للحفظ",
            color: color,
            allowInteraction: true, // ✅ السماح بالضغط
          ),
        ]);
        break;

      case 'edit':
        targets.addAll([
          createTarget(
            identify: "select_item",
            keyTarget: keys['select_item']!,
            title: "اختيار النوع للتعديل",
            description: "اختر نوع القات الذي تريد تعديله من القائمة. يمكنك البحث أو التمرير للعثور على النوع المطلوب.",
            color: color,
            shape: ShapeLightFocus.RRect,
            radius: 8,
          ),
          createTarget(
            identify: "edit_button",
            keyTarget: keys['edit_button']!,
            title: "زر التعديل",
            description: "اضغط على أيقونة التعديل لفتح نموذج تحرير بيانات نوع القات المحدد.",
            color: color,
            shape: ShapeLightFocus.Circle,
          ),
          createTarget(
            identify: "update_fields",
            keyTarget: keys['update_fields']!,
            title: "تحديث البيانات",
            description: "عدّل البيانات حسب الحاجة. يمكنك تغيير الاسم، السعر، أو أي تفاصيل أخرى.",
            color: color,
            shape: ShapeLightFocus.RRect,
            radius: 12,
          ),
        ]);
        break;

      case 'delete':
        targets.addAll([
          createTarget(
            identify: "select_item_delete",
            keyTarget: keys['select_item']!,
            title: "اختيار النوع للحذف",
            description: "اختر نوع القات الذي تريد حذفه من النظام. كن حذراً لأن هذا الإجراء لا يمكن التراجع عنه.",
            color: color,
            shape: ShapeLightFocus.RRect,
            radius: 8,
          ),
          createTarget(
            identify: "delete_button",
            keyTarget: keys['delete_button']!,
            title: "زر الحذف",
            description: "اضغط على أيقونة الحذف لإزالة نوع القات من النظام نهائياً.",
            color: color,
            shape: ShapeLightFocus.Circle,
          ),
          createTarget(
            identify: "confirm_dialog",
            keyTarget: keys['confirm_dialog']!,
            title: "تأكيد الحذف",
            description: "ستظهر رسالة تأكيد قبل الحذف النهائي. تأكد من اختيارك قبل المتابعة.",
            color: color,
            shape: ShapeLightFocus.RRect,
            radius: 16,
          ),
        ]);
        break;
    }

    return targets;
  }

  /// إنشاء هدف تعليمي (للتوافق مع الكود القديم)
  static TargetFocus createTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required Color color,
    ShapeLightFocus shape = ShapeLightFocus.Circle,
    double radius = 5,
  }) {
    // استخدام الدالة الجديدة مع إعدادات افتراضية
    return createSimpleTarget(
      identify: identify,
      keyTarget: keyTarget,
      title: title,
      description: description,
      color: color,
      shape: shape,
      allowInteraction: false, // افتراضي للتوافق
    );
  }

  /// إيقاف التعليمات الحالية
  void stopTutorial() {
    _tutorialCoachMark?.finish();
    _tutorialCoachMark = null;
  }


  /// التحقق من وجود تعليمات نشطة
  bool get isActive => _tutorialCoachMark != null;
}
