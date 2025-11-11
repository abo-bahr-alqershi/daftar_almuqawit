import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/google_drive_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/settings/backup_options.dart';
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
  String? _lastBackupPath;

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
        _lastBackupPath = backupPath;
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

  /// استعادة من نسخة سحابية (Google Drive)
  Future<void> _restoreFromCloud(DriveBackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'استعادة من السحابة',
        message:
            'تحذير: سيتم استبدال جميع البيانات الحالية بالنسخة المحفوظة (${backup.name}).\n\nهل تريد المتابعة؟',
        confirmText: 'نعم، استعد',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRestoring = true;
      _downloadProgress = 0.0;
    });

    try {
      _logger.info('بدء استعادة من Google Drive: ${backup.id}');

      await _backupService.restoreFromDrive(
        backup.id,
        onDownloadProgress: (progress) {
          setState(() => _downloadProgress = progress);
        },
      );

      setState(() {
        _isRestoring = false;
        _downloadProgress = 0.0;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('تمت الاستعادة بنجاح ✅\nسيتم إعادة تشغيل التطبيق...'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      // TODO: إعادة تشغيل التطبيق أو الانتقال للشاشة الرئيسية
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      _logger.error('فشلت استعادة البيانات من السحابة', error: e);

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
                title: 'نسخ محلي فقط',
                subtitle: 'حفظ على الجهاز بدون رفع إلى Google Drive',
                color: AppColors.info,
                onTap: () => _backupNow(uploadToDrive: false),
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.cloud_download, color: AppColors.primary),
        ),
        title: Text(
          backup.name,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('الحجم: ${backup.sizeFormatted}', style: AppTextStyles.bodySmall),
            Text(backup.timeAgo, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'restore') {
              _restoreFromCloud(backup);
            } else if (value == 'delete') {
              _deleteCloudBackup(backup);
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
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingWidget.large(),
              const SizedBox(height: AppDimensions.spaceL),
              Text(
                _isBackingUp
                    ? 'جارِ النسخ الاحتياطي...'
                    : 'جارِ الاستعادة...',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spaceM),
              
              if (_isBackingUp && _uploadProgress > 0) ...[
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  'رفع للسحابة: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
              
              if (_isRestoring && _downloadProgress > 0) ...[
                LinearProgressIndicator(value: _downloadProgress),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  'تحميل من السحابة: ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
              
              const SizedBox(height: AppDimensions.spaceM),
              Text(
                'الرجاء الانتظار، لا تغلق التطبيق',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
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
