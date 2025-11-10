import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// ويدجت رسم بياني بالأعمدة
class BarChartWidget extends StatelessWidget {
  final List<AppBarChartData> data;
  final String? title;
  final bool showGrid;
  final Color? barColor;

  const BarChartWidget({
    super.key,
    required this.data,
    this.title,
    this.showGrid = true,
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text('لا توجد بيانات', style: AppTextStyles.bodyMedium));
    }

    return Column(
      children: [
        if (title != null) Text(title!, style: AppTextStyles.headlineSmall),
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(
            BarChartData(
              barGroups: data.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(toY: e.value.value, color: barColor ?? AppColors.primary)],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class AppBarChartData {
  final String label;
  final double value;
  const AppBarChartData({required this.label, required this.value});
}
