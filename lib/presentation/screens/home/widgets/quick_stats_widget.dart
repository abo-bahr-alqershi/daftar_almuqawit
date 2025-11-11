import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/daily_statistics.dart';

/// ويدجت الإحصائيات السريعة - تصميم Tesla/iOS متطور
class QuickStatsWidget extends StatefulWidget {
  const QuickStatsWidget({super.key, this.stats, this.isLoading = false});
  final DailyStatistics? stats;
  final bool isLoading;

  @override
  State<QuickStatsWidget> createState() => _QuickStatsWidgetState();
}

class _QuickStatsWidgetState extends State<QuickStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _numberController;
  late Animation<double> _shimmerAnimation;
  late List<Animation<double>> _numberAnimations;

  int _selectedStatIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _numberController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _initNumberAnimations();
    _numberController.forward();
  }

  void _initNumberAnimations() {
    _numberAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _numberController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _numberController.dispose();
    _pageController.dispose();
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Main Stats Card
          _buildMainStatsCard(),

          const SizedBox(height: 16),

          // Stats Grid
          _buildStatsGrid(),

          const SizedBox(height: 16),

          // Performance Indicator
          _buildPerformanceIndicator(),
        ],
      ),
    );
  }

  Widget _buildMainStatsCard() => Container(
    height: 200,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.4),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
      ],
    ),
    child: Stack(
      children: [
        // Background Pattern
        Positioned.fill(child: CustomPaint(painter: _StatsBackgroundPainter())),

        // Glass Effect
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(24),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
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

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success,
                                blurRadius: 8,
                                spreadRadius: 2,
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
                  ),
                ],
              ),

              const Spacer(),

              // Main Value with Animation
              AnimatedBuilder(
                animation: _numberAnimations[0],
                builder: (context, child) {
                  final value =
                      (widget.stats?.netProfit ?? 0) *
                      _numberAnimations[0].value;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatNumber(value),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'ريال',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 8),

              // Profit Indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '+24.5%',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'عن أمس',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildStatsGrid() {
    final statsList = [
      _StatData(
        title: 'المبيعات',
        value: widget.stats?.totalSales ?? 0,
        icon: Icons.trending_up_rounded,
        color: AppColors.sales,
        trend: 12.5,
      ),
      _StatData(
        title: 'المشتريات',
        value: widget.stats?.totalPurchases ?? 0,
        icon: Icons.shopping_cart_rounded,
        color: AppColors.purchases,
        trend: -5.2,
      ),
      _StatData(
        title: 'المصروفات',
        value: widget.stats?.totalExpenses ?? 0,
        icon: Icons.payment_rounded,
        color: AppColors.expense,
        trend: -8.3,
      ),
      _StatData(
        title: 'الديون',
        value:
            (widget.stats?.newDebts ?? 0) + (widget.stats?.collectedDebts ?? 0),
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.debt,
        trend: 15.7,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: statsList.length,
      itemBuilder: (context, index) {
        final stat = statsList[index];
        return AnimatedBuilder(
          animation: _numberAnimations[index % _numberAnimations.length],
          builder: (context, child) => _ModernStatCard(
            data: stat,
            animation: _numberAnimations[index % _numberAnimations.length],
            onTap: () => setState(() => _selectedStatIndex = index),
            isSelected: _selectedStatIndex == index,
          ),
        );
      },
    );
  }

  Widget _buildPerformanceIndicator() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        // Performance Chart
        SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: _PerformanceChartPainter(
              percentage: 0.75,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Performance Details
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أداء اليوم',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'ممتاز',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Action Button
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.insights_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ],
    ),
  );

  Widget _buildLoadingState() => AnimatedBuilder(
    animation: _shimmerAnimation,
    builder: (context, child) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-2 + _shimmerAnimation.value, 0),
          end: Alignment(-1 + _shimmerAnimation.value, 0),
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
    ),
  );

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatDate(String? date) {
    if (date == null) return '';
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
    return '${days[now.weekday - 1]}, ${now.day}/${now.month}/${now.year}';
  }
}

// بطاقة الإحصائية المحسنة
class _ModernStatCard extends StatelessWidget {
  const _ModernStatCard({
    required this.data,
    required this.animation,
    required this.onTap,
    required this.isSelected,
  });
  final _StatData data;
  final Animation<double> animation;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final animatedValue = data.value * animation.value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? data.color.withOpacity(0.3)
                : AppColors.border.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: data.color.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.color, size: 20),
                ),

                // Trend Indicator
                if (data.trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: data.trend! > 0
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          data.trend! > 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: data.trend! > 0
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        Text(
                          '${data.trend!.abs()}%',
                          style: TextStyle(
                            color: data.trend! > 0
                                ? AppColors.success
                                : AppColors.danger,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      animatedValue.toStringAsFixed(0),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(
                        'ر.ي',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// بيانات الإحصائية
class _StatData {
  _StatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final double? trend;
}

// رسام خلفية الإحصائيات
class _StatsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw circles pattern
    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 60, paint);

    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 80, paint);

    // Draw lines pattern
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width * 0.3, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// رسام مخطط الأداء
class _PerformanceChartPainter extends CustomPainter {
  _PerformanceChartPainter({required this.percentage, required this.color});
  final double percentage;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(percentage * 100).toInt()}%',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
