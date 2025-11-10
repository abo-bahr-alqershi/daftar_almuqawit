import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// بطاقة حالة المزامنة
/// تعرض معلومات عن حالة المزامنة مع Firebase
class SyncStatusCard extends StatelessWidget {
  /// هل جاري المزامنة حالياً
  final bool isSyncing;
  
  /// وقت آخر مزامنة ناجحة
  final DateTime? lastSyncTime;
  
  /// عدد العناصر المنتظرة للمزامنة
  final int pendingItemsCount;
  
  /// رسالة حالة المزامنة
  final String? syncMessage;
  
  /// هل توجد أخطاء في المزامنة
  final bool hasErrors;
  
  /// رسالة الخطأ
  final String? errorMessage;
  
  /// عند الضغط على زر المزامنة اليدوية
  final VoidCallback? onManualSync;

  const SyncStatusCard({
    super.key,
    required this.isSyncing,
    this.lastSyncTime,
    required this.pendingItemsCount,
    this.syncMessage,
    this.hasErrors = false,
    this.errorMessage,
    this.onManualSync,
  });

  /// الحصول على لون الحالة
  Color _getStatusColor() {
    if (hasErrors) return AppColors.danger;
    if (isSyncing) return AppColors.info;
    if (pendingItemsCount > 0) return AppColors.warning;
    return AppColors.success;
  }

  /// الحصول على أيقونة الحالة
  IconData _getStatusIcon() {
    if (hasErrors) return Icons.error_outline;
    if (isSyncing) return Icons.sync;
    if (pendingItemsCount > 0) return Icons.cloud_upload;
    return Icons.cloud_done;
  }

  /// الحصول على نص الحالة
  String _getStatusText() {
    if (hasErrors) return 'خطأ في المزامنة';
    if (isSyncing) return 'جاري المزامنة...';
    if (pendingItemsCount > 0) return 'في انتظار المزامنة';
    return 'تمت المزامنة';
  }

  /// تنسيق وقت آخر مزامنة
  String _formatLastSync() {
    if (lastSyncTime == null) return 'لم تتم المزامنة بعد';
    
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);

    if (difference.inSeconds < 60) {
      return 'منذ لحظات';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else {
      return 'منذ ${difference.inDays} أيام';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            children: [
              // أيقونة الحالة مع أنيميشن
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: isSyncing
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.info,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        _getStatusIcon(),
                        color: statusColor,
                        size: 28,
                      ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة المزامنة',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // زر المزامنة اليدوية
              if (onManualSync != null && !isSyncing)
                IconButton(
                  onPressed: onManualSync,
                  icon: const Icon(Icons.refresh),
                  color: AppColors.primary,
                  tooltip: 'مزامنة يدوية',
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceL),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.spaceL),

          // معلومات المزامنة
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.schedule,
                  label: 'آخر مزامنة',
                  value: _formatLastSync(),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: _InfoItem(
                  icon: Icons.pending_actions,
                  label: 'في الانتظار',
                  value: pendingItemsCount.toString(),
                  valueColor: pendingItemsCount > 0 
                      ? AppColors.warning 
                      : AppColors.success,
                ),
              ),
            ],
          ),

          // رسالة المزامنة
          if (syncMessage != null) ...[
            const SizedBox(height: AppDimensions.spaceM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppDimensions.spaceS),
                  Expanded(
                    child: Text(
                      syncMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // رسالة الخطأ
          if (hasErrors && errorMessage != null) ...[
            const SizedBox(height: AppDimensions.spaceM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.danger.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: AppDimensions.spaceS),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// عنصر معلومات
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppDimensions.spaceS),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
