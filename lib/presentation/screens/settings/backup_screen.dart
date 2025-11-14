import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/google_drive_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/settings/backup_type_selector_dialog.dart';

/// شاشة النسخ الاحتياطي - تصميم راقي هادئ
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _backupService = sl<BackupService>();
  final _logger = sl<LoggerService>();

  // GlobalKeys للأزرار
  final _backupButtonKey = GlobalKey();
  final _restoreButtonKey = GlobalKey();

  bool _isLoading = false;
  DateTime? _lastBackupDate;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _lastBackupPath;

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
  }

  Future<void> _loadBackupSettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = sl.get<SharedPreferencesService>();
      final lastBackupTimestamp = prefs.getString(StorageKeys.lastBackupTime);

      setState(() {
        _lastBackupDate = lastBackupTimestamp != null
            ? DateTime.tryParse(lastBackupTimestamp)
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _backupNow() async {
    // عرض القائمة المنسدلة لاختيار نوع النسخة الاحتياطية
    final backupType = await BackupTypeDropdownMenu.show(
      context: context,
      buttonKey: _backupButtonKey,
      isRestore: false,
    );

    if (backupType == null) return;

    // تنفيذ النسخ الاحتياطي بناءً على الخيار المحدد
    if (backupType == BackupType.local) {
      await _backupToLocal();
    } else {
      await _backupToGoogleDrive();
    }
  }

  Future<void> _backupToLocal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'نسخ احتياطي محلي',
        message: 'سيتم حفظ النسخة الاحتياطية على جهازك. هل تريد المتابعة؟',
        confirmText: 'نعم، احفظ',
        cancelText: 'إلغاء',
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBackingUp = true);

    try {
      final backupPath = await _backupService.createBackup();

      final now = DateTime.now();
      final prefs = sl.get<SharedPreferencesService>();
      await prefs.setString(StorageKeys.lastBackupTime, now.toIso8601String());

      setState(() {
        _lastBackupDate = now;
        _lastBackupPath = backupPath;
        _isBackingUp = false;
      });

      if (!mounted) return;
      _showMessage('تم إنشاء النسخة الاحتياطية المحلية بنجاح');
    } catch (e) {
      setState(() => _isBackingUp = false);
      if (!mounted) return;
      _showMessage('فشل إنشاء النسخة الاحتياطية', isError: true);
    }
  }

  Future<void> _backupToGoogleDrive() async {
    setState(() => _isBackingUp = true);

    try {
      final googleDrive = GoogleDriveService.instance;

      // التحقق من تسجيل الدخول
      if (!googleDrive.isSignedIn) {
        final signedIn = await googleDrive.signIn();
        if (!signedIn) {
          setState(() => _isBackingUp = false);
          if (!mounted) return;
          _showMessage('فشل تسجيل الدخول إلى Google Drive', isError: true);
          return;
        }
      }

      // إنشاء نسخة احتياطية محلية أولاً
      final localBackupPath = await _backupService.createBackup();

      if (!mounted) return;

      // عرض dialog للتقدم
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ProgressDialog(
          title: 'جاري رفع النسخة الاحتياطية',
          message: 'يتم رفع البيانات إلى Google Drive...',
        ),
      );

      // رفع النسخة إلى Google Drive
      await googleDrive.uploadBackup(
        localBackupPath,
        onProgress: (progress) {
          _logger.info('تقدم الرفع: ${(progress * 100).toInt()}%');
        },
      );

      final now = DateTime.now();
      final prefs = sl.get<SharedPreferencesService>();
      await prefs.setString(StorageKeys.lastBackupTime, now.toIso8601String());

      setState(() {
        _lastBackupDate = now;
        _isBackingUp = false;
      });

      if (!mounted) return;
      Navigator.pop(context); // إغلاق dialog التقدم
      _showMessage('تم رفع النسخة الاحتياطية إلى Google Drive بنجاح');
    } catch (e) {
      setState(() => _isBackingUp = false);
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // إغلاق dialog التقدم
      }
      if (!mounted) return;
      _showMessage(
        'فشل رفع النسخة إلى Google Drive: ${e.toString()}',
        isError: true,
      );
      _logger.error('فشل رفع النسخة الاحتياطية', error: e);
    }
  }

  Future<void> _restore() async {
    // عرض القائمة المنسدلة لاختيار نوع الاستعادة
    final backupType = await BackupTypeDropdownMenu.show(
      context: context,
      buttonKey: _restoreButtonKey,
      isRestore: true,
    );

    if (backupType == null) return;

    // تنفيذ الاستعادة بناءً على الخيار المحدد
    if (backupType == BackupType.local) {
      await _restoreFromLocal();
    } else {
      await _restoreFromGoogleDrive();
    }
  }

  Future<void> _restoreFromLocal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'استعادة من نسخة محلية',
        message: 'تحذير: سيتم استبدال جميع البيانات الحالية. هل تريد المتابعة؟',
        confirmText: 'نعم، استعد',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);

    try {
      if (_lastBackupPath != null) {
        await _backupService.restoreBackup(_lastBackupPath!);
      } else {
        // استخدام file picker لاختيار الملف
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['db', 'sqlite', 'backup'],
        );

        if (result != null && result.files.single.path != null) {
          await _backupService.restoreBackup(result.files.single.path!);
        } else {
          setState(() => _isRestoring = false);
          if (!mounted) return;
          _showMessage('لم يتم اختيار ملف', isError: true);
          return;
        }
      }

      setState(() => _isRestoring = false);
      if (!mounted) return;
      _showMessage('تمت استعادة البيانات المحلية بنجاح');
    } catch (e) {
      setState(() => _isRestoring = false);
      if (!mounted) return;
      _showMessage('فشل استعادة البيانات', isError: true);
    }
  }

  Future<void> _restoreFromGoogleDrive() async {
    setState(() => _isRestoring = true);

    try {
      final googleDrive = GoogleDriveService.instance;

      // التحقق من تسجيل الدخول
      if (!googleDrive.isSignedIn) {
        final signedIn = await googleDrive.signIn();
        if (!signedIn) {
          setState(() => _isRestoring = false);
          if (!mounted) return;
          _showMessage('فشل تسجيل الدخول إلى Google Drive', isError: true);
          return;
        }
      }

      // الحصول على قائمة النسخ الاحتياطية
      final backups = await googleDrive.listBackups();

      if (backups.isEmpty) {
        setState(() => _isRestoring = false);
        if (!mounted) return;
        _showMessage('لا توجد نسخ احتياطية في Google Drive', isError: true);
        return;
      }

      if (!mounted) return;

      // عرض قائمة بالنسخ المتاحة للاختيار
      final selectedBackup = await showDialog<DriveBackupInfo>(
        context: context,
        builder: (context) => _BackupListDialog(backups: backups),
      );

      if (selectedBackup == null) {
        setState(() => _isRestoring = false);
        return;
      }

      if (!mounted) return;

      // تأكيد الاستعادة
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ConfirmDialog(
          title: 'تأكيد الاستعادة',
          message:
              'سيتم استعادة النسخة الاحتياطية من ${selectedBackup.name}\n\nتحذير: سيتم استبدال جميع البيانات الحالية!',
          confirmText: 'نعم، استعد',
          cancelText: 'إلغاء',
          isDestructive: true,
        ),
      );

      if (confirmed != true) {
        setState(() => _isRestoring = false);
        return;
      }

      if (!mounted) return;

      // عرض dialog للتقدم
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _ProgressDialog(
          title: 'جاري تحميل النسخة الاحتياطية',
          message: 'يتم تحميل البيانات من Google Drive...',
        ),
      );

      // تحميل النسخة من Google Drive
      final dir = await getApplicationDocumentsDirectory();
      final localPath = p.join(
        dir.path,
        'restore_${DateTime.now().millisecondsSinceEpoch}.db',
      );

      await googleDrive.downloadBackup(
        selectedBackup.id,
        localPath,
        onProgress: (progress) {
          _logger.info('تقدم التحميل: ${(progress * 100).toInt()}%');
        },
      );

      // استعادة البيانات من الملف المحمل
      await _backupService.restoreBackup(localPath);

      setState(() => _isRestoring = false);

      if (!mounted) return;
      Navigator.pop(context); // إغلاق dialog التقدم
      _showMessage('تمت استعادة البيانات من Google Drive بنجاح');

      // حذف الملف المؤقت
      try {
        await File(localPath).delete();
      } catch (e) {
        _logger.info('فشل حذف الملف المؤقت: $e');
      }
    } catch (e) {
      setState(() => _isRestoring = false);
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // إغلاق dialog التقدم
      }
      if (!mounted) return;
      _showMessage(
        'فشل استعادة البيانات من Google Drive: ${e.toString()}',
        isError: true,
      );
      _logger.error('فشل استعادة البيانات', error: e);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
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
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'النسخ الاحتياطي',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 24),
          _buildActionsSection(),
          const SizedBox(height: 24),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.info, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.backup_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة النسخ الاحتياطي',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lastBackupDate != null
                          ? 'آخر نسخة: ${_formatDate(_lastBackupDate!)}'
                          : 'لا توجد نسخ احتياطية',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return _SectionCard(
      title: 'الإجراءات',
      icon: Icons.touch_app_rounded,
      color: AppColors.primary,
      child: Column(
        children: [
          _ActionButton(
            key: _backupButtonKey,
            icon: Icons.backup_rounded,
            label: 'إنشاء نسخة احتياطية',
            subtitle: 'حفظ نسخة من بياناتك الحالية',
            color: AppColors.success,
            isLoading: _isBackingUp,
            onTap: _backupNow,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            key: _restoreButtonKey,
            icon: Icons.restore_rounded,
            label: 'استعادة البيانات',
            subtitle: 'استرجاع بيانات من نسخة احتياطية',
            color: AppColors.warning,
            isLoading: _isRestoring,
            onTap: _restore,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return _SectionCard(
      title: 'معلومات مهمة',
      icon: Icons.info_rounded,
      color: AppColors.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoItem(
            icon: Icons.check_circle_rounded,
            text: 'يتم حفظ النسخ الاحتياطية محلياً على جهازك',
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _InfoItem(
            icon: Icons.cloud_upload_rounded,
            text: 'يمكنك رفع النسخة الاحتياطية للسحابة يدوياً',
            color: AppColors.info,
          ),
          const SizedBox(height: 12),
          _InfoItem(
            icon: Icons.warning_rounded,
            text: 'احرص على إنشاء نسخ احتياطية دورية',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog لعرض التقدم
class _ProgressDialog extends StatelessWidget {
  final String title;
  final String message;

  const _ProgressDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog لاختيار النسخة الاحتياطية من قائمة
class _BackupListDialog extends StatelessWidget {
  final List<DriveBackupInfo> backups;

  const _BackupListDialog({required this.backups});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.info.withOpacity(0.15),
                      AppColors.info.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.info, Color(0xFF0284C7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.cloud_download_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر نسخة احتياطية',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${backups.length} نسخة متاحة',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: backups.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final backup = backups[index];
                    return _BackupListItem(
                      backup: backup,
                      onTap: () => Navigator.pop(context, backup),
                    );
                  },
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنصر في قائمة النسخ الاحتياطية
class _BackupListItem extends StatelessWidget {
  final DriveBackupInfo backup;
  final VoidCallback onTap;

  const _BackupListItem({required this.backup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.success, Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.backup_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(backup.createdTime),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatSize(backup.size),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
  }
}
