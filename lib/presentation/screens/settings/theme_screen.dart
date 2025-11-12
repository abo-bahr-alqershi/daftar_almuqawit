import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// شاشة اختيار المظهر - تصميم راقي هادئ
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  ThemeMode _selectedThemeMode = ThemeMode.light;

  final List<ThemeOption> _themeOptions = [
    ThemeOption(
      mode: ThemeMode.light,
      title: 'الوضع الفاتح',
      description: 'مظهر فاتح يناسب الاستخدام النهاري',
      icon: Icons.light_mode_rounded,
      iconColor: AppColors.warning,
    ),
    ThemeOption(
      mode: ThemeMode.dark,
      title: 'الوضع الداكن',
      description: 'مظهر داكن مريح للعين ويوفر الطاقة',
      icon: Icons.dark_mode_rounded,
      iconColor: AppColors.primary,
    ),
    ThemeOption(
      mode: ThemeMode.system,
      title: 'تلقائي',
      description: 'يتبع إعدادات النظام',
      icon: Icons.brightness_auto_rounded,
      iconColor: AppColors.info,
    ),
  ];

  void _changeTheme(ThemeMode themeMode) {
    if (_selectedThemeMode == themeMode) return;

    setState(() => _selectedThemeMode = themeMode);
    HapticFeedback.lightImpact();

    String message;
    switch (themeMode) {
      case ThemeMode.light:
        message = 'تم التبديل إلى الوضع الفاتح';
        break;
      case ThemeMode.dark:
        message = 'تم التبديل إلى الوضع الداكن';
        break;
      case ThemeMode.system:
        message = 'تم التبديل إلى الوضع التلقائي';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'المظهر',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            Expanded(child: _buildThemeOptions()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.12),
            AppColors.info.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.palette_rounded,
              color: AppColors.info,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'اختر مظهر التطبيق الذي يناسب تفضيلاتك',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.info,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptions() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _themeOptions.length,
      itemBuilder: (context, index) {
        final option = _themeOptions[index];
        final isSelected = _selectedThemeMode == option.mode;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? option.iconColor.withOpacity(0.3)
                  : AppColors.border.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _changeTheme(option.mode),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            option.iconColor.withOpacity(0.15),
                            option.iconColor.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        option.icon,
                        color: option.iconColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: isSelected ? option.iconColor : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.description,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [option.iconColor, option.iconColor.withOpacity(0.8)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    else
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ThemeOption {
  final ThemeMode mode;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  ThemeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}
