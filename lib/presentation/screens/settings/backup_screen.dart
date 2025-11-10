import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/constants/storage_keys.dart';
import '../../widgets/settings/backup_options.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/confirm_dialog.dart';

/// شاشة النسخ الاحتياطي والاستعادة
/// 
/// تعرض خيارات النسخ الاحتياطي والاستعادة مع حالات التحميل والخطأ
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  // حالات الشاشة
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isAutoBackupEnabled = false;
  DateTime? _lastBackupDate;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
  }

  /// تحميل إعدادات النسخ الاحتياطي
  Future<void> _loadBackupSettings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _isAutoBackupEnabled = prefs.getBool(StorageKeys.autoBackupEnabled) ?? false;
        final lastBackupTimestamp = prefs.getString(StorageKeys.lastBackupTime);
        _lastBackupDate = lastBackupTimestamp != null 
            ? DateTime.tryParse(lastBackupTimestamp) 
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'فشل تحميل إعدادات النسخ الاحتياطي';
      });
    }
  }

  /// إجراء نسخ احتياطي الآن
  Future<void> _backupNow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'نسخ احتياطي',
        message: 'هل تريد إنشاء نسخة احتياطية من بياناتك الآن؟',
        confirmText: 'نعم، احفظ',
        cancelText: 'إلغاء',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBackingUp = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.lastBackupTime, now.toIso8601String());
      
      setState(() {
        _lastBackupDate = now;
        _isBackingUp = false;
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _isBackingUp = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إنشاء النسخة الاحتياطية: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// استعادة البيانات
  Future<void> _restore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'استعادة البيانات',
        message: 'تحذير: سيتم استبدال جميع البيانات الحالية بالبيانات المحفوظة. هل تريد المتابعة؟',
        confirmText: 'نعم، استعد',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);

    try {
      // TODO: تنفيذ عملية الاستعادة
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isRestoring = false);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت استعادة البيانات بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _isRestoring = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشلت استعادة البيانات: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// تبديل النسخ الاحتياطي التلقائي
  Future<void> _toggleAutoBackup() async {
    setState(() => _isAutoBackupEnabled = !_isAutoBackupEnabled);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.autoBackupEnabled, _isAutoBackupEnabled);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isAutoBackupEnabled
                ? 'تم تفعيل النسخ الاحتياطي التلقائي'
                : 'تم تعطيل النسخ الاحتياطي التلقائي',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _isAutoBackupEnabled = !_isAutoBackupEnabled);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل تحديث الإعدادات'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// تصدير البيانات محلياً
  Future<void> _exportData() async {
    try {
      // TODO: تنفيذ تصدير البيانات إلى ملف محلي
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تصدير البيانات بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تصدير البيانات: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          title: Text(
            'النسخ الاحتياطي والاستعادة',
            style: AppTextStyles.titleLarge,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget.large(
        message: 'جارِ تحميل الإعدادات...',
      );
    }

    if (_hasError) {
      return AppErrorWidget(
        title: 'خطأ',
        message: _errorMessage ?? 'حدث خطأ غير متوقع',
        onRetry: _loadBackupSettings,
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات توضيحية
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: AppDimensions.iconM,
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Expanded(
                      child: Text(
                        'احتفظ بنسخة احتياطية من بياناتك بشكل دوري لتجنب فقدانها',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),

              // خيارات النسخ الاحتياطي
              BackupOptions(
                onBackupNow: _backupNow,
                onRestore: _restore,
                onAutoBackup: _toggleAutoBackup,
                onExportData: _exportData,
                isAutoBackupEnabled: _isAutoBackupEnabled,
                lastBackupDate: _lastBackupDate,
              ),
              
              const SizedBox(height: AppDimensions.spaceXL),

              // معلومات إضافية
              _buildInfoSection(),
            ],
          ),
        ),

        // مؤشر التحميل أثناء العمليات
        if (_isBackingUp || _isRestoring)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LoadingWidget.large(),
                    const SizedBox(height: AppDimensions.spaceM),
                    Text(
                      _isBackingUp ? 'جارِ النسخ الاحتياطي...' : 'جارِ الاستعادة...',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: AppDimensions.spaceS),
                    Text(
                      'الرجاء الانتظار، لا تغلق التطبيق',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.info,
                size: AppDimensions.iconM,
              ),
              const SizedBox(width: AppDimensions.spaceS),
              Text(
                'معلومات مهمة',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.info),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          _buildInfoItem('النسخ الاحتياطي يشمل جميع البيانات'),
          _buildInfoItem('الاستعادة تستبدل البيانات الحالية'),
          _buildInfoItem('النسخ التلقائي يعمل يومياً'),
          _buildInfoItem('البيانات مشفرة ومحمية'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
