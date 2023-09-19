import 'package:flutter/material.dart';
import 'dart:math' as math;

class RunAndKickAnimationScreen extends StatefulWidget {
  const RunAndKickAnimationScreen({super.key});

  @override
  _RunAndKickAnimationScreenState createState() =>
      _RunAndKickAnimationScreenState();
}

class _RunAndKickAnimationScreenState extends State<RunAndKickAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _runAnimation;
  late Animation<double> _kickAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _runAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
    _kickAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              painter: _RunAndKickPainter(
                _runAnimation.value,
                _kickAnimation.value,
              ),
              child: SizedBox(
                width: 200,
                height: 200,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RunAndKickPainter extends CustomPainter {
  final double runAnimationValue;
  final double kickAnimationValue;

  _RunAndKickPainter(this.runAnimationValue, this.kickAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double bodyWidth = 40;
    final double bodyHeight = 80;
    final double legLength = 60;
    final double legWidth = 10;
    final double ballRadius = 20;
    final double shoeWidth = 15;

    final double bodyX = size.width / 2 - bodyWidth / 2;
    final double bodyY = size.height / 2 - bodyHeight / 2;

    final double legX = bodyX + bodyWidth / 2;
    final double legY = bodyY + bodyHeight;

    final double angle = runAnimationValue;
    final double legEndX = legX + legLength * math.sin(angle);
    final double legEndY = legY + legLength * math.cos(angle);

    final double ballX = legEndX;
    final double ballY = legEndY + ballRadius;

    final double shoeX = legEndX - shoeWidth / 2;
    final double shoeY = legEndY + legWidth;

    final Paint bodyPaint = Paint()..color = Colors.blue;
    final Paint legPaint = Paint()..color = Colors.red;
    final Paint ballPaint = Paint()..color = Colors.black;
    final Paint shoePaint = Paint()..color = Colors.black;

    canvas.drawRect(
      Rect.fromLTRB(bodyX, bodyY, bodyX + bodyWidth, bodyY + bodyHeight),
      bodyPaint,
    );
    canvas.drawLine(
      Offset(legX, legY),
      Offset(legEndX, legEndY),
      legPaint,
    );
    canvas.drawCircle(Offset(ballX, ballY), ballRadius, ballPaint);
    canvas.drawRect(
      Rect.fromLTRB(shoeX, shoeY, shoeX + shoeWidth, shoeY + legWidth),
      shoePaint,
    );
  }

  @override
  bool shouldRepaint(_RunAndKickPainter oldDelegate) {
    return runAnimationValue != oldDelegate.runAnimationValue ||
        kickAnimationValue != oldDelegate.kickAnimationValue;
  }
}
