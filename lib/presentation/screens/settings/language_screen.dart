import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../widgets/common/loading_widget.dart';

/// شاشة اختيار اللغة
/// 
/// تسمح للمستخدم باختيار لغة التطبيق وحفظ الاختيار
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const String _languageKey = 'app_language';
  
  bool _isLoading = true;
  String _selectedLanguage = 'ar'; // ar = Arabic, en = English
  bool _isSaving = false;

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

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  /// تحميل اللغة المحفوظة
  Future<void> _loadCurrentLanguage() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      setState(() {
        _selectedLanguage = savedLanguage ?? 'ar';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحميل إعدادات اللغة: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// تغيير اللغة
  Future<void> _changeLanguage(String languageCode) async {
    if (_selectedLanguage == languageCode) return;

    setState(() {
      _isSaving = true;
      _selectedLanguage = languageCode;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      setState(() => _isSaving = false);

      if (!mounted) return;

      // إظهار رسالة نجاح
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

      // TODO: تطبيق تغيير اللغة على التطبيق
      // يمكن استخدام package مثل easy_localization أو flutter_localizations
      
      // إعادة بناء التطبيق بعد تأخير قصير
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // عرض dialog للإعلام بضرورة إعادة تشغيل التطبيق
      _showRestartDialog();
    } catch (e) {
      setState(() {
        _isSaving = false;
        // إرجاع اللغة السابقة في حالة الفشل
        _selectedLanguage = _selectedLanguage == 'ar' ? 'en' : 'ar';
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ اللغة: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        body: _isLoading
            ? const LoadingWidget.large(message: 'جارِ التحميل...')
            : _buildLanguageList(),
      ),
    );
  }

  Widget _buildLanguageList() {
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
              final isSelected = _selectedLanguage == language.code;

              return _LanguageTile(
                language: language,
                isSelected: isSelected,
                onTap: _isSaving ? null : () => _changeLanguage(language.code),
              );
            },
          ),
        ),

        // مؤشر الحفظ
        if (_isSaving)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Text(
                  'جارِ الحفظ...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
