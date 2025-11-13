import 'package:flutter/material.dart';
import 'qat_types_tutorial_service.dart';
import 'qat_types_edit_tutorial_service.dart';
import 'qat_types_delete_tutorial_service.dart';

/// مدير التعليمات الرئيسي لأنواع القات
/// يدير جميع أنواع التعليمات (إضافة، تعديل، حذف)
class QatTypesTutorialManager {
  static QatTypesTutorialManager? _instance;
  static QatTypesTutorialManager get instance => _instance ??= QatTypesTutorialManager._();
  QatTypesTutorialManager._();

  /// بدء التعليمات حسب نوع العملية
  void startTutorial(
    BuildContext context, {
    required String operation,
    required Map<String, GlobalKey> keys,
  }) {
    switch (operation) {
      case 'add':
        _startAddTutorial(context, keys);
        break;
      case 'edit':
        _startEditTutorial(context, keys);
        break;
      case 'delete':
        _startDeleteTutorial(context, keys);
        break;
      default:
        debugPrint('⚠️ نوع عملية غير مدعوم: $operation');
    }
  }

  /// بدء تعليمات الإضافة
  void _startAddTutorial(BuildContext context, Map<String, GlobalKey> keys) {
    final formContainerKey = keys['add_button'] ?? keys['form_container'];
    final nameFieldKey = keys['name_field'];
    final priceFieldKey = keys['price_field'];
    final saveButtonKey = keys['save_button'];

    if (formContainerKey != null && 
        nameFieldKey != null && 
        priceFieldKey != null && 
        saveButtonKey != null) {
      
      QatTypesTutorialService.instance.startAddTutorial(
        context,
        formContainerKey: formContainerKey,
        nameFieldKey: nameFieldKey,
        priceFieldKey: priceFieldKey,
        saveButtonKey: saveButtonKey,
      );
    } else {
      debugPrint('⚠️ مفاتيح تعليمات الإضافة غير مكتملة');
      _logMissingKeys('add', keys);
    }
  }

  /// بدء تعليمات التعديل
  void _startEditTutorial(BuildContext context, Map<String, GlobalKey> keys) {
    final listKey = keys['select_item'] ?? keys['list'];
    final editButtonKey = keys['edit_button'];
    final updateFieldsKey = keys['update_fields'] ?? keys['form_container'];

    if (listKey != null && editButtonKey != null && updateFieldsKey != null) {
      QatTypesEditTutorialService.instance.startEditTutorial(
        context,
        listKey: listKey,
        editButtonKey: editButtonKey,
        updateFieldsKey: updateFieldsKey,
      );
    } else {
      debugPrint('⚠️ مفاتيح تعليمات التعديل غير مكتملة');
      _logMissingKeys('edit', keys);
    }
  }

  /// بدء تعليمات الحذف
  void _startDeleteTutorial(BuildContext context, Map<String, GlobalKey> keys) {
    final listKey = keys['select_item'] ?? keys['list'];
    final deleteButtonKey = keys['delete_button'];
    final confirmDialogKey = keys['confirm_dialog'];

    if (listKey != null && deleteButtonKey != null && confirmDialogKey != null) {
      QatTypesDeleteTutorialService.instance.startDeleteTutorial(
        context,
        listKey: listKey,
        deleteButtonKey: deleteButtonKey,
        confirmDialogKey: confirmDialogKey,
      );
    } else {
      debugPrint('⚠️ مفاتيح تعليمات الحذف غير مكتملة');
      _logMissingKeys('delete', keys);
    }
  }

  /// تسجيل المفاتيح المفقودة للتصحيح
  void _logMissingKeys(String operation, Map<String, GlobalKey> keys) {
    debugPrint('🔍 المفاتيح المتوفرة لعملية $operation:');
    keys.forEach((key, value) {
      final hasContext = value.currentContext != null;
      debugPrint('  - $key: ${hasContext ? "✅" : "❌"} ${hasContext ? "متوفر" : "غير متوفر"}');
    });
  }

  /// إيقاف جميع التعليمات النشطة
  void stopAllTutorials() {
    QatTypesTutorialService.instance.stopTutorial();
    QatTypesEditTutorialService.instance.stopTutorial();
    QatTypesDeleteTutorialService.instance.stopTutorial();
  }

  /// التحقق من وجود تعليمات نشطة
  bool get hasActiveTutorial {
    return QatTypesTutorialService.instance.isActive ||
           QatTypesEditTutorialService.instance.isActive ||
           QatTypesDeleteTutorialService.instance.isActive;
  }

  /// الحصول على نوع التعليمات النشطة
  String? get activeTutorialType {
    if (QatTypesTutorialService.instance.isActive) return 'add';
    if (QatTypesEditTutorialService.instance.isActive) return 'edit';
    if (QatTypesDeleteTutorialService.instance.isActive) return 'delete';
    return null;
  }
}
