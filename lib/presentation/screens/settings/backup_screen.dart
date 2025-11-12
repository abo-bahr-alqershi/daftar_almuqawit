import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_state.dart';

/// شاشة النسخ الاحتياطي - تصميم راقي هادئ
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _backupService = sl<BackupService>();
  final _logger = sl<LoggerService>();

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
      _showMessage('تم إنشاء النسخة الاحتياطية بنجاح');
    } catch (e) {
      setState(() => _isBackingUp = false);
      if (!mounted) return;
      _showMessage('فشل إنشاء النسخة الاحتياطية', isError: true);
    }
  }

  Future<void> _restore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'استعادة البيانات',
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
      }

      setState(() => _isRestoring = false);
      if (!mounted) return;
      _showMessage('تمت استعادة البيانات بنجاح');
    } catch (e) {
      setState(() => _isRestoring = false);
      if (!mounted) return;
      _showMessage('فشل استعادة البيانات', isError: true);
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
              child: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary, size: 20),
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
            icon: Icons.backup_rounded,
            label: 'إنشاء نسخة احتياطية',
            subtitle: 'حفظ نسخة من بياناتك الحالية',
            color: AppColors.success,
            isLoading: _isBackingUp,
            onTap: _backupNow,
          ),
          const SizedBox(height: 12),
          _ActionButton(
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
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
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
          colors: [
            color.withOpacity(0.12),
            color.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () {
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
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.08),
              ],
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
