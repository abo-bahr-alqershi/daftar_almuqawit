import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/debt.dart';

/// الخط الزمني للدين
class DebtTimeline extends StatelessWidget {
  final Debt debt;

  const DebtTimeline({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final events = _buildTimelineEvents();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return TimelineTile(
          isFirst: index == 0,
          isLast: index == events.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 40,
            color: event.color,
            iconStyle: IconStyle(
              iconData: event.icon,
              color: AppColors.textOnDark,
            ),
          ),
          beforeLineStyle: LineStyle(color: event.color.withOpacity(0.3)),
          endChild: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(event.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(_formatDate(event.date), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TimelineEvent> _buildTimelineEvents() {
    final events = <TimelineEvent>[
      TimelineEvent(
        title: 'إنشاء الدين',
        description: 'تم إنشاء الدين بمبلغ ${debt.totalAmount.toStringAsFixed(0)} ريال',
        date: debt.createdAt,
        icon: Icons.add_circle,
        color: AppColors.primary,
      ),
    ];

    for (final payment in debt.payments) {
      events.add(
        TimelineEvent(
          title: 'دفعة',
          description: 'تم دفع ${payment.amount.toStringAsFixed(0)} ريال',
          date: payment.paymentDate,
          icon: Icons.payment,
          color: AppColors.success,
        ),
      );
    }

    if (debt.remainingAmount == 0) {
      events.add(
        TimelineEvent(
          title: 'تم السداد',
          description: 'تم سداد الدين بالكامل',
          date: debt.payments.last.paymentDate,
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
      );
    }

    return events;
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

class TimelineEvent {
  final String title;
  final String description;
  final DateTime date;
  final IconData icon;
  final Color color;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.color,
  });
}
