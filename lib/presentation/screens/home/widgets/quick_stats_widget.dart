import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/daily_statistics.dart';

/// ويدجت الإحصائيات السريعة
class QuickStatsWidget extends StatelessWidget {
  final DailyStatistics? stats;
  final bool isLoading;

  const QuickStatsWidget({
    super.key,
    this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ملخص اليوم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textOnDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stats?.date ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'المبيعات',
                  value: '${stats?.totalSales.toStringAsFixed(0) ?? '0'} ر.ي',
                  icon: Icons.trending_up,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.textOnDark.withOpacity(0.2),
              ),
              Expanded(
                child: _StatItem(
                  label: 'المشتريات',
                  value: '${stats?.totalPurchases.toStringAsFixed(0) ?? '0'} ر.ي',
                  icon: Icons.shopping_cart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'الربح',
                  value: '${stats?.netProfit.toStringAsFixed(0) ?? '0'} ر.ي',
                  icon: Icons.monetization_on,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.textOnDark.withOpacity(0.2),
              ),
              Expanded(
                child: _StatItem(
                  label: 'المصروفات',
                  value: '${stats?.totalExpenses.toStringAsFixed(0) ?? '0'} ر.ي',
                  icon: Icons.money_off,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textOnDark.withOpacity(0.7),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textOnDark.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
