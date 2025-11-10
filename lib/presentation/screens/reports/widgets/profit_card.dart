/// بطاقة الربح
/// ويدجت لعرض معلومات الربح بشكل جذاب

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// بطاقة الربح
class ProfitCard extends StatelessWidget {
  /// إجمالي الربح
  final double totalProfit;
  
  /// الربح الإجمالي (قبل المصروفات)
  final double grossProfit;
  
  /// الربح الصافي (بعد المصروفات)
  final double netProfit;
  
  /// نسبة هامش الربح
  final double profitMargin;
  
  /// الفترة الزمنية
  final String period;
  
  /// هل يعرض التفاصيل
  final bool showDetails;

  const ProfitCard({
    super.key,
    required this.totalProfit,
    required this.grossProfit,
    required this.netProfit,
    required this.profitMargin,
    required this.period,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = totalProfit >= 0;
    final profitColor = isPositive ? AppColors.success : AppColors.error;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            profitColor,
            profitColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: profitColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الربح',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  period,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // إجمالي الربح
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isPositive 
                  ? Icons.trending_up 
                  : Icons.trending_down,
                color: AppColors.textOnDark,
                size: 40,
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي الربح',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnDark.withOpacity(0.9),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${totalProfit.toStringAsFixed(2)} ر.ي',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // نسبة هامش الربح
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.percent,
                      color: AppColors.textOnDark,
                      size: 20,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${profitMargin.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // التفاصيل
          if (showDetails) ...[
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textOnDark.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'الربح الإجمالي',
                    value: grossProfit,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _DetailRow(
                    label: 'الربح الصافي',
                    value: netProfit,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// صف التفاصيل
class _DetailRow extends StatelessWidget {
  final String label;
  final double value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnDark.withOpacity(0.9),
          ),
        ),
        
        Text(
          '${value.toStringAsFixed(2)} ر.ي',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
