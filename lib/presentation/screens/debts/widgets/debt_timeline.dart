import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/debt.dart';

class DebtTimeline extends StatefulWidget {
  final Debt debt;

  const DebtTimeline({super.key, required this.debt});

  @override
  State<DebtTimeline> createState() => _DebtTimelineState();
}

class _DebtTimelineState extends State<DebtTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = _buildTimelineEvents();

    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final isFirst = index == 0;
          final isLast = index == events.length - 1;
          final delay = index * 100;

          return _buildTimelineItem(
            event: event,
            isFirst: isFirst,
            isLast: isLast,
            delay: delay,
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem({
    required TimelineEvent event,
    required bool isFirst,
    required bool isLast,
    required int delay,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (delay / 1200).clamp(0.0, 1.0),
            ((delay + 400) / 1200).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (delay / 1200).clamp(0.0, 1.0),
              ((delay + 400) / 1200).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    if (!isFirst)
                      Expanded(
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                event.color.withOpacity(0.3),
                                event.color.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 20),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            event.color,
                            event.color.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: event.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        event.icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                event.color.withOpacity(0.1),
                                event.color.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : 24,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showEventDetails(event);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: event.color.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: event.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _formatDate(event.date),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: event.color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          if (event.amount != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    event.color.withOpacity(0.1),
                                    event.color.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on_rounded,
                                    color: event.color,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'المبلغ:',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${Formatters.formatCurrency(event.amount!)} ريال',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: event.color,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textHint.withOpacity(0.1),
                  AppColors.textHint.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timeline_rounded,
              size: 64,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد أحداث',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم عرض الخط الزمني للدين هنا',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<TimelineEvent> _buildTimelineEvents() {
    final events = <TimelineEvent>[];

    try {
      final createdDate = DateTime.parse(widget.debt.createdAt);
      events.add(
        TimelineEvent(
          title: 'إنشاء الدين',
          description: 'تم تسجيل الدين في النظام',
          date: createdDate,
          icon: Icons.add_circle_rounded,
          color: AppColors.primary,
          amount: widget.debt.totalAmount,
        ),
      );
    } catch (e) {
      // ignore invalid date
    }

    final payments = widget.debt.payments ?? [];
    for (var i = 0; i < payments.length; i++) {
      final payment = payments[i];
      try {
        final paymentDate = DateTime.parse(payment.paymentDate ?? '');
        events.add(
          TimelineEvent(
            title: 'دفعة ${i + 1}',
            description: payment.notes?.isNotEmpty == true
                ? payment.notes!
                : 'تم استلام دفعة بطريقة ${payment.paymentMethod ?? "نقدي"}',
            date: paymentDate,
            icon: Icons.payment_rounded,
            color: AppColors.success,
            amount: payment.amount,
          ),
        );
      } catch (e) {
        // ignore invalid payment date
      }
    }

    if (widget.debt.remainingAmount == 0 && payments.isNotEmpty) {
      try {
        final lastPaymentDate =
            DateTime.parse(payments.last.paymentDate ?? '');
        events.add(
          TimelineEvent(
            title: 'تم السداد الكامل',
            description: 'تم سداد كامل مبلغ الدين بنجاح',
            date: lastPaymentDate,
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            amount: widget.debt.totalAmount,
          ),
        );
      } catch (e) {
        // ignore invalid date
      }
    } else if (widget.debt.status == 'مسدد جزئي') {
      events.add(
        TimelineEvent(
          title: 'دين نشط',
          description:
              'المبلغ المتبقي: ${Formatters.formatCurrency(widget.debt.remainingAmount ?? 0.0)} ريال',
          date: DateTime.now(),
          icon: Icons.pending_actions_rounded,
          color: AppColors.warning,
          amount: widget.debt.remainingAmount,
        ),
      );
    } else if (widget.debt.status == 'غير مسدد') {
      final isOverdue = _isOverdue();
      events.add(
        TimelineEvent(
          title: isOverdue ? 'دين متأخر' : 'دين غير مسدد',
          description: isOverdue
              ? 'تجاوز الدين تاريخ الاستحقاق المحدد'
              : 'في انتظار الدفع',
          date: DateTime.now(),
          icon: isOverdue
              ? Icons.warning_rounded
              : Icons.hourglass_empty_rounded,
          color: isOverdue ? AppColors.danger : AppColors.warning,
          amount: widget.debt.totalAmount,
        ),
      );
    }

    events.sort((a, b) => a.date.compareTo(b.date));

    return events;
  }

  bool _isOverdue() {
    if (widget.debt.dueDate == null) return false;
    try {
      final dueDate = DateTime.parse(widget.debt.dueDate!);
      return dueDate.isBefore(DateTime.now()) &&
          (widget.debt.remainingAmount ?? 0.0) > 0;
    } catch (e) {
      return false;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? "أسبوع" : "أسابيع"}';
    } else {
      final months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  void _showEventDetails(TimelineEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [event.color, event.color.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                event.icon,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              event.title,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (event.amount != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      event.color.withOpacity(0.1),
                      event.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'المبلغ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.formatCurrency(event.amount!)} ريال',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: event.color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _formatFullDate(event.date),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class TimelineEvent {
  final String title;
  final String description;
  final DateTime date;
  final IconData icon;
  final Color color;
  final double? amount;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.color,
    this.amount,
  });
}
