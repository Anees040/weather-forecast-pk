import 'dart:math';
import 'package:flutter/material.dart';

class WindCompassWidget extends StatelessWidget {
  final double windDegree;
  final String windSpeed;

  const WindCompassWidget({
    Key? key,
    required this.windDegree,
    required this.windSpeed,
  }) : super(key: key);

  String _degreeToDirection(double deg) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((deg + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text(
            'Wind Direction',
            style: TextStyle(
              color: Color(0xFF64FFDA),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _CompassPainter(windDegree),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _degreeToDirection(windDegree),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${windDegree.round()}°',
                      style: TextStyle(
                        color: Colors.white.withAlpha(150),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            windSpeed,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double windDegree;

  _CompassPainter(this.windDegree);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer circle
    final circlePaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Cardinal direction marks
    final markPaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * pi / 180;
      final isCardinal = i % 2 == 0;
      final innerR = isCardinal ? radius - 12 : radius - 8;
      final start = Offset(
        center.dx + innerR * cos(angle),
        center.dy + innerR * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, end, markPaint);
    }

    // Wind direction arrow
    final arrowAngle = (windDegree - 90) * pi / 180;
    final arrowPaint = Paint()
      ..color = const Color(0xFF64FFDA)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final arrowEnd = Offset(
      center.dx + (radius - 16) * cos(arrowAngle),
      center.dy + (radius - 16) * sin(arrowAngle),
    );
    canvas.drawLine(center, arrowEnd, arrowPaint);

    // Arrow tip
    final tipLength = 10.0;
    final tipAngle1 = arrowAngle + 2.6;
    final tipAngle2 = arrowAngle - 2.6;
    canvas.drawLine(
      arrowEnd,
      Offset(
        arrowEnd.dx + tipLength * cos(tipAngle1),
        arrowEnd.dy + tipLength * sin(tipAngle1),
      ),
      arrowPaint,
    );
    canvas.drawLine(
      arrowEnd,
      Offset(
        arrowEnd.dx + tipLength * cos(tipAngle2),
        arrowEnd.dy + tipLength * sin(tipAngle2),
      ),
      arrowPaint,
    );

    // Center dot
    final dotPaint = Paint()..color = const Color(0xFF64FFDA);
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.windDegree != windDegree;
  }
}
