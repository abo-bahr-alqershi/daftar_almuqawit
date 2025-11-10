/// ويدجت المخطط البياني
/// ويدجت لعرض المخططات البيانية في التقارير

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// نوع المخطط
enum ChartType {
  /// مخطط خطي
  line,
  
  /// مخطط شريطي
  bar,
  
  /// مخطط دائري
  pie,
}

/// بيانات نقطة في المخطط
class ChartDataPoint {
  /// التسمية
  final String label;
  
  /// القيمة
  final double value;
  
  /// اللون (اختياري)
  final Color? color;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
  });
}

/// ويدجت المخطط البياني
class ChartWidget extends StatelessWidget {
  /// عنوان المخطط
  final String title;
  
  /// نوع المخطط
  final ChartType chartType;
  
  /// بيانات المخطط
  final List<ChartDataPoint> data;
  
  /// ارتفاع المخطط
  final double height;
  
  /// لون أساسي للمخطط
  final Color primaryColor;

  const ChartWidget({
    super.key,
    required this.title,
    required this.chartType,
    required this.data,
    this.height = 250,
    this.primaryColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان المخطط
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // المخطط
          SizedBox(
            height: height,
            child: _buildChart(),
          ),
          
          const SizedBox(height: 16),
          
          // مفتاح المخطط
          _buildLegend(),
        ],
      ),
    );
  }

  /// بناء المخطط حسب النوع
  Widget _buildChart() {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات لعرضها',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    switch (chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
    }
  }

  /// بناء مخطط خطي
  Widget _buildLineChart() {
    // TODO: تكامل مع مكتبة fl_chart
    return Center(
      child: Text(
        'مخطط خطي (قيد التطوير)',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// بناء مخطط شريطي
  Widget _buildBarChart() {
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final dataPoint = entry.value;
        final heightRatio = dataPoint.value / maxValue;
        final barColor = dataPoint.color ?? 
          _getColorForIndex(index);
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // القيمة فوق الشريط
                Text(
                  dataPoint.value.toStringAsFixed(0),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // الشريط
                Container(
                  height: (height - 60) * heightRatio,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        barColor,
                        barColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // التسمية
                Text(
                  dataPoint.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// بناء مخطط دائري
  Widget _buildPieChart() {
    // TODO: تكامل مع مكتبة fl_chart
    return Center(
      child: Text(
        'مخطط دائري (قيد التطوير)',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// بناء مفتاح المخطط
  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final dataPoint = entry.value;
        final color = dataPoint.color ?? _getColorForIndex(index);
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            
            const SizedBox(width: 6),
            
            Text(
              dataPoint.label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// الحصول على لون لمؤشر معين
  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.primary,
      AppColors.sales,
      AppColors.purchases,
      AppColors.expense,
      AppColors.debt,
      AppColors.accent,
    ];
    
    return colors[index % colors.length];
  }
}
