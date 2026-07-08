import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveWidget extends StatefulWidget {
  final double percentage; // 0 to 100
  final double size;
  final Color waterColor;
  final Color? waveColor2;

  const WaveWidget({
    super.key,
    required this.percentage,
    this.size = 200.0,
    this.waterColor = const Color(0xFF0288D1), // Deep blue
    this.waveColor2,
  });

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finalWaveColor2 = widget.waveColor2 ?? widget.waterColor.withOpacity(0.5);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.waterColor.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Border (Reservoir Wall)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blueGrey.withOpacity(0.2),
                width: 6,
              ),
            ),
          ),
          
          // Animated Wave
          ClipPath(
            clipper: _CircleClipper(),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _WavePainter(
                    percentage: widget.percentage,
                    animValue: _controller.value,
                    waveColor1: widget.waterColor,
                    waveColor2: finalWaveColor2,
                  ),
                );
              },
            ),
          ),
          
          // Center Text Percentage
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${widget.percentage.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: widget.size * 0.16,
                  fontWeight: FontWeight.bold,
                  color: widget.percentage > 50 ? Colors.white : Colors.blueGrey.shade800,
                  shadows: [
                    if (widget.percentage > 50)
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                  ],
                ),
              ),
              Text(
                "STORAGE",
                style: TextStyle(
                  fontSize: widget.size * 0.055,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: widget.percentage > 55 ? Colors.white70 : Colors.blueGrey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _WavePainter extends CustomPainter {
  final double percentage;
  final double animValue;
  final Color waveColor1;
  final Color waveColor2;

  _WavePainter({
    required this.percentage,
    required this.animValue,
    required this.waveColor1,
    required this.waveColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Normalizing level height: percentage 0 is bottom (height), percentage 100 is top (0)
    final double targetHeight = height * (1 - (percentage / 100.0));

    final paint1 = Paint()
      ..color = waveColor2
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = waveColor1
      ..style = PaintingStyle.fill;

    final path1 = Path();
    final path2 = Path();

    // Wave configurations
    const double waveFrequency = 1.8; // Number of waves across width
    const double waveAmplitude = 8.0; // Wave peak-to-trough height

    path1.moveTo(0, height);
    path2.moveTo(0, height);

    // Calculate wave paths
    for (double x = 0; x <= width; x++) {
      // First wave (moves left-to-right)
      final double wave1Offset = animValue * 2 * math.pi;
      final double y1 = targetHeight +
          math.sin((x / width * 2 * math.pi * waveFrequency) + wave1Offset) * waveAmplitude;
      path1.lineTo(x, y1);

      // Second wave (moves right-to-left, offset slightly)
      final double wave2Offset = -animValue * 2 * math.pi + math.pi / 2;
      final double y2 = targetHeight +
          math.sin((x / width * 2 * math.pi * waveFrequency) + wave2Offset) * (waveAmplitude * 0.85) - 3;
      path2.lineTo(x, y2);
    }

    // Close paths at bottom corners
    path1.lineTo(width, height);
    path1.lineTo(0, height);
    path1.close();

    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    // Draw the two waves
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.animValue != animValue;
  }
}
