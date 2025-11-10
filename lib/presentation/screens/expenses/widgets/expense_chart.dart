import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// رسم بياني للمصروفات
/// 
/// يعرض المصروفات في شكل رسم بياني دائري حسب الفئات
class ExpenseChart extends StatelessWidget {
  final Map<String, double> expensesByCategory;

  const ExpenseChart({
    super.key,
    required this.expensesByCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (expensesByCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد بيانات لعرضها',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _buildSections(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = expensesByCategory.values.fold(0.0, (sum, value) => sum + value);
    final colors = _getCategoryColors();

    int index = 0;
    return expensesByCategory.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 50,
        titleStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textOnDark,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = _getCategoryColors();
    int index = 0;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: expensesByCategory.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.key,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${entry.value.toStringAsFixed(0)})',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Color> _getCategoryColors() {
    return [
      AppColors.primary,
      AppColors.warning,
      AppColors.success,
      AppColors.info,
      AppColors.danger,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
  }
}
