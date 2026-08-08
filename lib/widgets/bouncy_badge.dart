import 'package:flutter/material.dart';

/// Micro-interaction badge wrapper that triggers a subtle bounce (180ms) when value changes.
class BouncyBadge extends StatefulWidget {
  final int value;
  final Widget child;
  final Duration duration;

  const BouncyBadge({
    super.key,
    required this.value,
    required this.child,
    this.duration = const Duration(milliseconds: 180),
  });

  @override
  State<BouncyBadge> createState() => _BouncyBadgeState();
}

class _BouncyBadgeState extends State<BouncyBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant BouncyBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
