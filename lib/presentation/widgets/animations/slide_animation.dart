import 'package:flutter/material.dart';

/// تأثير الانزلاق
class SlideAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Offset end;
  final Curve curve;

  const SlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.begin = const Offset(0, 0.5),
    this.end = Offset.zero,
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(value.dx * 100, value.dy * 100), child: child);
      },
      child: child,
    );
  }
}
