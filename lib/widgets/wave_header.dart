import 'package:flutter/material.dart';

class WaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 45);

    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.55, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.82, size.height - 70);
    var secondEndPoint = Offset(size.width, size.height - 25);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SecondWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);

    var firstControlPoint = Offset(size.width * 0.35, size.height - 70);
    var firstEndPoint = Offset(size.width * 0.65, size.height - 25);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.88, size.height + 10);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveHeaderWidget extends StatelessWidget {
  final double height;
  final Widget? child;

  const WaveHeaderWidget({
    super.key,
    required this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Base Primary Royal Navy Background (#0F2B66)
          Container(
            height: height,
            color: const Color(0xFF0F2B66),
          ),

          // Layer 1: Overlapping Fluid Wave
          ClipPath(
            clipper: SecondWaveClipper(),
            child: Container(
              height: height,
              color: const Color(0xFF102A5B).withOpacity(0.85),
            ),
          ),

          // Layer 2: Top Organic Wave with Rich Royal Navy -> Accent Blue Gradient
          ClipPath(
            clipper: WaveHeaderClipper(),
            child: Container(
              height: height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F2B66), // Primary Royal Navy (#0F2B66)
                    Color(0xFF102A5B), // Heading Navy (#102A5B)
                    Color(0xFF1E40AF), // Deep Royal Accent
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Radial Glow Spotlight 1 (Top Right - Accent Blue Glow #7FD3FF)
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7FD3FF).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Radial Glow Spotlight 2 (Mid Left - Light Blue Glow #D9F2FF)
          Positioned(
            top: height * 0.25,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD9F2FF).withOpacity(0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Floating Ambient Translucent Glass Orbs
          Positioned(
            top: height * 0.40,
            right: 35,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
              ),
            ),
          ),

          // Child Overlay Content
          if (child != null)
            SafeArea(
              child: child!,
            ),
        ],
      ),
    );
  }

  double sizeWidth(BuildContext context) => MediaQuery.of(context).size.width;
}
