import 'package:flutter/material.dart';

/// لوحة الألوان المستخدمة في التطبيق
/// 
/// تحتوي على جميع الألوان الأساسية والثانوية المستخدمة
/// في واجهة المستخدم مع دعم الوضع الليلي والنهاري
class AppColors {
  AppColors._();

  // ========== الألوان الأساسية ==========
  
  /// اللون الأساسي للتطبيق (أخضر القات)
  static const Color primary = Color(0xFF2E7D32);
  
  /// نسخة داكنة من اللون الأساسي
  static const Color primaryDark = Color(0xFF1B5E20);
  
  /// نسخة فاتحة من اللون الأساسي
  static const Color primaryLight = Color(0xFF4CAF50);
  
  /// اللون الثانوي (اللون المميز)
  static const Color accent = Color(0xFF8BC34A);
  
  /// نسخة داكنة من اللون الثانوي
  static const Color accentDark = Color(0xFF689F38);

  // ========== ألوان الخلفيات ==========
  
  /// خلفية التطبيق الرئيسية
  static const Color background = Color(0xFFF7F9FB);
  
  /// خلفية البطاقات والأسطح
  static const Color surface = Colors.white;
  
  /// خلفية ثانوية
  static const Color backgroundSecondary = Color(0xFFECEFF1);
  
  /// خلفية الحاويات
  static const Color container = Color(0xFFFFFFFF);

  // ========== ألوان النصوص ==========
  
  /// لون النص الأساسي
  static const Color textPrimary = Color(0xFF0F172A);
  
  /// لون النص الثانوي
  static const Color textSecondary = Color(0xFF475569);
  
  /// لون النص الباهت
  static const Color textTertiary = Color(0xFF94A3B8);
  
  /// لون النص على الخلفية الداكنة
  static const Color textOnDark = Color(0xFFFFFFFF);
  
  /// لون النص المعطل
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ========== ألوان الحالات ==========
  
  /// لون الخطأ/الخطر
  static const Color danger = Color(0xFFD32F2F);
  
  /// نسخة فاتحة من لون الخطر
  static const Color dangerLight = Color(0xFFFFEBEE);
  
  /// لون التحذير
  static const Color warning = Color(0xFFF57C00);
  
  /// نسخة فاتحة من لون التحذير
  static const Color warningLight = Color(0xFFFFF3E0);
  
  /// لون النجاح
  static const Color success = Color(0xFF2E7D32);
  
  /// نسخة فاتحة من لون النجاح
  static const Color successLight = Color(0xFFE8F5E9);
  
  /// لون المعلومات
  static const Color info = Color(0xFF0288D1);
  
  /// نسخة فاتحة من لون المعلومات
  static const Color infoLight = Color(0xFFE1F5FE);

  // ========== ألوان الحدود والفواصل ==========
  
  /// لون الحدود
  static const Color border = Color(0xFFE2E8F0);
  
  /// لون الفواصل
  static const Color divider = Color(0xFFE2E8F0);
  
  /// لون الظل
  static const Color shadow = Color(0x1A000000);

  // ========== ألوان خاصة بالتطبيق ==========
  
  /// لون الدين (أحمر)
  static const Color debt = Color(0xFFE53935);
  
  /// لون الربح (أخضر)
  static const Color profit = Color(0xFF43A047);
  
  /// لون المصروفات (برتقالي)
  static const Color expense = Color(0xFFFF6F00);
  
  /// لون المبيعات (أزرق)
  static const Color sales = Color(0xFF1E88E5);
  
  /// لون المشتريات (بنفسجي)
  static const Color purchases = Color(0xFF8E24AA);

  // ========== ألوان الوضع الليلي ==========
  
  /// خلفية الوضع الليلي
  static const Color darkBackground = Color(0xFF0F172A);
  
  /// سطح الوضع الليلي
  static const Color darkSurface = Color(0xFF1E293B);
  
  /// لون النص في الوضع الليلي
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  
  /// لون النص الثانوي في الوضع الليلي
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  // ========== تدرجات لونية ==========
  
  /// تدرج لوني أساسي
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// تدرج لوني للنجاح
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// تدرج لوني للخطر
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [danger, Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
