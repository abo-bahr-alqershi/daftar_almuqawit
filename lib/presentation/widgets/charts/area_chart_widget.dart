import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

/// ويدجت رسم بياني مساحي
class AreaChartWidget extends StatelessWidget {
  final List<AreaChartDataSet> dataSets;
  final String? title;

  const AreaChartWidget({super.key, required this.dataSets, this.title});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          lineBarsData: dataSets.map((ds) {
            return LineChartBarData(
              spots: ds.data,
              color: ds.color,
              belowBarData: BarAreaData(show: true, color: ds.color.withOpacity(0.3)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class AreaChartDataSet {
  final String label;
  final List<FlSpot> data;
  final Color color;
  const AreaChartDataSet({required this.label, required this.data, required this.color});
}
