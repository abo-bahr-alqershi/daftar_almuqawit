import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// أنماط النصوص المستخدمة في التطبيق
/// 
/// يوفر مجموعة شاملة من أنماط النصوص باستخدام خط Cairo
/// مع دعم كامل للغة العربية وأحجام متنوعة
class AppTextStyles {
  AppTextStyles._();

  // الخط الأساسي
  static const String _fontFamily = 'Cairo';

  // ========== العناوين الرئيسية ==========

  /// عنوان كبير جداً (Display)
  static TextStyle get displayLarge => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: -0.5,
      );

  /// عنوان كبير
  static TextStyle get displayMedium => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// عنوان صغير
  static TextStyle get displaySmall => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ========== العناوين ==========

  /// عنوان رئيسي كبير
  static TextStyle get headlineLarge => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// عنوان رئيسي متوسط
  static TextStyle get headlineMedium => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// عنوان رئيسي صغير
  static TextStyle get headlineSmall => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // ========== العناوين الفرعية ==========

  /// عنوان كبير
  static TextStyle get titleLarge => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// عنوان متوسط
  static TextStyle get titleMedium => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// عنوان صغير
  static TextStyle get titleSmall => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ========== النصوص الأساسية ==========

  /// نص كبير
  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  /// نص متوسط
  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  /// نص صغير
  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // ========== التسميات التوضيحية ==========

  /// تسمية كبيرة
  static TextStyle get labelLarge => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: 0.1,
      );

  /// تسمية متوسطة
  static TextStyle get labelMedium => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: 0.1,
      );

  /// تسمية صغيرة
  static TextStyle get labelSmall => GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.3,
        letterSpacing: 0.1,
      );

  // ========== أنماط خاصة ==========

  /// نص الأزرار
  static TextStyle get button => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
        height: 1.2,
        letterSpacing: 0.2,
      );

  /// نص الأزرار الصغيرة
  static TextStyle get buttonSmall => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
        height: 1.2,
        letterSpacing: 0.2,
      );

  /// نص حقول الإدخال
  static TextStyle get input => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// نص التلميحات في حقول الإدخال
  static TextStyle get inputHint => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  /// نص رسائل الخطأ
  static TextStyle get error => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.danger,
        height: 1.3,
      );

  /// نص التوضيحات
  static TextStyle get caption => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  /// نص صغير جداً
  static TextStyle get overline => GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        height: 1.3,
        letterSpacing: 0.5,
      );

  // ========== أنماط الأرقام ==========

  /// أرقام كبيرة (للإحصائيات)
  static TextStyle get numberLarge => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  /// أرقام متوسطة
  static TextStyle get numberMedium => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  /// أرقام صغيرة
  static TextStyle get numberSmall => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  // ========== أنماط المبالغ المالية ==========

  /// مبلغ مالي كبير
  static TextStyle get currencyLarge => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  /// مبلغ مالي متوسط
  static TextStyle get currencyMedium => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  /// مبلغ مالي صغير
  static TextStyle get currencySmall => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  // ========== أنماط الحالات ==========

  /// نص النجاح
  static TextStyle get success => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.success,
        height: 1.3,
      );

  /// نص التحذير
  static TextStyle get warning => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.warning,
        height: 1.3,
      );

  /// نص الخطر
  static TextStyle get danger => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.danger,
        height: 1.3,
      );

  /// نص المعلومات
  static TextStyle get info => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.info,
        height: 1.3,
      );

  // ========== أنماط خاصة بالتطبيق ==========

  /// نص الدين
  static TextStyle get debt => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.debt,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  /// نص الربح
  static TextStyle get profit => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.profit,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  // ========== أنماط قديمة للتوافق ==========

  /// عنوان رئيسي (للتوافق مع الكود القديم)
  static TextStyle get headline => headlineLarge;

  /// عنوان (للتوافق مع الكود القديم)
  static TextStyle get title => titleLarge;

  /// عنوان فرعي (للتوافق مع الكود القديم)
  static TextStyle get subtitle => titleMedium;

  /// نص عادي (للتوافق مع الكود القديم)
  static TextStyle get body => bodyMedium;

  /// عنوان H1 (للتوافق)
  static TextStyle get h1 => displayLarge;

  /// عنوان H2 (للتوافق)
  static TextStyle get h2 => displayMedium;

  /// عنوان H3 (للتوافق)
  static TextStyle get h3 => displaySmall;
}
