import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';

/// مؤشر حالة المزامنة - تصميم Tesla/iOS متطور
class SyncIndicator extends StatefulWidget {
  const SyncIndicator({
    super.key,
    this.isSyncing = false,
    this.lastSyncTime,
    this.onTap,
    this.showDetails = true,
  });
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final VoidCallback? onTap;
  final bool showDetails;

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScaleAnimation;

  bool _showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _updateAnimationState();
  }

  @override
  void didUpdateWidget(SyncIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSyncing && !widget.isSyncing) {
      _showSuccessAnimation = true;
      _successController.forward().then((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _showSuccessAnimation = false);
            _successController.reverse();
          }
        });
      });
    }

    _updateAnimationState();
  }

  void _updateAnimationState() {
    if (widget.isSyncing) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
    } else {
      _rotationController.stop();
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  String _getLastSyncText() {
    if (widget.lastSyncTime == null) return 'لم تتم المزامنة';

    final diff = DateTime.now().difference(widget.lastSyncTime!);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
  }

  Color _getSyncColor() {
    if (widget.isSyncing) return AppColors.info;
    if (_showSuccessAnimation) return AppColors.success;

    if (widget.lastSyncTime == null) return AppColors.warning;

    final diff = DateTime.now().difference(widget.lastSyncTime!);
    if (diff.inMinutes < 5) return AppColors.success;
    if (diff.inHours < 1) return AppColors.info;
    if (diff.inDays < 1) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final syncColor = _getSyncColor();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: widget.showDetails ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [syncColor.withOpacity(0.1), syncColor.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: syncColor.withOpacity(0.3)),
          boxShadow: [
            if (widget.isSyncing || _showSuccessAnimation)
              BoxShadow(
                color: syncColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Section
            _buildIconSection(syncColor),

            if (widget.showDetails) ...[
              const SizedBox(width: 10),

              // Text Section
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.isSyncing
                          ? 'جاري المزامنة...'
                          : _showSuccessAnimation
                          ? 'تمت المزامنة!'
                          : 'تمت المزامنة',
                      style: TextStyle(
                        fontSize: 13,
                        color: syncColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (!widget.isSyncing && !_showSuccessAnimation)
                      Text(
                        _getLastSyncText(),
                        style: TextStyle(
                          fontSize: 11,
                          color: syncColor.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconSection(Color syncColor) => Stack(
    alignment: Alignment.center,
    children: [
      // Pulse Animation
      if (widget.isSyncing)
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: syncColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

      // Main Icon
      AnimatedBuilder(
        animation: Listenable.merge([
          _rotationAnimation,
          _successScaleAnimation,
        ]),
        builder: (context, child) {
          if (_showSuccessAnimation) {
            return Transform.scale(
              scale: _successScaleAnimation.value,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            );
          }

          return Transform.rotate(
            angle: widget.isSyncing ? _rotationAnimation.value : 0,
            child: Icon(
              widget.isSyncing ? Icons.sync_rounded : Icons.cloud_done_rounded,
              size: 20,
              color: syncColor,
            ),
          );
        },
      ),

      // Progress Indicator
      if (widget.isSyncing)
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              syncColor.withOpacity(0.3),
            ),
          ),
        ),
    ],
  );
}

/// نافذة تفاصيل المزامنة
class SyncDetailsSheet extends StatelessWidget {
  const SyncDetailsSheet({
    required this.isSyncing,
    super.key,
    this.lastSyncTime,
    this.itemsSynced = 0,
    this.itemsPending = 0,
    this.onSync,
  });
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int itemsSynced;
  final int itemsPending;
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSyncing ? Icons.sync_rounded : Icons.cloud_done_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                isSyncing ? 'جاري المزامنة' : 'حالة المزامنة',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              if (lastSyncTime != null)
                Text(
                  'آخر مزامنة: ${_formatDateTime(lastSyncTime!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'تمت المزامنة',
                  value: itemsSynced.toString(),
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'في الانتظار',
                  value: itemsPending.toString(),
                  icon: Icons.pending_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: isSyncing ? null : onSync,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSyncing) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  isSyncing ? 'جاري المزامنة...' : 'بدء المزامنة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    ),
  );

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'قبل ${diff.inSeconds} ثانية';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';

    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// بطاقة الإحصائيات
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}
