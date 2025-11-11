import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// بطاقة ملخص الإحصائيات - تصميم Tesla/iOS راقي
class SummaryCard extends StatefulWidget {
  const SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
    this.subtitle,
    this.onTap,
    this.percentage,
    this.showChart = false,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  final double? percentage;
  final bool showChart;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _chartController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));

    _chartAnimation = Tween<double>(begin: 0, end: widget.percentage ?? 0.0)
        .animate(
          CurvedAnimation(parent: _chartController, curve: Curves.easeOutCubic),
        );

    _mainController.forward();
    if (widget.showChart) {
      _chartController.forward();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _mainController,
    builder: (context, child) => Transform.scale(
      scale: _scaleAnimation.value,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            if (widget.onTap != null) {
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(_isPressed ? 0.98 : 1.0)
                ..rotateZ(_isHovered ? 0.005 : 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withOpacity(0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isPressed || _isHovered
                      ? widget.color.withOpacity(0.3)
                      : AppColors.border.withOpacity(0.1),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isPressed || _isHovered)
                        ? widget.color.withOpacity(0.15)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: _isPressed ? 25 : 20,
                    offset: Offset(0, _isPressed ? 8 : 6),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 10,
                    offset: const Offset(-3, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (_isHovered) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: widget.color,
                                  ),
                                ],
                              ],
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Icon Container
                      _buildIconContainer(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Value Section
                  _buildValueSection(),

                  // Chart Section
                  if (widget.showChart && widget.percentage != null)
                    _buildChartSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildIconContainer() => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: _isHovered ? 1 : 0),
    duration: const Duration(milliseconds: 300),
    builder: (context, value, child) => Transform.rotate(
      angle: value * 0.1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color.withOpacity(0.2 + value * 0.1),
              widget.color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.2 * value),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(widget.icon, color: widget.color, size: 26),
      ),
    ),
  );

  Widget _buildValueSection() => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
      // Parse numeric value for animation
      final numericValue =
          double.tryParse(widget.value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      final animatedValue = (numericValue * value).toStringAsFixed(0);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            animatedValue,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: widget.color,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.value.replaceAll(RegExp(r'[\d.]'), '').trim(),
              style: TextStyle(
                fontSize: 14,
                color: widget.color.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _buildChartSection() => Container(
    margin: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'معدل الإنجاز',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) => Text(
                '${(_chartAnimation.value * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) => FractionallySizedBox(
              widthFactor: _chartAnimation.value,
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
