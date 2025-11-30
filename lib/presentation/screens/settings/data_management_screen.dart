import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/sync/storage_sync_coordinator.dart';
import '../../../core/services/sync/sync_status_monitor.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';

/// شاشة إدارة البيانات - المزامنة والنسخ الاحتياطي
/// 
/// توضح الفرق بين:
/// 1. المزامنة (Firebase Storage) - للتحديث المستمر بين الأجهزة
/// 2. النسخ الاحتياطي (Google Drive) - للاستعادة الكاملة عند الحاجة
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen>
    with SingleTickerProviderStateMixin {
  // الخدمات
  final _backupService = sl<BackupService>();
  final _syncCoordinator = StorageSyncCoordinator.instance;
  final _logger = sl<LoggerService>();
  late final SyncStatusMonitor _syncMonitor;

  // Tabs
  late TabController _tabController;
  int _currentTab = 0;

  // حالات الشاشة
  bool _isLoading = false;
  DateTime? _lastBackupDate;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  double _uploadProgress = 0.0;
  double _downloadProgress = 0.0;

  // قائمة النسخ الاحتياطية
  List<DriveBackupInfo> _driveBackups = [];
  bool _isLoadingBackups = false;

  @override
  void initState() {
    super.initState();
    _syncMonitor = SyncStatusMonitor();
    _syncMonitor.startMonitoring();
    
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
        if (_currentTab == 2 && _driveBackups.isEmpty) {
          _loadDriveBackups();
        }
      }
    });
    
    _loadSettings();
  }

  @override
  void dispose() {
    _syncMonitor.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// تحميل الإعدادات
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = sl<SharedPreferencesService>();
      final lastBackupStr = prefs.getString(StorageKeys.lastBackupTime);

      setState(() {
        _lastBackupDate = lastBackupStr != null ? DateTime.tryParse(lastBackupStr) : null;
        _isLoading = false;
      });
    } catch (e) {
      _logger.error('فشل تحميل الإعدادات', error: e);
      setState(() => _isLoading = false);
    }
  }

  /// تحميل قائمة النسخ الاحتياطية من Google Drive
  Future<void> _loadDriveBackups() async {
    setState(() => _isLoadingBackups = true);

    try {
      final backups = await _backupService.getDriveBackups();
      setState(() {
        _driveBackups = backups;
        _isLoadingBackups = false;
      });
      _logger.info('تم تحميل ${backups.length} نسخة احتياطية من Google Drive');
    } catch (e) {
      _logger.error('فشل تحميل النسخ الاحتياطية من Google Drive', error: e);
      setState(() => _isLoadingBackups = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل النسخ: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// نسخ احتياطي إلى Google Drive
  Future<void> _backupToDrive() async {
    // التحقق من تسجيل الدخول أولاً
    if (!_backupService.isSignedInToDrive) {
      _logger.info('🔐 محاولة تسجيل الدخول إلى Google Drive...');
      
      // محاولة تسجيل دخول صامت أولاً
      bool signedIn = await _backupService.signInToGoogleDrive();
      
      if (!signedIn) {
        if (!mounted) return;
        
        // طلب تسجيل دخول من المستخدم
        final shouldSignIn = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تسجيل الدخول إلى Google Drive'),
            content: const Text(
              'للنسخ الاحتياطي على Google Drive، يجب تسجيل الدخول إلى حساب Google الخاص بك.\n\n'
              'سيتم استخدام هذا الحساب فقط لحفظ النسخ الاحتياطية.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        );
        
        if (shouldSignIn != true) return;
        
        // محاولة تسجيل الدخول
        signedIn = await _backupService.signInToGoogleDrive();
        
        if (!signedIn) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل تسجيل الدخول إلى Google Drive\nتحقق من الإعدادات والاتصال بالإنترنت'),
              backgroundColor: AppColors.danger,
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }
        
        _logger.info('✅ تم تسجيل الدخول بنجاح');
      }
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'نسخ احتياطي إلى Google Drive',
        message: 'سيتم إنشاء نسخة احتياطية كاملة ورفعها إلى:\n\n${_backupService.isSignedInToDrive ? "✅ " : ""}Google Drive\n\nهل تريد المتابعة؟',
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
      _logger.info('📦 بدء النسخ الاحتياطي...');
      
      final fileId = await _backupService.createBackupToDrive(
        onUploadProgress: (progress) {
          setState(() => _uploadProgress = progress);
          _logger.info('📤 تقدم الرفع: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      _logger.info('✅ تم رفع النسخة بنجاح! File ID: $fileId');

      // حفظ وقت آخر نسخة
      final now = DateTime.now();
      final prefs = sl<SharedPreferencesService>();
      await prefs.setString(StorageKeys.lastBackupTime, now.toIso8601String());
      await prefs.setString(StorageKeys.lastBackupFileId, fileId);

      setState(() {
        _lastBackupDate = now;
        _isBackingUp = false;
        _uploadProgress = 0.0;
      });

      _loadDriveBackups();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ تم إنشاء النسخة الاحتياطية ورفعها إلى Google Drive بنجاح!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'عرض',
            textColor: Colors.white,
            onPressed: () {
              // الانتقال إلى تبويب النسخ الاحتياطية
              _tabController.animateTo(2);
            },
          ),
        ),
      );
    } catch (e) {
      _logger.error('❌ فشل النسخ الاحتياطي إلى Google Drive', error: e);

      setState(() {
        _isBackingUp = false;
        _uploadProgress = 0.0;
      });

      if (!mounted) return;

      String errorMessage = 'فشل النسخ الاحتياطي: $e';
      
      // رسائل خطأ أكثر وضوحاً
      if (e.toString().contains('DEVELOPER_ERROR')) {
        errorMessage = 'خطأ في الإعدادات\nيُرجى مراجعة GOOGLE_DRIVE_SETUP.md';
      } else if (e.toString().contains('sign_in_required')) {
        errorMessage = 'يجب تسجيل الدخول إلى Google Drive أولاً';
      } else if (e.toString().contains('network')) {
        errorMessage = 'تحقق من الاتصال بالإنترنت';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: Colors.white,
            onPressed: () => _backupToDrive(),
          ),
        ),
      );
    }
  }

  /// استعادة من Google Drive
  Future<void> _restoreFromDrive(DriveBackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'استعادة من Google Drive',
        message: 'تحذير: سيتم استبدال جميع البيانات الحالية بالنسخة المحفوظة (${backup.name}).\n\nهل تريد المتابعة؟',
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
          content: Text('تمت الاستعادة بنجاح ✅\nسيتم إعادة تشغيل التطبيق...'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(seconds: 3));
      // TODO: إعادة تشغيل التطبيق
    } catch (e) {
      _logger.error('فشلت الاستعادة من Google Drive', error: e);

      setState(() {
        _isRestoring = false;
        _downloadProgress = 0.0;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشلت الاستعادة: $e'),
          backgroundColor: AppColors.danger,
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
          title: const Text('إدارة البيانات', style: TextStyle(color: Colors.white)),
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
              Tab(icon: Icon(Icons.info_outline), text: 'معلومات'),
              Tab(icon: Icon(Icons.sync), text: 'المزامنة'),
              Tab(icon: Icon(Icons.backup), text: 'نسخ احتياطي'),
            ],
          ),
        ),
        body: _isLoading
            ? const LoadingWidget.large(message: 'جارِ التحميل...')
            : Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(),
                      _buildSyncTab(),
                      _buildBackupTab(),
                    ],
                  ),
                  if (_isBackingUp || _isRestoring) _buildLoadingOverlay(),
                ],
              ),
      ),
    );
  }

  // ========== التبويبات ==========

  /// تبويب المعلومات
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionCard(
            title: '🔄 المزامنة (Firebase Storage)',
            icon: Icons.sync,
            color: AppColors.info,
            children: [
              _buildInfoItem('تحديث مستمر للبيانات بين جميع أجهزتك'),
              _buildInfoItem('يعمل تلقائياً في الخلفية'),
              _buildInfoItem('يتطلب اتصال بالإنترنت'),
              _buildInfoItem('مثالي للعمل من أكثر من جهاز'),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceL),
          _buildSectionCard(
            title: '📦 النسخ الاحتياطي (Google Drive)',
            icon: Icons.backup,
            color: AppColors.success,
            children: [
              _buildInfoItem('نسخة كاملة من قاعدة البيانات'),
              _buildInfoItem('يُحفظ على Google Drive'),
              _buildInfoItem('للاستعادة عند فقدان البيانات'),
              _buildInfoItem('يُنفذ يدوياً أو بجدولة'),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceL),
          _buildSectionCard(
            title: '💡 نصيحة',
            icon: Icons.tips_and_updates,
            color: AppColors.warning,
            children: [
              _buildInfoItem('فعّل المزامنة للعمل من عدة أجهزة'),
              _buildInfoItem('أنشئ نسخة احتياطية بشكل دوري'),
              _buildInfoItem('احفظ نسخة احتياطية قبل التحديثات الكبيرة'),
            ],
          ),
        ],
      ),
    );
  }

  /// تبويب المزامنة
  Widget _buildSyncTab() {
    return SyncStatusWidget(
      monitor: _syncMonitor,
      builder: (context, status, syncInfo) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حالة المزامنة
              _buildSyncStatusCard(status, syncInfo),
              
              const SizedBox(height: AppDimensions.spaceL),

              // زر المزامنة الفورية
              ElevatedButton.icon(
                onPressed: status == SyncStatus.syncing
                    ? null
                    : () => _syncMonitor.triggerSync(),
                icon: const Icon(Icons.sync),
                label: const Text('مزامنة الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceM),

              // المزامنة التلقائية
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is! SettingsLoaded) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    child: SwitchListTile(
                      title: const Text('المزامنة التلقائية'),
                      subtitle: const Text('تفعيل المزامنة الدورية كل 15 دقيقة'),
                      value: syncInfo?.autoSyncEnabled ?? false,
                      onChanged: (value) {
                        if (value) {
                          _syncMonitor.enableAutoSync();
                        } else {
                          _syncMonitor.disableAutoSync();
                        }
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// تبويب النسخ الاحتياطي
  Widget _buildBackupTab() {
    return RefreshIndicator(
      onRefresh: _loadDriveBackups,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حالة تسجيل الدخول
            _buildDriveAccountCard(),
            
            const SizedBox(height: AppDimensions.spaceL),

            // زر النسخ الاحتياطي
            ElevatedButton.icon(
              onPressed: _backupToDrive,
              icon: const Icon(Icons.backup),
              label: const Text('نسخ احتياطي إلى Google Drive'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(AppDimensions.paddingM),
              ),
            ),

            if (_lastBackupDate != null) ...[
              const SizedBox(height: AppDimensions.spaceM),
              Text(
                'آخر نسخة: ${_formatDate(_lastBackupDate!)}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: AppDimensions.spaceXL),

            // قائمة النسخ الاحتياطية
            Text(
              'النسخ الاحتياطية المتاحة',
              style: AppTextStyles.titleMedium,
            ),

            const SizedBox(height: AppDimensions.spaceM),

            if (_isLoadingBackups)
              const Center(child: CircularProgressIndicator())
            else if (_driveBackups.isEmpty)
              _buildEmptyBackups()
            else
              ..._driveBackups.map((backup) => _buildBackupCard(backup)).toList(),
          ],
        ),
      ),
    );
  }

  /// بطاقة حساب Google Drive
  Widget _buildDriveAccountCard() {
    final isSignedIn = _backupService.isSignedInToDrive;
    final email = isSignedIn ? 'مسجل الدخول' : 'غير مسجل';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isSignedIn ? AppColors.success : AppColors.textSecondary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSignedIn ? Icons.check_circle : Icons.cloud_off,
                color: isSignedIn ? AppColors.success : AppColors.textSecondary,
                size: 30,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حساب Google Drive',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSignedIn)
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.danger),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => const ConfirmDialog(
                      title: 'تسجيل الخروج',
                      message: 'هل تريد تسجيل الخروج من Google Drive؟\n\nستحتاج إلى تسجيل الدخول مرة أخرى للنسخ الاحتياطي.',
                      confirmText: 'نعم',
                      cancelText: 'إلغاء',
                      isDestructive: true,
                    ),
                  );

                  if (confirmed == true) {
                    await _backupService.signOutFromGoogleDrive();
                    setState(() {});
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تسجيل الخروج من Google Drive'),
                        ),
                      );
                    }
                  }
                },
                tooltip: 'تسجيل الخروج',
              )
            else
              TextButton.icon(
                onPressed: () async {
                  final success = await _backupService.signInToGoogleDrive();
                  if (success) {
                    setState(() {});
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم تسجيل الدخول بنجاح'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('فشل تسجيل الدخول'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('تسجيل الدخول'),
              ),
          ],
        ),
      ),
    );
  }

  // ========== Widgets المساعدة ==========

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppDimensions.spaceS),
                Expanded(
                  child: Text(title, style: AppTextStyles.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: Text(text, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusCard(SyncStatus status, SyncInfo? info) {
    IconData icon;
    Color color;
    String statusText;

    switch (status) {
      case SyncStatus.idle:
        icon = Icons.sync_disabled;
        color = AppColors.textSecondary;
        statusText = 'غير نشط';
        break;
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = AppColors.info;
        statusText = 'جارِ المزامنة...';
        break;
      case SyncStatus.synced:
        icon = Icons.check_circle;
        color = AppColors.success;
        statusText = 'متزامن';
        break;
      case SyncStatus.error:
        icon = Icons.error;
        color = AppColors.danger;
        statusText = 'خطأ في المزامنة';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: AppDimensions.spaceM),
            Text(statusText, style: AppTextStyles.titleMedium.copyWith(color: color)),
            if (info?.lastSyncTime != null) ...[
              const SizedBox(height: AppDimensions.spaceS),
              Text(
                'آخر مزامنة: ${info!.lastSyncFormatted}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(DriveBackupInfo backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.backup, color: AppColors.primary),
        ),
        title: Text(backup.name, style: AppTextStyles.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحجم: ${backup.sizeFormatted}', style: AppTextStyles.bodySmall),
            Text(backup.timeAgo, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'restore') {
              _restoreFromDrive(backup);
            } else if (value == 'delete') {
              // TODO: حذف النسخة
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('استعادة'),
                ],
              ),
            ),
            PopupMenuItem(
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

  Widget _buildEmptyBackups() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 60, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            'لا توجد نسخ احتياطية',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                _isBackingUp ? 'جارِ النسخ الاحتياطي...' : 'جارِ الاستعادة...',
                style: AppTextStyles.titleMedium,
              ),
              if (_isBackingUp && _uploadProgress > 0) ...[
                const SizedBox(height: AppDimensions.spaceM),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  'رفع: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
              if (_isRestoring && _downloadProgress > 0) ...[
                const SizedBox(height: AppDimensions.spaceM),
                LinearProgressIndicator(value: _downloadProgress),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  'تحميل: ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
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
