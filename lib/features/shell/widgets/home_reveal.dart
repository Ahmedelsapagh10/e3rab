import 'package:flutter/material.dart';

class HomeReveal extends StatelessWidget {
  const HomeReveal({super.key, required this.child, this.delay = 0});

  final Widget child;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 700),
      curve: Interval(delay.clamp(0, 0.65), 1, curve: Curves.easeOutCubic),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, reduceMotion ? 0 : 18 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
