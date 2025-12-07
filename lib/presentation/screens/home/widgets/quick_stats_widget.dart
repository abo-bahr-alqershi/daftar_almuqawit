import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/daily_statistics.dart';
import '../../../navigation/route_names.dart';

/// ويدجت الإحصائيات السريعة - تصميم راقي ونظيف
class QuickStatsWidget extends StatefulWidget {
  const QuickStatsWidget({
    super.key,
    this.stats,
    this.isLoading = false,
    this.yesterdayStats,
  });

  final DailyStatistics? stats;
  final DailyStatistics? yesterdayStats;
  final bool isLoading;

  @override
  State<QuickStatsWidget> createState() => _QuickStatsWidgetState();
}

class _QuickStatsWidgetState extends State<QuickStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _valueController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _valueController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    _entryController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _valueController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.stats == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildMainCard(),
              const SizedBox(height: 16),
              _buildStatsGrid(),
              const SizedBox(height: 16),
              _buildPerformanceCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, RouteNames.dashboard);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص اليوم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(widget.stats?.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),

            const SizedBox(height: 28),

            // Main Value
            AnimatedBuilder(
              animation: _valueController,
              builder: (context, child) {
                final value =
                    (widget.stats?.netProfit ?? 0) * _valueController.value;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatNumber(value),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'ريال',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // Change Indicator
            _buildChangeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withOpacity(0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'نشط',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator() {
    final isPositive = (widget.stats?.netProfit ?? 0) >= 0;
    final color = isPositive
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _getProfitChangeText(),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'عن أمس',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final statsList = [
      _StatItem(
        title: 'المبيعات',
        value: widget.stats?.totalSales ?? 0,
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF6366F1),
        trend: _calculateTrend('sales'),
      ),
      _StatItem(
        title: 'المشتريات',
        value: widget.stats?.totalPurchases ?? 0,
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFF0EA5E9),
        trend: _calculateTrend('purchases'),
      ),
      _StatItem(
        title: 'المصروفات',
        value: widget.stats?.totalExpenses ?? 0,
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFF59E0B),
        trend: _calculateTrend('expenses'),
      ),
      _StatItem(
        title: 'الديون',
        value:
            (widget.stats?.newDebts ?? 0) + (widget.stats?.collectedDebts ?? 0),
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFFDC2626),
        trend: _calculateTrend('debts'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: statsList.length,
      itemBuilder: (context, index) {
        return _buildStatCard(statsList[index], index);
      },
    );
  }

  Widget _buildStatCard(_StatItem item, int index) {
    return AnimatedBuilder(
      animation: _valueController,
      builder: (context, child) {
        final delay = index * 0.15;
        final progress = ((_valueController.value - delay) / (1 - delay)).clamp(
          0.0,
          1.0,
        );

        return Transform.scale(
          scale: 0.9 + (0.1 * progress),
          child: Opacity(
            opacity: progress,
            child: _StatCard(item: item, valueProgress: progress),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceCard() {
    final percentage = _calculatePerformancePercentage();
    final color = _getPerformanceColor(percentage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Performance Ring
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 6,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(Colors.transparent),
                ),
                AnimatedBuilder(
                  animation: _valueController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: percentage * _valueController.value,
                      strokeWidth: 6,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(color),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Performance Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أداء اليوم',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPerformanceLabel(percentage),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Action Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Color(0xFF6366F1),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildShimmer(height: 180, borderRadius: 20),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildShimmer(height: 100, borderRadius: 16)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmer(height: 100, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmer(height: 100, borderRadius: 16)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmer(height: 100, borderRadius: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer({required double height, required double borderRadius}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.6),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB).withOpacity(value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  // Helper Methods
  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatDate(String? date) {
    final now = DateTime.now();
    final days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    return '${days[now.weekday % 7]}, ${now.day}/${now.month}/${now.year}';
  }

  String _getProfitChangeText() {
    if (widget.stats == null) return '+0%';

    if (widget.yesterdayStats == null) {
      final totalSales = widget.stats!.totalSales;
      final netProfit = widget.stats!.netProfit;
      if (totalSales == 0) return '+0%';
      final profitMargin = (netProfit / totalSales * 100);
      final sign = profitMargin >= 0 ? '+' : '';
      return '$sign${profitMargin.toStringAsFixed(1)}%';
    }

    final todayProfit = widget.stats!.netProfit;
    final yesterdayProfit = widget.yesterdayStats!.netProfit;

    if (yesterdayProfit == 0) {
      return todayProfit > 0
          ? '+100%'
          : todayProfit < 0
          ? '-100%'
          : '+0%';
    }

    final changePercent =
        ((todayProfit - yesterdayProfit) / yesterdayProfit.abs() * 100);
    final sign = changePercent >= 0 ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(1)}%';
  }

  double _calculatePerformancePercentage() {
    if (widget.stats == null) return 0.0;

    final netProfit = widget.stats!.netProfit;
    final totalSales = widget.stats!.totalSales;
    final totalExpenses = widget.stats!.totalExpenses;

    if (totalSales == 0) return 0.0;

    final profitMargin = (netProfit / totalSales).abs();
    final expenseRatio = totalExpenses / totalSales;

    double performance = (profitMargin * 0.7);
    if (expenseRatio < 1) {
      performance += ((1 - expenseRatio) * 0.3);
    }

    if (netProfit < 0) {
      performance = performance * 0.5;
    }

    return performance.clamp(0.0, 1.0);
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 0.6) return const Color(0xFF16A34A);
    if (percentage >= 0.3) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  String _getPerformanceLabel(double percentage) {
    if (percentage >= 0.8) return 'ممتاز';
    if (percentage >= 0.6) return 'جيد جداً';
    if (percentage >= 0.4) return 'جيد';
    if (percentage >= 0.2) return 'مقبول';
    return 'ضعيف';
  }

  double? _calculateTrend(String type) {
    if (widget.stats == null) return null;

    if (widget.yesterdayStats == null) {
      double todayValue = 0;
      switch (type) {
        case 'sales':
          todayValue = widget.stats!.totalSales;
          break;
        case 'purchases':
          todayValue = widget.stats!.totalPurchases;
          break;
        case 'expenses':
          todayValue = widget.stats!.totalExpenses;
          break;
        case 'debts':
          todayValue = widget.stats!.newDebts + widget.stats!.collectedDebts;
          break;
      }
      return todayValue > 0 ? 100.0 : 0.0;
    }

    double today = 0, yesterday = 0;
    switch (type) {
      case 'sales':
        today = widget.stats!.totalSales;
        yesterday = widget.yesterdayStats!.totalSales;
        break;
      case 'purchases':
        today = widget.stats!.totalPurchases;
        yesterday = widget.yesterdayStats!.totalPurchases;
        break;
      case 'expenses':
        today = widget.stats!.totalExpenses;
        yesterday = widget.yesterdayStats!.totalExpenses;
        break;
      case 'debts':
        today = widget.stats!.newDebts + widget.stats!.collectedDebts;
        yesterday =
            widget.yesterdayStats!.newDebts +
            widget.yesterdayStats!.collectedDebts;
        break;
    }

    if (yesterday == 0) return today > 0 ? 100.0 : 0.0;
    return ((today - yesterday) / yesterday * 100);
  }
}

// بطاقة الإحصائية
class _StatCard extends StatelessWidget {
  final _StatItem item;
  final double valueProgress;

  const _StatCard({required this.item, required this.valueProgress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.color, size: 16),
              ),
              if (item.trend != null) _buildTrendBadge(item.trend!),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            item.title,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  (item.value * valueProgress).toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              const Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text(
                  'ر.ي',
                  style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(double trend) {
    final isPositive = trend >= 0;
    final color = isPositive
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${trend.abs().toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final double? trend;

  _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
}
