// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// تعريف ThemeData للتطبيق
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleTextStyle: AppTextStyles.title,
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: AppTextStyles.headline,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
      ),
    );
  }
}
