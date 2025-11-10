import 'package:flutter/material.dart';

/// تأثير الظهور التدريجي
class FadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeIn,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}
