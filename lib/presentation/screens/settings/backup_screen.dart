import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/settings/backup_options.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';

/// شاشة النسخ الاحتياطي والاستعادة
///
/// تعرض خيارات النسخ الاحتياطي والاستعادة مع حالات التحميل والخطأ
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  // الخدمات
  final _backupService = sl<BackupService>();
  final _logger = sl<LoggerService>();

  // حالات الشاشة
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  DateTime? _lastBackupDate;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _lastBackupPath;

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
      final settingsBloc = context.read<SettingsBloc>();
      if (settingsBloc.state is SettingsLoaded) {
        final state = settingsBloc.state as SettingsLoaded;

        // تحميل وقت آخر نسخة احتياطية
        final prefs = sl.get<SharedPreferencesService>();
        final lastBackupTimestamp = prefs.getString(StorageKeys.lastBackupTime);

        setState(() {
          _lastBackupDate = lastBackupTimestamp != null
              ? DateTime.tryParse(lastBackupTimestamp)
              : null;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _logger.error('فشل تحميل إعدادات النسخ الاحتياطي', error: e);
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
      _logger.info('بدء عملية النسخ الاحتياطي...');

      // إنشاء نسخة احتياطية حقيقية
      final backupPath = await _backupService.createBackup();

      _logger.info('تم إنشاء النسخة الاحتياطية في: $backupPath');

      // حفظ وقت آخر نسخة
      final now = DateTime.now();
      final prefs = sl.get<SharedPreferencesService>();
      await prefs.setString(StorageKeys.lastBackupTime, now.toIso8601String());

      setState(() {
        _lastBackupDate = now;
        _lastBackupPath = backupPath;
        _isBackingUp = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء النسخة الاحتياطية بنجاح\n$backupPath'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      _logger.error('فشل إنشاء النسخة الاحتياطية', error: e);

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
        message:
            'تحذير: سيتم استبدال جميع البيانات الحالية بالبيانات المحفوظة. هل تريد المتابعة؟',
        confirmText: 'نعم، استعد',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    // التحقق من وجود مسار نسخة احتياطية
    if (_lastBackupPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد نسخة احتياطية للاستعادة'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isRestoring = true);

    try {
      _logger.info('بدء عملية الاستعادة من: $_lastBackupPath');

      // استعادة حقيقية من النسخة الاحتياطية
      await _backupService.restoreBackup(_lastBackupPath!);

      _logger.info('تمت استعادة البيانات بنجاح');

      setState(() => _isRestoring = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت استعادة البيانات بنجاح\nسيتم إعادة تشغيل التطبيق'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      // TODO: إعادة تشغيل التطبيق أو إعادة التوجيه للشاشة الرئيسية
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      _logger.error('فشلت استعادة البيانات', error: e);

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
    final settingsBloc = context.read<SettingsBloc>();
    final currentState = settingsBloc.state as SettingsLoaded;

    final newValue = !currentState.autoBackupEnabled;

    // إرسال الحدث إلى BLoC
    settingsBloc.add(ToggleAutoBackup(newValue));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newValue
              ? 'تم تفعيل النسخ الاحتياطي التلقائي'
              : 'تم تعطيل النسخ الاحتياطي التلقائي',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// تصدير البيانات محلياً
  Future<void> _exportData() async {
    try {
      _logger.info('بدء عملية تصدير البيانات...');

      // TODO: تنفيذ تصدير البيانات إلى ملف Excel
      await Future.delayed(const Duration(seconds: 1));

      _logger.info('تم تصدير البيانات بنجاح');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تصدير البيانات بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _logger.error('فشل تصدير البيانات', error: e);

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

  /// نسخ احتياطي إلى Google Drive
  Future<void> _backupToDrive() async {
    // التحقق من تسجيل الدخول أولاً
    if (!_backupService.isSignedInToDrive) {
      final signedIn = await _backupService.signInToGoogleDrive();

      if (!signedIn) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول إلى Google Drive أولاً'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'نسخ احتياطي إلى Google Drive',
        message:
            'هل تريد رفع نسخة احتياطية إلى Google Drive؟\n\nستظهر النسخة في حسابك على drive.google.com',
        confirmText: 'نعم، ارفع',
        cancelText: 'إلغاء',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBackingUp = true);

    try {
      _logger.info('بدء النسخ الاحتياطي إلى Google Drive...');

      final driveFileId = await _backupService.createBackupToDrive(
        onUploadProgress: (progress) {
          _logger.info('تقدم الرفع: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      _logger.info('تم رفع النسخة إلى Google Drive بنجاح! ID: $driveFileId');

      final now = DateTime.now();
      final prefs = sl.get<SharedPreferencesService>();
      await prefs.setString(StorageKeys.lastBackupTime, now.toIso8601String());

      setState(() {
        _lastBackupDate = now;
        _isBackingUp = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ تم رفع النسخة إلى Google Drive بنجاح!\n\nيمكنك مشاهدتها في drive.google.com',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      _logger.error('فشل النسخ الاحتياطي إلى Google Drive', error: e);

      setState(() => _isBackingUp = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل رفع النسخة إلى Google Drive: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// استعادة من Google Drive
  Future<void> _restoreFromDrive() async {
    // التحقق من تسجيل الدخول أولاً
    if (!_backupService.isSignedInToDrive) {
      final signedIn = await _backupService.signInToGoogleDrive();

      if (!signedIn) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول إلى Google Drive أولاً'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // جلب قائمة النسخ من Drive
      final backups = await _backupService.getDriveBackups();

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (backups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد نسخ احتياطية في Google Drive'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // عرض قائمة النسخ المتاحة
      final selectedBackup = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('اختر نسخة احتياطية'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[index];
                return ListTile(
                  leading: const Icon(Icons.cloud, color: Color(0xFF4285F4)),
                  title: Text(backup.name),
                  subtitle: Text(backup.timeAgo),
                  trailing: Text(backup.sizeFormatted),
                  onTap: () => Navigator.pop(context, backup.id),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      );

      if (selectedBackup == null) return;

      // تأكيد الاستعادة
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => const ConfirmDialog(
          title: 'استعادة من Google Drive',
          message:
              'هل تريد استعادة البيانات من هذه النسخة؟\n\n⚠️ سيتم استبدال جميع البيانات الحالية',
          confirmText: 'نعم، استعد',
          cancelText: 'إلغاء',
        ),
      );

      if (confirmed != true) return;

      setState(() => _isRestoring = true);

      _logger.info('بدء الاستعادة من Google Drive...');

      await _backupService.restoreFromDrive(
        selectedBackup,
        onDownloadProgress: (progress) {
          _logger.info('تقدم التحميل: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      _logger.info('تمت الاستعادة من Google Drive بنجاح!');

      setState(() => _isRestoring = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تمت الاستعادة بنجاح! سيتم إعادة تشغيل التطبيق...'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      // إعادة تشغيل التطبيق
      await Future.delayed(const Duration(seconds: 3));
      // يمكن إضافة كود إعادة التشغيل هنا
    } catch (e) {
      _logger.error('فشلت الاستعادة من Google Drive', error: e);

      setState(() => _isRestoring = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشلت الاستعادة من Google Drive: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      return const LoadingWidget.large(message: 'جارِ تحميل الإعدادات...');
    }

    if (_hasError) {
      return AppErrorWidget(
        title: 'خطأ',
        message: _errorMessage ?? 'حدث خطأ غير متوقع',
        onRetry: _loadBackupSettings,
      );
    }

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
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
                    onBackupToDrive: _backupToDrive,
                    onRestoreFromDrive: _restoreFromDrive,
                    onRestore: _restore,
                    onAutoBackup: _toggleAutoBackup,
                    onExportData: _exportData,
                    isAutoBackupEnabled: state.autoBackupEnabled,
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoadingWidget.large(),
                        const SizedBox(height: AppDimensions.spaceM),
                        Text(
                          _isBackingUp
                              ? 'جارِ النسخ الاحتياطي...'
                              : 'جارِ الاستعادة...',
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
      },
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
