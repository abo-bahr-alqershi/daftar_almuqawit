import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/google_drive_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';

/// شاشة النسخ الاحتياطي والاستعادة المحسّنة
/// تدعم النسخ المحلي والسحابي (Firebase Storage)
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen>
    with SingleTickerProviderStateMixin {
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
  double _uploadProgress = 0.0;
  double _downloadProgress = 0.0;

  // قائمة النسخ السحابية (Google Drive)
  List<DriveBackupInfo> _cloudBackups = [];
  bool _isLoadingCloudBackups = false;

  // Tabs
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
        if (_currentTab == 1 && _cloudBackups.isEmpty) {
          _loadCloudBackups();
        }
      }
    });
    _loadBackupSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// تحميل إعدادات النسخ الاحتياطي
  Future<void> _loadBackupSettings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = sl<SharedPreferencesService>();
      final lastBackupTimestamp = prefs.getString(StorageKeys.lastBackupTime);

      setState(() {
        _lastBackupDate = lastBackupTimestamp != null
            ? DateTime.tryParse(lastBackupTimestamp)
            : null;
        _isLoading = false;
      });
    } catch (e) {
      _logger.error('فشل تحميل إعدادات النسخ الاحتياطي', error: e);
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'فشل تحميل إعدادات النسخ الاحتياطي';
      });
    }
  }

  /// تحميل قائمة النسخ السحابية
  Future<void> _loadCloudBackups() async {
    setState(() => _isLoadingCloudBackups = true);

    try {
      final backups = await _backupService.getCloudBackups();
      setState(() {
        _cloudBackups = backups;
        _isLoadingCloudBackups = false;
      });
      _logger.info('تم تحميل ${backups.length} نسخة احتياطية سحابية');
    } catch (e) {
      _logger.error('فشل تحميل النسخ السحابية', error: e);
      setState(() => _isLoadingCloudBackups = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل النسخ السحابية: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// إجراء نسخ احتياطي محلي مع اختيار الموقع
  Future<void> _backupToLocalWithPicker() async {
    try {
      // اختيار مجلد الحفظ
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر موقع حفظ النسخة الاحتياطية',
      );

      if (selectedDirectory == null) {
        _logger.info('تم إلغاء اختيار المجلد');
        return;
      }

      _logger.info('المجلد المختار: $selectedDirectory');

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ConfirmDialog(
          title: 'نسخ احتياطي محلي',
          message: 'سيتم إنشاء نسخة احتياطية وحفظها في:\n$selectedDirectory\n\nهل تريد المتابعة؟',
          confirmText: 'نعم، احفظ',
          cancelText: 'إلغاء',
        ),
      );

      if (confirmed != true) return;

      setState(() {
        _isBackingUp = true;
        _uploadProgress = 0.0;
      });

      // إنشاء نسخة احتياطية
      final tempBackupPath = await _backupService.createBackup(
        onProgress: (progress) {
          setState(() => _uploadProgress = progress * 0.8);
        },
      );

      // نسخ الملف إلى الموقع المختار
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_$timestamp.db';
      final destinationPath = path.join(selectedDirectory, fileName);

      _logger.info('نسخ الملف من $tempBackupPath إلى $destinationPath');

      final sourceFile = File(tempBackupPath);
      await sourceFile.copy(destinationPath);

      setState(() => _uploadProgress = 0.9);

      // حفظ وقت آخر نسخة
      final now = DateTime.now();
      final prefs = sl<SharedPreferencesService>();
      await prefs.setString(StorageKeys.lastBackupTime, now.toIso8601String());

      setState(() {
        _lastBackupDate = now;
        _isBackingUp = false;
        _uploadProgress = 0.0;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء النسخة الاحتياطية بنجاح في:\n$destinationPath'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      _logger.error('فشل إنشاء النسخة الاحتياطية المحلية', error: e);

      setState(() {
        _isBackingUp = false;
        _uploadProgress = 0.0;
      });

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

  /// استعادة من ملف محلي مع اختيار الملف
  Future<void> _restoreFromLocalFile() async {
    try {
      // اختيار ملف النسخة الاحتياطية
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'اختر ملف النسخة الاحتياطية',
        type: FileType.any,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.isEmpty) {
        _logger.info('تم إلغاء اختيار الملف');
        return;
      }

      final selectedFile = result.files.first;
      final filePath = selectedFile.path;

      if (filePath == null) {
        throw Exception('لم يتم اختيار ملف صالح');
      }

      _logger.info('الملف المختار: $filePath');

      // التحقق من وجود الملف
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('الملف المختار غير موجود');
      }

      final fileSize = await file.length();
      final fileSizeFormatted = fileSize < 1024 * 1024
          ? '${(fileSize / 1024).toStringAsFixed(1)} KB'
          : '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ConfirmDialog(
          title: 'استعادة من نسخة محلية',
          message:
              '⚠️ تحذير مهم:\n\n'
              '• سيتم استبدال جميع البيانات الحالية\n'
              '• سيتم إنشاء نسخة احتياطية للحماية تلقائياً\n'
              '• الملف المختار: ${selectedFile.name}\n'
              '• الحجم: $fileSizeFormatted\n\n'
              'هل تريد المتابعة؟',
          confirmText: 'نعم، استعد البيانات',
          cancelText: 'إلغاء',
          isDestructive: true,
        ),
      );

      if (confirmed != true) return;

      setState(() {
        _isRestoring = true;
        _downloadProgress = 0.0;
      });

      // إنشاء نسخة احتياطية للحماية
      _logger.info('🛡️ إنشاء نسخة احتياطية للحماية...');
      setState(() => _downloadProgress = 0.1);

      try {
        await _backupService.createBackup();
      } catch (e) {
        _logger.warning('⚠️ فشل إنشاء نسخة الحماية: $e');
      }

      setState(() => _downloadProgress = 0.3);

      // استعادة من الملف المختار
      _logger.info('🔄 بدء استعادة البيانات...');
      await _backupService.restoreBackup(filePath);

      setState(() {
        _isRestoring = false;
        _downloadProgress = 1.0;
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Text(
                  'تمت الاستعادة بنجاح',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم استعادة البيانات بنجاح من الملف المحلي.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spaceS),
                        Text(
                          'معلومات الملف:',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceS),
                    _buildInfoRow('الاسم', selectedFile.name),
                    _buildInfoRow('الحجم', fileSizeFormatted),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('تم'),
            ),
          ],
        ),
      );
    } catch (e) {
      _logger.error('فشلت استعادة البيانات من الملف المحلي', error: e);

      setState(() {
        _isRestoring = false;
        _downloadProgress = 0.0;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشلت الاستعادة: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// إجراء نسخ احتياطي محلي + رفع لـ Google Drive
  Future<void> _backupNow({bool uploadToDrive = true}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'نسخ احتياطي',
        message: uploadToDrive
            ? 'سيتم إنشاء نسخة احتياطية ورفعها إلى Google Drive. هل تريد المتابعة؟'
            : 'سيتم إنشاء نسخة احتياطية محلية فقط. هل تريد المتابعة؟',
        confirmText: 'نعم، احفظ',
        cancelText: 'إلغاء',
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isBackingUp = true;
      _uploadProgress = 0.0;
    });

    try {
      String backupPath;
      
      if (uploadToDrive) {
        _logger.info('بدء عملية النسخ الاحتياطي إلى Google Drive...');

        // رفع إلى Google Drive مباشرة
        final fileId = await _backupService.createBackupToDrive(
          onUploadProgress: (progress) {
            setState(() => _uploadProgress = progress);
          },
        );

        _logger.info('تم رفع النسخة إلى Google Drive: $fileId');
        backupPath = fileId;
      } else {
        // نسخ محلي فقط
        backupPath = await _backupService.createBackup();
        _logger.info('تم إنشاء النسخة المحلية في: $backupPath');
      }

      // حفظ وقت آخر نسخة
      final now = DateTime.now();
      final prefs = sl<SharedPreferencesService>();
      await prefs.setString(StorageKeys.lastBackupTime, now.toIso8601String());

      setState(() {
        _lastBackupDate = now;
        _isBackingUp = false;
        _uploadProgress = 0.0;
      });

      // إعادة تحميل النسخ السحابية
      if (uploadToDrive) {
        _loadCloudBackups();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uploadToDrive
                ? 'تم إنشاء النسخة الاحتياطية ورفعها إلى Google Drive بنجاح ✅'
                : 'تم إنشاء النسخة الاحتياطية المحلية بنجاح ✅',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      _logger.error('فشل إنشاء النسخة الاحتياطية', error: e);

      setState(() {
        _isBackingUp = false;
        _uploadProgress = 0.0;
      });

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

  /// استعادة من نسخة سحابية (Google Drive) مع آليات حماية احترافية
  Future<void> _restoreFromCloud(DriveBackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'استعادة من السحابة',
        message:
            '⚠️ تحذير مهم:\n\n'
            '• سيتم استبدال جميع البيانات الحالية\n'
            '• سيتم إنشاء نسخة احتياطية للحماية تلقائياً\n'
            '• النسخة المختارة: ${backup.name}\n'
            '• الحجم: ${backup.sizeFormatted}\n'
            '• التاريخ: ${backup.timeAgo}\n\n'
            'هل تريد المتابعة؟',
        confirmText: 'نعم، استعد البيانات',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRestoring = true;
      _downloadProgress = 0.0;
    });

    String? errorDetails;

    try {
      _logger.info('🔄 بدء استعادة من Google Drive: ${backup.id}');
      _logger.info('📦 النسخة: ${backup.name}');
      _logger.info('📊 الحجم: ${backup.sizeFormatted}');

      await _backupService.restoreFromDrive(
        backup.id,
        onDownloadProgress: (progress) {
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
          
          _logger.info('📥 تقدم الاستعادة: ${(progress * 100).toStringAsFixed(0)}%');
        },
        createSafetyBackup: true,
      );

      _logger.info('✅ تمت الاستعادة بنجاح!');

      setState(() {
        _isRestoring = false;
        _downloadProgress = 1.0;
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Text(
                  'تمت الاستعادة بنجاح',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم استعادة البيانات بنجاح من النسخة الاحتياطية.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spaceS),
                        Text(
                          'معلومات النسخة المستعادة:',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceS),
                    _buildInfoRow('الاسم', backup.name),
                    _buildInfoRow('الحجم', backup.sizeFormatted),
                    _buildInfoRow('التاريخ', backup.timeAgo),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Text(
                'يُنصح بإعادة تشغيل التطبيق للتأكد من تحميل البيانات بشكل صحيح.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('العودة للإعدادات'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('تم'),
            ),
          ],
        ),
      );

    } catch (e, stackTrace) {
      _logger.error('❌ فشلت استعادة البيانات من السحابة', error: e, stackTrace: stackTrace);
      errorDetails = e.toString();

      setState(() {
        _isRestoring = false;
        _downloadProgress = 0.0;
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Text(
                  'فشلت الاستعادة',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدث خطأ أثناء استعادة البيانات:',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.spaceM),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Text(
                    errorDetails ?? 'خطأ غير معروف',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.danger,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceM),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                          const SizedBox(width: AppDimensions.spaceS),
                          Text(
                            'الحلول المقترحة:',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spaceS),
                      _buildSolutionItem('تأكد من اتصالك بالإنترنت'),
                      _buildSolutionItem('تحقق من تسجيل دخولك إلى Google Drive'),
                      _buildSolutionItem('تأكد من صحة النسخة الاحتياطية المختارة'),
                      _buildSolutionItem('حاول مرة أخرى بعد قليل'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _restoreFromCloud(backup);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  /// حذف نسخة احتياطية سحابية (Google Drive)
  Future<void> _deleteCloudBackup(DriveBackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'حذف نسخة احتياطية',
        message: 'هل تريد حذف النسخة الاحتياطية "${backup.name}"؟\nلا يمكن التراجع عن هذا الإجراء.',
        confirmText: 'نعم، احذف',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    try {
      await _backupService.deleteCloudBackup(backup.id);
      
      setState(() {
        _cloudBackups.remove(backup);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف النسخة الاحتياطية بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _logger.error('فشل حذف النسخة السحابية', error: e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الحذف: $e'),
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
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text('النسخ الاحتياطي', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.phone_android), text: 'محلي'),
              Tab(icon: Icon(Icons.cloud), text: 'سحابي'),
            ],
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

    return Stack(
      children: [
        TabBarView(
          controller: _tabController,
          children: [
            _buildLocalBackupTab(),
            _buildCloudBackupTab(),
          ],
        ),

        // مؤشر التحميل أثناء العمليات
        if (_isBackingUp || _isRestoring) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLocalBackupTab() {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات توضيحية
              _buildInfoBox(
                icon: Icons.info_outline,
                text: 'يتم حفظ النسخ المحلية على جهازك وسيتم رفعها للسحابة تلقائياً',
                color: AppColors.info,
              ),

              const SizedBox(height: AppDimensions.spaceL),

              // زر النسخ الاحتياطي
              _buildActionButton(
                icon: Icons.backup,
                title: 'نسخ احتياطي الآن',
                subtitle: _lastBackupDate != null
                    ? 'آخر نسخة: ${_formatDate(_lastBackupDate!)}'
                    : 'لم يتم إنشاء نسخة بعد',
                color: AppColors.primary,
                onTap: () => _backupNow(uploadToDrive: true),
              ),

              const SizedBox(height: AppDimensions.spaceM),

              // زر النسخ المحلي فقط
              _buildActionButton(
                icon: Icons.save_alt,
                title: 'نسخ محلي مع اختيار الموقع',
                subtitle: 'حفظ على الجهاز في موقع من اختيارك',
                color: AppColors.info,
                onTap: _backupToLocalWithPicker,
              ),

              const SizedBox(height: AppDimensions.spaceL),

              // قسم الاستعادة
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.restore,
                          color: AppColors.warning,
                          size: AppDimensions.iconM,
                        ),
                        const SizedBox(width: AppDimensions.spaceS),
                        Text(
                          'استعادة البيانات',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    _buildRestoreButton(
                      icon: Icons.folder_open,
                      title: 'استعادة من ملف محلي',
                      subtitle: 'اختر ملف النسخة من جهازك',
                      onTap: _restoreFromLocalFile,
                    ),
                    const SizedBox(height: AppDimensions.spaceS),
                    _buildRestoreButton(
                      icon: Icons.cloud_download,
                      title: 'استعادة من Google Drive',
                      subtitle: 'اذهب للتبويب السحابي لاختيار النسخة',
                      onTap: () {
                        _tabController.animateTo(1);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceL),

              // النسخ الاحتياطي التلقائي
              _buildAutoBackupSection(state),

              const SizedBox(height: AppDimensions.spaceXL),

              // معلومات إضافية
              _buildInfoSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCloudBackupTab() {
    return RefreshIndicator(
      onRefresh: _loadCloudBackups,
      child: _isLoadingCloudBackups
          ? const Center(child: CircularProgressIndicator())
          : _cloudBackups.isEmpty
              ? _buildEmptyCloudBackups()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  itemCount: _cloudBackups.length,
                  itemBuilder: (context, index) {
                    final backup = _cloudBackups[index];
                    return _buildCloudBackupCard(backup);
                  },
                ),
    );
  }

  Widget _buildCloudBackupCard(DriveBackupInfo backup) {
    final isRecent = backup.isRecent;
    final isOld = backup.isOld;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecent
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isRecent
                    ? AppColors.success.withOpacity(0.1)
                    : isOld
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.cloud_download,
                color: isRecent
                    ? AppColors.success
                    : isOld
                        ? AppColors.warning
                        : AppColors.primary,
              ),
            ),
            if (isRecent)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                backup.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRecent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'جديد',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            if (isOld && !isRecent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'قديم',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.storage,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  backup.sizeFormatted,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    backup.timeAgo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  backup.formattedDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'restore') {
              _restoreFromCloud(backup);
            } else if (value == 'delete') {
              _deleteCloudBackup(backup);
            } else if (value == 'info') {
              _showBackupInfo(backup);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('استعادة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  SizedBox(width: 8),
                  Text('معلومات'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.danger),
                  SizedBox(width: 8),
                  Text('حذف'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupInfo(DriveBackupInfo backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Text(
                'معلومات النسخة الاحتياطية',
                style: AppTextStyles.titleMedium,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoDetailRow('الاسم', backup.name, Icons.label),
              _buildInfoDetailRow('الحجم', backup.sizeFormatted, Icons.storage),
              _buildInfoDetailRow('تاريخ الإنشاء', backup.formattedDate, Icons.calendar_today),
              _buildInfoDetailRow('منذ', backup.timeAgo, Icons.access_time),
              _buildInfoDetailRow('معرف الملف', backup.id, Icons.fingerprint),
              if (backup.description != null && backup.description!.isNotEmpty)
                _buildInfoDetailRow('الوصف', backup.description!, Icons.description),
              const SizedBox(height: AppDimensions.spaceM),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: backup.isRecent
                      ? AppColors.success.withOpacity(0.1)
                      : backup.isOld
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: backup.isRecent
                        ? AppColors.success.withOpacity(0.3)
                        : backup.isOld
                            ? AppColors.warning.withOpacity(0.3)
                            : AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      backup.isRecent
                          ? Icons.check_circle
                          : backup.isOld
                              ? Icons.warning_amber_rounded
                              : Icons.info_outline,
                      color: backup.isRecent
                          ? AppColors.success
                          : backup.isOld
                              ? AppColors.warning
                              : AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spaceS),
                    Expanded(
                      child: Text(
                        backup.isRecent
                            ? 'نسخة حديثة (أقل من 24 ساعة)'
                            : backup.isOld
                                ? 'نسخة قديمة (أكثر من 30 يوم)'
                                : 'نسخة صالحة',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: backup.isRecent
                              ? AppColors.success
                              : backup.isOld
                                  ? AppColors.warning
                                  : AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreFromCloud(backup);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.info),
          const SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCloudBackups() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: AppDimensions.spaceL),
          Text(
            'لا توجد نسخ احتياطية سحابية',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            'قم بإنشاء نسخة احتياطية لرفعها للسحابة',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    String progressMessage = 'جارِ التحضير...';
    
    if (_isRestoring) {
      if (_downloadProgress < 0.1) {
        progressMessage = '🛡️ إنشاء نسخة احتياطية للحماية...';
      } else if (_downloadProgress < 0.6) {
        progressMessage = '⬇️ تحميل النسخة من Google Drive...';
      } else if (_downloadProgress < 0.7) {
        progressMessage = '✅ تم التحميل بنجاح';
      } else if (_downloadProgress < 0.8) {
        progressMessage = '🔍 التحقق من صحة البيانات...';
      } else if (_downloadProgress < 0.85) {
        progressMessage = '🔒 إغلاق قاعدة البيانات...';
      } else if (_downloadProgress < 0.9) {
        progressMessage = '🔄 استبدال قاعدة البيانات...';
      } else if (_downloadProgress < 0.95) {
        progressMessage = '🔓 إعادة فتح قاعدة البيانات...';
      } else {
        progressMessage = '✅ التحقق النهائي...';
      }
    }
    
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isBackingUp
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _isBackingUp ? _uploadProgress : _downloadProgress,
                        strokeWidth: 5,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isBackingUp ? AppColors.primary : AppColors.info,
                        ),
                      ),
                    ),
                    Icon(
                      _isBackingUp ? Icons.cloud_upload : Icons.cloud_download,
                      color: _isBackingUp ? AppColors.primary : AppColors.info,
                      size: 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),
              Text(
                _isBackingUp ? 'جارِ النسخ الاحتياطي...' : 'جارِ الاستعادة...',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),
              Text(
                progressMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceL),
              
              if (_isBackingUp && _uploadProgress > 0) ...[
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'رفع للسحابة',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (_isRestoring && _downloadProgress > 0) ...[
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.info),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم الكلي',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: AppDimensions.spaceL),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spaceS),
                    Expanded(
                      child: Text(
                        'الرجاء الانتظار، لا تغلق التطبيق',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconM),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.arrow_back_ios, size: 16),
      ),
    );
  }

  Widget _buildRestoreButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoBackupSection(SettingsLoaded state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
        title: const Text('النسخ الاحتياطي التلقائي'),
        subtitle: const Text('نسخ احتياطي يومي تلقائي'),
        value: state.autoBackupEnabled,
        onChanged: (value) {
          context.read<SettingsBloc>().add(ToggleAutoBackup(value));
        },
      ),
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
              Icon(Icons.help_outline, color: AppColors.info, size: AppDimensions.iconM),
              const SizedBox(width: AppDimensions.spaceS),
              Text(
                'معلومات مهمة',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.info),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          _buildInfoItem('النسخ الاحتياطي يشمل جميع البيانات'),
          _buildInfoItem('يتم رفع النسخ تلقائياً لـ Google Drive'),
          _buildInfoItem('يمكنك استعادة البيانات من أي جهاز'),
          _buildInfoItem('النسخ التلقائي يعمل يومياً'),
          _buildInfoItem('البيانات محمية ومشفرة'),
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
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    return '${date.day}/${date.month}/${date.year}';
  }
}
