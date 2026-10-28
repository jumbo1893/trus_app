import 'package:flutter/material.dart';

enum PubDrinkType { beer, shot }

/// Small vector illustrations used by the visual pub ledger.
class PubDrinkArt extends StatelessWidget {
  const PubDrinkArt({super.key, required this.type, required this.active});

  final PubDrinkType type;
  final bool active;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(38, 40),
    painter: _PubDrinkPainter(
      type,
      active,
      Theme.of(context).brightness == Brightness.light,
    ),
  );
}

class _PubDrinkPainter extends CustomPainter {
  const _PubDrinkPainter(this.type, this.active, this.light);

  final PubDrinkType type;
  final bool active;
  final bool light;

  static const _outline = Color(0xFFFFF4DD);
  static const _muted = Color(0xFF484351);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 40);
    final line = Paint()
      ..color = light
          ? (active ? const Color(0xFF3B3024) : const Color(0xFF777D87))
          : (active ? _outline : _muted)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    switch (type) {
      case PubDrinkType.beer:
        _paintMug(canvas, line);
      case PubDrinkType.shot:
        _paintShot(canvas, line);
    }
    canvas.restore();
  }

  void _paintMug(Canvas canvas, Paint line) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 11, 23, 25),
      const Radius.circular(3),
    );
    if (active) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 15, 19, 19),
          const Radius.circular(1),
        ),
        Paint()..color = const Color(0xFFFFB529),
      );
    }
    canvas.drawRRect(body, line);
    final handle = Path()
      ..moveTo(29, 15)
      ..lineTo(33, 15)
      ..quadraticBezierTo(37, 15, 37, 19)
      ..lineTo(37, 26)
      ..quadraticBezierTo(37, 30, 33, 30)
      ..lineTo(29, 30);
    canvas.drawPath(handle, line);
    if (active) {
      final foam = Paint()..color = light ? const Color(0xFF3B3024) : _outline;
      canvas.drawOval(const Rect.fromLTWH(6, 8, 11, 7), foam);
      canvas.drawOval(const Rect.fromLTWH(14, 6, 10, 8), foam);
      canvas.drawOval(const Rect.fromLTWH(21, 9, 9, 6), foam);
    }
  }

  void _paintShot(Canvas canvas, Paint line) {
    final glass = Path()
      ..moveTo(10, 17)
      ..lineTo(30, 17)
      ..lineTo(27, 31)
      ..quadraticBezierTo(26.5, 33, 24, 33)
      ..lineTo(16, 33)
      ..quadraticBezierTo(13.5, 33, 13, 31)
      ..close();
    if (active) {
      canvas.save();
      canvas.clipPath(glass);
      canvas.drawRect(
        const Rect.fromLTWH(11, 23, 18, 11),
        Paint()
          ..color = light ? const Color(0xFF48B8AC) : const Color(0xFF7ADCCC),
      );
      canvas.restore();
    }
    canvas.drawPath(glass, line);
    canvas.drawLine(const Offset(10, 17), const Offset(30, 17), line);
    canvas.drawLine(const Offset(15, 34), const Offset(25, 34), line);
  }

  @override
  bool shouldRepaint(covariant _PubDrinkPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.active != active ||
      oldDelegate.light != light;
}
