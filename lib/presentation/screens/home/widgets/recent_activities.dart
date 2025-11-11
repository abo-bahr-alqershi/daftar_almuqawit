import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// عرض النشاطات الأخيرة - تصميم Tesla/iOS متطور
class RecentActivities extends StatefulWidget {
  const RecentActivities({required this.activities, super.key, this.onViewAll});
  final List<ActivityItem> activities;
  final VoidCallback? onViewAll;

  @override
  State<RecentActivities> createState() => _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _headerAnimationController;
  late List<Animation<double>> _itemAnimations;
  late Animation<double> _headerSlideAnimation;

  bool _isExpanded = false;
  int _displayCount = 5;

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _initItemAnimations();

    _headerAnimationController.forward();
    _listAnimationController.forward();
  }

  void _initItemAnimations() {
    _itemAnimations = List.generate(
      math.min(widget.activities.length, 10),
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _listAnimationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
      return _buildEmptyState();
    }

    final displayActivities = widget.activities.take(_displayCount).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          AnimatedBuilder(
            animation: _headerSlideAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _headerSlideAnimation.value),
              child: _buildHeader(),
            ),
          ),

          const SizedBox(height: 16),

          // Activities List
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            child: Column(
              children: [
                ...displayActivities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;

                  if (index >= _itemAnimations.length) {
                    return _ModernActivityCard(
                      activity: activity,
                      onTap: () => _showActivityDetails(activity),
                    );
                  }

                  return AnimatedBuilder(
                    animation: _itemAnimations[index],
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                        50 * (1 - _itemAnimations[index].value),
                        0,
                      ),
                      child: Opacity(
                        opacity: _itemAnimations[index].value,
                        child: Transform.scale(
                          scale: 0.95 + (_itemAnimations[index].value * 0.05),
                          child: _ModernActivityCard(
                            activity: activity,
                            onTap: () => _showActivityDetails(activity),
                            index: index,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Load More Button
                if (widget.activities.length > 5) _buildLoadMoreButton(),
              ],
            ),
          ),

          // Summary Section
          if (widget.activities.isNotEmpty) _buildSummarySection(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        // Icon with Pulse Animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) => Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(value * 0.2),
                  blurRadius: 20 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            child: const Icon(
              Icons.timeline_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'النشاطات الأخيرة',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.activities.length} نشاط جديد',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // View All Button
        _buildViewAllButton(),
      ],
    ),
  );

  Widget _buildViewAllButton() => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      if (widget.onViewAll != null) {
        widget.onViewAll!();
      } else {
        Navigator.of(context).pushNamed('/activities');
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Text(
            'عرض الكل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
        ],
      ),
    ),
  );

  Widget _buildLoadMoreButton() => Container(
    margin: const EdgeInsets.only(top: 16),
    child: TextButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        setState(() {
          _isExpanded = !_isExpanded;
          _displayCount = _isExpanded ? widget.activities.length : 5;
        });
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: AppColors.primary.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isExpanded ? 'عرض أقل' : 'عرض المزيد',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(
              Icons.expand_more_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSummarySection() {
    final totalAmount = widget.activities.where((a) => a.amount != null).fold(
      0.0,
      (sum, a) {
        final amountStr = a.amount!.replaceAll(RegExp(r'[^\d.]'), '');
        return sum + (double.tryParse(amountStr) ?? 0);
      },
    );

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.accent.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem(
            'إجمالي المعاملات',
            '${widget.activities.length}',
            Icons.receipt_long_rounded,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border.withOpacity(0.2),
          ),
          _buildSummaryItem(
            'القيمة الإجمالية',
            '${totalAmount.toStringAsFixed(0)} ريال',
            Icons.payments_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) =>
      Expanded(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        // Animated Empty Icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Container(
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
              child: const Icon(
                Icons.inbox_rounded,
                size: 40,
                color: AppColors.textHint,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'لا توجد نشاطات',
          style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        const Text(
          'ستظهر هنا جميع نشاطاتك الأخيرة',
          style: TextStyle(color: AppColors.textHint, fontSize: 14),
        ),
      ],
    ),
  );

  void _showActivityDetails(ActivityItem activity) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityDetailsSheet(activity: activity),
    );
  }
}

// بطاقة النشاط المحسنة
class _ModernActivityCard extends StatefulWidget {
  const _ModernActivityCard({required this.activity, this.onTap, this.index});
  final ActivityItem activity;
  final VoidCallback? onTap;
  final int? index;

  @override
  State<_ModernActivityCard> createState() => _ModernActivityCardState();
}

class _ModernActivityCardState extends State<_ModernActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isImportant =
        widget.activity.amount != null &&
        double.tryParse(
              widget.activity.amount!.replaceAll(RegExp(r'[^\d.]'), ''),
            ) !=
            null &&
        double.parse(
              widget.activity.amount!.replaceAll(RegExp(r'[^\d.]'), ''),
            ) >
            5000;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isPressed
                    ? widget.activity.color.withOpacity(0.3)
                    : isImportant
                    ? widget.activity.color.withOpacity(0.15)
                    : AppColors.border.withOpacity(0.1),
                width: _isPressed ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isImportant
                      ? widget.activity.color.withOpacity(0.08)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: _isPressed ? 20 : 12,
                  offset: Offset(0, _isPressed ? 6 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Background Gradient for Important Items
                  if (isImportant)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.activity.color,
                              widget.activity.color.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon Container
                        Hero(
                          tag:
                              'activity-icon-${widget.index ?? widget.activity.hashCode}',
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.activity.color.withOpacity(0.15),
                                  widget.activity.color.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  widget.activity.icon,
                                  color: widget.activity.color,
                                  size: 26,
                                ),
                                if (isImportant)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.success,
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.activity.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.activity.time,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                  if (widget.activity.status != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          widget.activity.status!,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.activity.status!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _getStatusColor(
                                            widget.activity.status!,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Amount
                        if (widget.activity.amount != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.activity.amount!.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: widget.activity.color,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                widget.activity.amount!.split(' ').last,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.activity.color.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(width: 8),

                        // Arrow
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textHint.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),

                  // Ripple Effect
                  if (_isPressed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: widget.activity.color.withOpacity(0.05),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'مكتمل':
      case 'completed':
        return AppColors.success;
      case 'معلق':
      case 'pending':
        return AppColors.warning;
      case 'ملغي':
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
}

// Sheet تفاصيل النشاط
class _ActivityDetailsSheet extends StatelessWidget {
  const _ActivityDetailsSheet({required this.activity});
  final ActivityItem activity;

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.85,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: Column(
      children: [
        // Handle Bar
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
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [activity.color.withOpacity(0.05), Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activity.color.withOpacity(0.15),
                      activity.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(activity.icon, color: activity.color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.time,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildDetailSection('تفاصيل المعاملة', [
                  _DetailItem('المبلغ', activity.amount ?? '0 ريال'),
                  _DetailItem('الحالة', activity.status ?? 'مكتمل'),
                  _DetailItem('رقم المرجع', '#${activity.hashCode}'),
                  _DetailItem('طريقة الدفع', 'نقدي'),
                ]),

                const SizedBox(height: 24),

                _buildDetailSection('معلومات إضافية', [
                  _DetailItem(
                    'التاريخ',
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  ),
                  _DetailItem(
                    'الوقت',
                    '${DateTime.now().hour}:${DateTime.now().minute}',
                  ),
                  _DetailItem('المستخدم', 'المدير'),
                  _DetailItem('الفرع', 'الرئيسي'),
                ]),

                const SizedBox(height: 24),

                _buildDetailSection('الملاحظات', [
                  _DetailItem('', 'لا توجد ملاحظات مسجلة'),
                ]),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Actions
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    // تعديل النشاط
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text(
                    'تعديل',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: HapticFeedback.lightImpact,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.border.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text(
                    'مشاركة',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const IconButton(
                  onPressed: HapticFeedback.mediumImpact,
                  icon: Icon(Icons.delete_rounded, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildDetailSection(String title, List<_DetailItem> items) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...items.map(
              (item) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.label.isNotEmpty)
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

// نموذج عنصر النشاط
class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
    this.amount,
    this.status,
  });
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final String? amount;
  final String? status;
}

// عنصر التفاصيل
class _DetailItem {
  _DetailItem(this.label, this.value);
  final String label;
  final String value;
}
