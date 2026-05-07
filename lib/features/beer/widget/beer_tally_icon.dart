import 'package:flutter/material.dart';

class BeerTallyIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BeerTallyIcon({
    super.key,
    this.size = 24,
    this.color = Colors.black,
    this.strokeWidth = 2.8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BeerTallyPainter(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _BeerTallyPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BeerTallyPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // 4 svislé čáry
    final verticals = [
      [w * 0.18, h * 0.18, w * 0.14, h * 0.86],
      [w * 0.38, h * 0.14, w * 0.37, h * 0.90],
      [w * 0.58, h * 0.22, w * 0.56, h * 0.84],
      [w * 0.79, h * 0.10, w * 0.75, h * 0.88],
    ];

    for (final line in verticals) {
      canvas.drawLine(
        Offset(line[0], line[1]),
        Offset(line[2], line[3]),
        paint,
      );
    }

    // přeškrtnutí / vodorovná čára
    canvas.drawLine(
      Offset(w * 0.08, h * 0.52),
      Offset(w * 0.92, h * 0.57),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BeerTallyPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}