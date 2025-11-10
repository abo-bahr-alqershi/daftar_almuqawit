import 'package:flutter/material.dart';

/// تأثير التكبير/التصغير
class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double begin;
  final double end;
  final Curve curve;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.begin = 0.0,
    this.end = 1.0,
    this.curve = Curves.elasticOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }
}
