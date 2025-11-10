import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// ويدجت رسم بياني دائري
class PieChartWidget extends StatelessWidget {
  final List<PieChartData> data;
  final bool showPercentages;
  final bool showLegend;
  final double radius;
  final String? title;

  const PieChartWidget({
    super.key,
    required this.data,
    this.showPercentages = true,
    this.showLegend = true,
    this.radius = 100,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات للعرض',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
        ],
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sections: data.map((item) {
                final percentage = (item.value / total * 100);
                return PieChartSectionData(
                  value: item.value,
                  title: showPercentages ? '${percentage.toStringAsFixed(1)}%' : '',
                  color: item.color,
                  radius: radius,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }
}

class PieChartData {
  final String label;
  final double value;
  final Color color;
  const PieChartData({required this.label, required this.value, required this.color});
}
