import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ظلال جاهزة للاستخدام في التطبيق
/// 
/// يوفر مجموعة من الظلال المعرفة مسبقاً لضمان تناسق التصميم
class AppShadows {
  AppShadows._();

  // ========== ظلال البطاقات ==========

  /// ظل خفيف للبطاقات
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// ظل متوسط للبطاقات
  static const List<BoxShadow> cardMedium = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// ظل قوي للبطاقات
  static const List<BoxShadow> cardStrong = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  /// ظل البطاقة الافتراضي (للتوافق)
  static const List<BoxShadow> card = cardMedium;

  // ========== ظلال الأزرار ==========

  /// ظل الزر العادي
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// ظل الزر عند الضغط
  static const List<BoxShadow> buttonPressed = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// ظل الزر المرتفع
  static const List<BoxShadow> buttonElevated = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // ========== ظلال القوائم المنبثقة ==========

  /// ظل القائمة المنبثقة
  static const List<BoxShadow> dropdown = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// ظل الحوار
  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 24,
      offset: Offset(0, 11),
      spreadRadius: 0,
    ),
  ];

  /// ظل القائمة السفلية
  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 20,
      offset: Offset(0, -4),
      spreadRadius: 0,
    ),
  ];

  // ========== ظلال خاصة ==========

  /// ظل الشريط العلوي
  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// ظل شريط التنقل السفلي
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, -2),
      spreadRadius: 0,
    ),
  ];

  /// ظل الزر العائم
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  // ========== ظلال ملونة ==========

  /// ظل أخضر (للنجاح)
  static List<BoxShadow> get success => [
        BoxShadow(
          color: AppColors.success.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// ظل أحمر (للخطر)
  static List<BoxShadow> get danger => [
        BoxShadow(
          color: AppColors.danger.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// ظل برتقالي (للتحذير)
  static List<BoxShadow> get warning => [
        BoxShadow(
          color: AppColors.warning.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// ظل أزرق (للمعلومات)
  static List<BoxShadow> get info => [
        BoxShadow(
          color: AppColors.info.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// ظل أخضر أساسي
  static List<BoxShadow> get primary => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  // ========== ظلال الوضع الليلي ==========

  /// ظل خفيف للوضع الليلي
  static const List<BoxShadow> darkLight = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// ظل متوسط للوضع الليلي
  static const List<BoxShadow> darkMedium = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// ظل قوي للوضع الليلي
  static const List<BoxShadow> darkStrong = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}
