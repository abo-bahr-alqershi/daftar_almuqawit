import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// مؤشر حالة المزامنة
class SyncIndicator extends StatelessWidget {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final VoidCallback? onTap;

  const SyncIndicator({
    super.key,
    this.isSyncing = false,
    this.lastSyncTime,
    this.onTap,
  });

  String _getLastSyncText() {
    if (lastSyncTime == null) return 'لم يتم المزامنة';
    
    final diff = DateTime.now().difference(lastSyncTime!);
    
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSyncing
                ? AppColors.info.withOpacity(0.1)
                : AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSyncing ? AppColors.info : AppColors.success,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSyncing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                  ),
                )
              else
                Icon(
                  Icons.cloud_done,
                  size: 16,
                  color: AppColors.success,
                ),
              const SizedBox(width: 8),
              Text(
                isSyncing ? 'جاري المزامنة...' : 'تمت المزامنة ${_getLastSyncText()}',
                style: TextStyle(
                  fontSize: 12,
                  color: isSyncing ? AppColors.info : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
