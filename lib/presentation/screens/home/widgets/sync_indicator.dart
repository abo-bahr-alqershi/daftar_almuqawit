import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// مؤشر حالة المزامنة - تصميم راقي ونظيف
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
  late AnimationController _successController;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _updateAnimations();
  }

  @override
  void didUpdateWidget(SyncIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSyncing && !widget.isSyncing) {
      setState(() => _showSuccess = true);
      _successController.forward().then((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _successController.reverse();
            setState(() => _showSuccess = false);
          }
        });
      });
    }

    _updateAnimations();
  }

  void _updateAnimations() {
    if (widget.isSyncing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Color _getSyncColor() {
    if (widget.isSyncing) return const Color(0xFF0EA5E9);
    if (_showSuccess) return const Color(0xFF16A34A);

    if (widget.lastSyncTime == null) return const Color(0xFFF59E0B);

    final diff = DateTime.now().difference(widget.lastSyncTime!);
    if (diff.inMinutes < 5) return const Color(0xFF16A34A);
    if (diff.inHours < 1) return const Color(0xFF0EA5E9);
    if (diff.inDays < 1) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  String _getLastSyncText() {
    if (widget.lastSyncTime == null) return 'لم تتم المزامنة';

    final diff = DateTime.now().difference(widget.lastSyncTime!);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSyncColor();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: widget.showDetails ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(color),
            if (widget.showDetails) ...[
              const SizedBox(width: 10),
              _buildText(color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.isSyncing)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.3)),
            ),
          ),
        AnimatedBuilder(
          animation: Listenable.merge([
            _rotationController,
            _successController,
          ]),
          builder: (context, child) {
            if (_showSuccess) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: _successController,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              );
            }

            return Transform.rotate(
              angle: widget.isSyncing
                  ? _rotationController.value * 2 * math.pi
                  : 0,
              child: Icon(
                widget.isSyncing
                    ? Icons.sync_rounded
                    : Icons.cloud_done_outlined,
                size: 18,
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildText(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.isSyncing
              ? 'جاري المزامنة...'
              : _showSuccess
              ? 'تمت المزامنة!'
              : 'تمت المزامنة',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (!widget.isSyncing && !_showSuccess)
          Text(
            _getLastSyncText(),
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
          ),
      ],
    );
  }
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSyncing ? Icons.sync_rounded : Icons.cloud_done_outlined,
              size: 36,
              color: const Color(0xFF6366F1),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            isSyncing ? 'جاري المزامنة' : 'حالة المزامنة',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),

          if (lastSyncTime != null) ...[
            const SizedBox(height: 6),
            Text(
              'آخر مزامنة: ${_formatDateTime(lastSyncTime!)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],

          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'تمت المزامنة',
                  itemsSynced.toString(),
                  Icons.check_circle_outline,
                  const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'في الانتظار',
                  itemsPending.toString(),
                  Icons.pending_outlined,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sync Button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: isSyncing
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: isSyncing
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        onSync?.call();
                      },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSyncing) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        isSyncing ? 'جاري المزامنة...' : 'بدء المزامنة',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSyncing
                              ? const Color(0xFF9CA3AF)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'قبل ${diff.inSeconds} ثانية';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';

    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
