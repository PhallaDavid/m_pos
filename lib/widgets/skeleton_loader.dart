import 'package:flutter/material.dart';

/// A custom, lightweight Shimmer animation wrapper for Flutter without external packages.
/// Uses Flutter's native [AnimationController] and [LinearGradient] to sweep light across placeholder shapes.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0), // Slate 200
    this.highlightColor = const Color(0xFFF8FAFC), // Slate 50
    this.duration = const Duration(milliseconds: 1500),
  });

  /// Shimmer variant optimized for dark containers/cards (e.g. Sales Revenue Card)
  factory AppShimmer.dark({
    Key? key,
    required Widget child,
  }) {
    return AppShimmer(
      key: key,
      baseColor: Colors.white.withOpacity(0.12),
      highlightColor: Colors.white.withOpacity(0.30),
      duration: const Duration(milliseconds: 1500),
      child: child,
    );
  }

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0, 0);
  }
}

/// A basic rectangular skeleton block with customizable dimensions and border radius.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A circular skeleton placeholder (e.g. for user avatars, icon backgrounds).
class SkeletonCircle extends StatelessWidget {
  final double size;
  final Color? color;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A text-line skeleton placeholder.
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const SkeletonText({
    super.key,
    required this.width,
    this.height = 14.0,
    this.borderRadius = 4.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
      color: color,
    );
  }
}
