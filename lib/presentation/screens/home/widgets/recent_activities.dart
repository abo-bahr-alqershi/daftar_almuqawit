import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// عرض الأنشطة الأخيرة
class RecentActivities extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivities({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'النشاطات الأخيرة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: activities.length > 5 ? 5 : activities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _ActivityTile(activity: activity);
          },
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (activity.amount != null)
            Text(
              activity.amount!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: activity.color,
              ),
            ),
        ],
      ),
    );
  }
}

/// نموذج عنصر النشاط
class ActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final String? amount;

  const ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
    this.amount,
  });
}
