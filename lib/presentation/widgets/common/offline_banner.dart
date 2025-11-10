import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// بانر الاتصال بالإنترنت
/// 
/// يظهر عندما يكون الجهاز غير متصل بالإنترنت
/// لإخبار المستخدم بأنه في وضع عدم الاتصال
class OfflineBanner extends StatelessWidget {
  /// هل متصل بالإنترنت
  final bool isOnline;
  
  /// رسالة عدم الاتصال
  final String offlineMessage;
  
  /// رسالة الاتصال
  final String onlineMessage;
  
  /// لون الخلفية في وضع عدم الاتصال
  final Color? offlineColor;
  
  /// لون الخلفية في وضع الاتصال
  final Color? onlineColor;
  
  /// هل يظهر البانر عند الاتصال
  final bool showOnlineMessage;
  
  /// مدة ظهور رسالة الاتصال
  final Duration onlineMessageDuration;

  const OfflineBanner({
    super.key,
    required this.isOnline,
    this.offlineMessage = 'لا يوجد اتصال بالإنترنت',
    this.onlineMessage = 'تم استعادة الاتصال',
    this.offlineColor,
    this.onlineColor,
    this.showOnlineMessage = true,
    this.onlineMessageDuration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline && !showOnlineMessage) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOnline ? 0 : null,
      child: MaterialBanner(
        backgroundColor: isOnline
            ? (onlineColor ?? AppColors.success)
            : (offlineColor ?? AppColors.danger),
        content: Row(
          children: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              color: AppColors.textOnDark,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isOnline ? onlineMessage : offlineMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ],
        ),
        actions: const [SizedBox.shrink()],
      ),
    );
  }
}

/// ويدجت حالة الاتصال
/// 
/// يعرض معلومات أكثر تفصيلاً عن حالة الاتصال
class ConnectionStatusWidget extends StatelessWidget {
  /// هل متصل بالإنترنت
  final bool isOnline;
  
  /// هل يتم المزامنة حالياً
  final bool isSyncing;
  
  /// عدد العمليات المعلقة
  final int pendingOperations;
  
  /// دالة إعادة المحاولة
  final VoidCallback? onRetry;

  const ConnectionStatusWidget({
    super.key,
    required this.isOnline,
    this.isSyncing = false,
    this.pendingOperations = 0,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? AppColors.success : AppColors.danger,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? 'متصل بالإنترنت' : 'غير متصل بالإنترنت',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (isSyncing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'جاري المزامنة...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (!isOnline && pendingOperations > 0) ...[
            const SizedBox(height: 12),
            Text(
              'لديك $pendingOperations عملية معلقة',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (!isOnline && onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnDark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// مؤشر حالة الاتصال الصغير
/// 
/// مؤشر بسيط يظهر في شريط التطبيق أو في أي مكان آخر
class ConnectionIndicator extends StatelessWidget {
  /// هل متصل بالإنترنت
  final bool isOnline;
  
  /// حجم المؤشر
  final double size;
  
  /// هل يظهر النص
  final bool showLabel;

  const ConnectionIndicator({
    super.key,
    required this.isOnline,
    this.size = 8,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isOnline ? AppColors.success : AppColors.danger,
          shape: BoxShape.circle,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.success : AppColors.danger,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isOnline ? 'متصل' : 'غير متصل',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
