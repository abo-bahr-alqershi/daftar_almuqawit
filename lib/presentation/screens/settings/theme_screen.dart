import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../widgets/common/loading_widget.dart';
import '../../blocs/app/app_settings_bloc.dart';

/// شاشة اختيار المظهر
/// 
/// تسمح للمستخدم باختيار وضع المظهر (فاتح، داكن، تلقائي) مع معاينة
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  ThemeMode _selectedThemeMode = ThemeMode.system;

  final List<ThemeOption> _themeOptions = [
    ThemeOption(
      mode: ThemeMode.light,
      title: 'الوضع الفاتح',
      description: 'مظهر فاتح يناسب الاستخدام النهاري',
      icon: Icons.light_mode,
      iconColor: AppColors.warning,
      previewColors: [
        AppColors.background,
        AppColors.surface,
        AppColors.primary,
      ],
    ),
    ThemeOption(
      mode: ThemeMode.dark,
      title: 'الوضع الداكن',
      description: 'مظهر داكن مريح للعين ويوفر الطاقة',
      icon: Icons.dark_mode,
      iconColor: AppColors.primary,
      previewColors: [
        AppColors.darkBackground,
        AppColors.darkSurface,
        AppColors.primaryLight,
      ],
    ),
    ThemeOption(
      mode: ThemeMode.system,
      title: 'تلقائي',
      description: 'يتبع إعدادات النظام',
      icon: Icons.brightness_auto,
      iconColor: AppColors.info,
      previewColors: [
        AppColors.background,
        AppColors.darkBackground,
        AppColors.primary,
      ],
    ),
  ];

  /// تحويل النص إلى ThemeMode
  ThemeMode _parseThemeMode(bool isDarkMode) {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// تغيير المظهر
  void _changeTheme(ThemeMode themeMode) {
    final settingsBloc = context.read<AppSettingsBloc>();
    final currentIsDarkMode = settingsBloc.state.isDarkMode;
    final currentThemeMode = _parseThemeMode(currentIsDarkMode);

    if (currentThemeMode == themeMode && themeMode != ThemeMode.system) return;

    bool? newIsDarkMode;
    if (themeMode == ThemeMode.dark) {
      newIsDarkMode = true;
    } else if (themeMode == ThemeMode.light) {
      newIsDarkMode = false;
    } else {
      newIsDarkMode = false;
    }

    settingsBloc.add(ToggleThemeMode(isDarkMode: newIsDarkMode));

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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('المظهر', style: AppTextStyles.titleLarge),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<AppSettingsBloc, AppSettingsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const LoadingWidget.large(message: 'جارِ التحميل...');
            }
            
            final currentThemeMode = _parseThemeMode(state.isDarkMode);
            return _buildThemeOptions(currentThemeMode);
          },
        ),
      ),
    );
  }

  Widget _buildThemeOptions(ThemeMode currentThemeMode) {
    return Column(
      children: [
        // معلومات توضيحية
        Container(
          margin: const EdgeInsets.all(AppDimensions.marginL),
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: AppColors.info,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Text(
                  'اختر مظهر التطبيق الذي يناسب تفضيلاتك',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
        ),

        // خيارات المظهر
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            itemCount: _themeOptions.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spaceM),
            itemBuilder: (context, index) {
              final option = _themeOptions[index];
              final isSelected = currentThemeMode == option.mode;

              return _ThemeOptionTile(
                option: option,
                isSelected: isSelected,
                onTap: () => _changeTheme(option.mode),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// عنصر خيار المظهر في القائمة
class _ThemeOptionTile extends StatelessWidget {
  final ThemeOption option;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ThemeOptionTile({
    required this.option,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // الأيقونة
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: option.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(
                option.icon,
                color: option.iconColor,
                size: AppDimensions.iconL,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceM),

            // معلومات المظهر
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceS),
                  
                  // معاينة الألوان
                  Row(
                    children: option.previewColors.map((color) {
                      return Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // أيقونة التحديد
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.textOnDark,
                  size: 18,
                ),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// نموذج بيانات خيار المظهر
class ThemeOption {
  final ThemeMode mode;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final List<Color> previewColors;

  ThemeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.previewColors,
  });
}
