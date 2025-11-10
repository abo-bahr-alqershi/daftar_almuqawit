import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../widgets/common/loading_widget.dart';
import '../../blocs/app/app_settings_bloc.dart';

/// شاشة اختيار اللغة
/// 
/// تسمح للمستخدم باختيار لغة التطبيق وحفظ الاختيار
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final List<LanguageItem> _languages = [
    LanguageItem(
      code: 'ar',
      name: 'العربية',
      englishName: 'Arabic',
      flag: '🇾🇪',
    ),
    LanguageItem(
      code: 'en',
      name: 'English',
      englishName: 'English',
      flag: '🇬🇧',
    ),
  ];

  /// تغيير اللغة
  void _changeLanguage(String languageCode) {
    final settingsBloc = context.read<AppSettingsBloc>();
    final currentLanguage = settingsBloc.state.languageCode;

    if (currentLanguage == languageCode) return;

    settingsBloc.add(ChangeLanguage(languageCode));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageCode == 'ar'
              ? 'تم تغيير اللغة إلى العربية'
              : 'Language changed to English',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _showRestartDialog();
    });
  }

  /// عرض dialog لإعادة التشغيل
  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppDimensions.spaceS),
              Text('إعادة التشغيل', style: AppTextStyles.titleMedium),
            ],
          ),
          content: Text(
            'لتطبيق تغيير اللغة بشكل كامل، يُفضل إعادة تشغيل التطبيق.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق الـ dialog
                Navigator.pop(context); // العودة للشاشة السابقة
              },
              child: Text(
                'حسناً',
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
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
          title: Text('اللغة', style: AppTextStyles.titleLarge),
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
            return _buildLanguageList(state.languageCode);
          },
        ),
      ),
    );
  }

  Widget _buildLanguageList(String selectedLanguage) {
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
                Icons.language,
                color: AppColors.info,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Text(
                  'اختر اللغة المفضلة لعرض واجهة التطبيق',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
        ),

        // قائمة اللغات
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            itemCount: _languages.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spaceM),
            itemBuilder: (context, index) {
              final language = _languages[index];
              final isSelected = selectedLanguage == language.code;

              return _LanguageTile(
                language: language,
                isSelected: isSelected,
                onTap: () => _changeLanguage(language.code),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// عنصر اللغة في القائمة
class _LanguageTile extends StatelessWidget {
  final LanguageItem language;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LanguageTile({
    required this.language,
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
            // العلم
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              alignment: Alignment.center,
              child: Text(
                language.flag,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceM),

            // معلومات اللغة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.englishName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
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

/// نموذج بيانات اللغة
class LanguageItem {
  final String code;
  final String name;
  final String englishName;
  final String flag;

  LanguageItem({
    required this.code,
    required this.name,
    required this.englishName,
    required this.flag,
  });
}
