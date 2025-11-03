import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// تعريف ThemeData للتطبيق
/// 
/// يوفر ثيمات كاملة للوضع النهاري والليلي مع تخصيص شامل
/// لجميع مكونات Material Design
class AppTheme {
  AppTheme._();

  // ========== الثيم النهاري ==========

  /// ثيم الوضع النهاري
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // نظام الألوان
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnDark,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.textPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnDark,
        secondaryContainer: AppColors.accentDark,
        onSecondaryContainer: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.textOnDark,
        errorContainer: AppColors.dangerLight,
        onErrorContainer: AppColors.danger,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.backgroundSecondary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        shadow: AppColors.shadow,
      ),

      // الخلفية
      scaffoldBackgroundColor: AppColors.background,

      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconM,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // البطاقات
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppDimensions.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        margin: const EdgeInsets.all(AppDimensions.marginS),
      ),

      // الأزرار المرتفعة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          elevation: AppDimensions.elevationLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, AppDimensions.buttonHeightM),
        ),
      ),

      // الأزرار المحددة
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderMedium,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, AppDimensions.buttonHeightM),
        ),
      ),

      // الأزرار النصية
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: AppDimensions.borderMedium,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.inputHint,
        errorStyle: AppTextStyles.error,
      ),

      // الأيقونات
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppDimensions.iconM,
      ),

      // الفواصل
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: AppDimensions.borderThin,
        space: AppDimensions.spaceM,
      ),

      // الحوارات
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppDimensions.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        titleTextStyle: AppTextStyles.headlineMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // القوائم السفلية
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppDimensions.elevationHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusL),
          ),
        ),
      ),

      // شريط التنقل السفلي
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        elevation: AppDimensions.elevationMedium,
        type: BottomNavigationBarType.fixed,
      ),

      // الزر العائم
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnDark,
        elevation: AppDimensions.elevationMedium,
      ),

      // مفاتيح التبديل
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.border;
        }),
      ),

      // مربعات الاختيار
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.textOnDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        ),
      ),

      // أزرار الراديو
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
      ),

      // النصوص
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  // ========== الثيم الليلي ==========

  /// ثيم الوضع الليلي
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // نظام الألوان
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.textPrimary,
        primaryContainer: AppColors.primary,
        onPrimaryContainer: AppColors.textOnDark,
        secondary: AppColors.accent,
        onSecondary: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.textOnDark,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkTextPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.border,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      // يمكن إضافة المزيد من التخصيصات للوضع الليلي هنا
    );
  }
}
