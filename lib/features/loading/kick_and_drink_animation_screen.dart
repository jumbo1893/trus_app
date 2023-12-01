import 'package:flutter/material.dart';
import 'package:trus_app/features/loading/paint/beer_paint.dart';
import 'package:trus_app/features/loading/paint/goal_paint.dart';
import 'package:trus_app/features/loading/paint/table_paint.dart';
import 'package:trus_app/features/loading/ticketprovider/my_ticket_provider_factory.dart';
import 'dart:math' as math;

import 'ball_bounce.dart';
import 'body_tween_sequence_components.dart';
import 'figure_lines_calculator.dart';
import 'loading_animation_status.dart';

class RunAndKickAnimationScreen extends StatefulWidget {
  const RunAndKickAnimationScreen({super.key});

  @override
  State<RunAndKickAnimationScreen> createState() =>
      _RunAndKickAnimationScreenState();
}

class _RunAndKickAnimationScreenState extends State<RunAndKickAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bodyController;
  late Animation<double> _ballJumpingAnimation;
  late Animation<double> _kickAnimation;
  late Animation<double> _ballFlyingAnimation;
  late Animation<double> _ballFallingAnimation;
  late Animation<double> _bodyAngle;
  late Animation<double> _leftArmAngle;
  late Animation<double> _leftForearmAngle;
  late Animation<double> _rightArmAngle;
  late Animation<double> _rightForearmAngle;
  late Animation<double> _leftThighAngle;
  late Animation<double> _rightThighAngle;
  late Animation<double> _leftCalfAngle;
  late Animation<double> _rightCalfAngle;
  late Animation<double> _bodyY1;
  final double firstRightLegAngle = 50;
  int numberOfRepetition = 0;
  LoadingAnimationStatus loadingStatus = LoadingAnimationStatus.playerRunning;
  AnimationStatus animationStatus = AnimationStatus.forward;

  @override
  void initState() {
    super.initState();
    final tickerFactory = MyTickerProviderFactory();
    final tickerProvider2 = tickerFactory.createTickerProvider();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addStatusListener((status) {
        animationStatus = status;
        if (status == AnimationStatus.forward) {
          numberOfRepetition++;
        }
        if (status == AnimationStatus.reverse) {
          numberOfRepetition++;
        }
        if (numberOfRepetition == 9) {
          numberOfRepetition = 1;
        }
        if (numberOfRepetition % 8 == 0) {
          loadingStatus = LoadingAnimationStatus.tableLeaving;
          setRunningPlayerAnimation();
        } else if (numberOfRepetition % 7 == 0) {
          loadingStatus = LoadingAnimationStatus.playerDrinking;
          setDrinkingPlayer();
        } else if (numberOfRepetition % 6 == 0) {
          loadingStatus = LoadingAnimationStatus.tableIncoming;
          setRunningPlayerAnimation();
        } else if (numberOfRepetition % 5 == 0) {
          loadingStatus = LoadingAnimationStatus.goalScored;
          setRunningPlayerAnimation();
        } else if (numberOfRepetition % 4 == 0) {
          loadingStatus = LoadingAnimationStatus.ballFlying;
          setCelebratingPlayerAnimation();
        } else if (numberOfRepetition % 3 == 0) {
          loadingStatus = LoadingAnimationStatus.playerShooting;
          setShootingPlayerAnimation();
        } else if (numberOfRepetition % 2 == 0) {
          setRunningPlayerAnimation();
          loadingStatus = LoadingAnimationStatus.goalIncoming;
        } else {
          setRunningPlayerAnimation();
          loadingStatus = LoadingAnimationStatus.playerRunning;
        }
      });
    _bodyController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: tickerProvider2,
    );
    _ballJumpingAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0, 1, curve: BallBounce()),
      reverseCurve: const Interval(0.99, 1, curve: Curves.linear),
    );
    _kickAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );
    _ballFallingAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1, curve: Curves.bounceIn),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.bounceIn),
    );
    _ballFlyingAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1, curve: Curves.easeInOut),
      reverseCurve: const Interval(0.99, 1.0, curve: Curves.linear),
    );
    //_controller.repeat(reverse: true);
    _bodyController.repeat(reverse: false);
    _controller.repeat(reverse: true);
  }

  void setShootingPlayerAnimation() {
    _bodyAngle = TweenSequence(
            BodyTweenSequenceComponents([-10, -10, -10, -10, -10], -10)
                .getTweenComponents())
        .animate(_controller);
    _leftArmAngle = TweenSequence(
            BodyTweenSequenceComponents([60, 30, 5, 30, 50], 70)
                .getTweenComponents())
        .animate(_controller);
    _rightArmAngle = TweenSequence(
            BodyTweenSequenceComponents([-75, -30, -5, -25, -45], -65)
                .getTweenComponents())
        .animate(_controller);
    _leftForearmAngle = TweenSequence(
            BodyTweenSequenceComponents([120, 110, 100, 100, 110], 120)
                .getTweenComponents())
        .animate(_controller);
    _rightForearmAngle = TweenSequence(
            BodyTweenSequenceComponents([120, 90, 60, 30, 0], 0)
                .getTweenComponents())
        .animate(_controller);
    _leftThighAngle = TweenSequence(
            BodyTweenSequenceComponents([50, 20, 5, 5, 5], 5)
                .getTweenComponents())
        .animate(_controller);
    _rightThighAngle = TweenSequence(
            BodyTweenSequenceComponents([-20, -10, 5, 30, 60], 90)
                .getTweenComponents())
        .animate(_controller);
    _leftCalfAngle = TweenSequence(
            BodyTweenSequenceComponents([0, 0, 0, 0, 0], 0)
                .getTweenComponents())
        .animate(_controller);
    _rightCalfAngle = TweenSequence(
            BodyTweenSequenceComponents([-60, -30, -20, -10, 0], 0)
                .getTweenComponents())
        .animate(_controller);
    _bodyY1 = TweenSequence(BodyTweenSequenceComponents([0, 0, 0, 0, 0], 0)
            .getTweenComponents())
        .animate(_controller);
  }

  void setRunningPlayerAnimation() {
    _bodyAngle = TweenSequence(
            BodyTweenSequenceComponents([-10, -10, -10, -10, -10], -10)
                .getTweenComponents())
        .animate(_bodyController);
    _leftArmAngle = TweenSequence(
            BodyTweenSequenceComponents([-75, -95, 15, 30, 35], 60)
                .getTweenComponents())
        .animate(_bodyController);
    _rightArmAngle = TweenSequence(
            BodyTweenSequenceComponents([60, 70, -20, -35, -50], -75)
                .getTweenComponents())
        .animate(_bodyController);
    _leftForearmAngle = TweenSequence(
            BodyTweenSequenceComponents([110, 110, 110, 130, 135], 120)
                .getTweenComponents())
        .animate(_bodyController);
    _rightForearmAngle = TweenSequence(
            BodyTweenSequenceComponents([120, 120, 90, 90, 100], 110)
                .getTweenComponents())
        .animate(_bodyController);
    _leftThighAngle = TweenSequence(
            BodyTweenSequenceComponents([-20, 5, 30, 45, 50], 50)
                .getTweenComponents())
        .animate(_bodyController);
    _rightThighAngle = TweenSequence(BodyTweenSequenceComponents(
                [firstRightLegAngle, 60, 10, -5, -10], -20)
            .getTweenComponents())
        .animate(_bodyController);
    _leftCalfAngle = TweenSequence(
            BodyTweenSequenceComponents([-60, -95, -100, -70, -40], 0)
                .getTweenComponents())
        .animate(_bodyController);
    _rightCalfAngle = TweenSequence(
            BodyTweenSequenceComponents([0, -60, -20, -10, -30], -60)
                .getTweenComponents())
        .animate(_bodyController);
    _bodyY1 = TweenSequence(BodyTweenSequenceComponents([0, 10, 0, -5, -15], 0)
            .getTweenComponents())
        .animate(_bodyController);
  }

  void setDrinkingPlayer() {
    _bodyAngle = TweenSequence(
            BodyTweenSequenceComponents([-10, 0, 0, 0, 0], -10)
                .getTweenComponents())
        .animate(_controller);
    _leftArmAngle = TweenSequence(
            BodyTweenSequenceComponents([60, 40, 70, 70, 40.1], 70)
                .getTweenComponents())
        .animate(_controller);
    _rightArmAngle = TweenSequence(
            BodyTweenSequenceComponents([-75, -30, -15, -15, -15], -65)
                .getTweenComponents())
        .animate(_controller);
    _leftForearmAngle = TweenSequence(
            BodyTweenSequenceComponents([120, 20, 70, 80, 20], 120)
                .getTweenComponents())
        .animate(_controller);
    _rightForearmAngle = TweenSequence(
            BodyTweenSequenceComponents([120, 60, 15, 15, 15], 110)
                .getTweenComponents())
        .animate(_controller);
    _leftThighAngle = TweenSequence(
            BodyTweenSequenceComponents([50, -10, -10, -10, -10], -20)
                .getTweenComponents())
        .animate(_controller);
    _rightThighAngle = TweenSequence(BodyTweenSequenceComponents(
                [-20, 10, 10, 10, 10], firstRightLegAngle)
            .getTweenComponents())
        .animate(_controller);
    _leftCalfAngle = TweenSequence(
            BodyTweenSequenceComponents([0, 0, 0, 0, 0], -60)
                .getTweenComponents())
        .animate(_controller);
    _rightCalfAngle = TweenSequence(BodyTweenSequenceComponents(
                [-60, 0, 0, 0.1, 0.1], 0.1) //větší než 0 = nebude pěna
            .getTweenComponents())
        .animate(_controller);
    _bodyY1 = TweenSequence(BodyTweenSequenceComponents([0, 0, 0.1, 0.2, 0],
                0) //desetinný čárky určujou kdy bude pivo v ruce
            .getTweenComponents())
        .animate(_controller);
  }

  void setCelebratingPlayerAnimation() {
    _bodyAngle = TweenSequence(
            BodyTweenSequenceComponents([-10, 0, -0, 0, -0], -10)
                .getTweenComponents())
        .animate(_controller);
    _leftArmAngle = TweenSequence(
            BodyTweenSequenceComponents([70, 180, 130, 180, 130], 110)
                .getTweenComponents())
        .animate(_controller);
    _rightArmAngle = TweenSequence(
            BodyTweenSequenceComponents([-65, -180, -130, -180, -30], -75)
                .getTweenComponents())
        .animate(_controller);
    _leftForearmAngle = TweenSequence(
            BodyTweenSequenceComponents([120, 0, 30, 0, 60], 120)
                .getTweenComponents())
        .animate(_controller);
    _rightForearmAngle = TweenSequence(
            BodyTweenSequenceComponents([0, 0, 30, 0, 60], 110)
                .getTweenComponents())
        .animate(_controller);
    _leftThighAngle = TweenSequence(
            BodyTweenSequenceComponents([5, -10, -10, -10, -15], -20)
                .getTweenComponents())
        .animate(_controller);
    _rightThighAngle = TweenSequence(BodyTweenSequenceComponents(
                [90, 10, 10, 10, 30], firstRightLegAngle)
            .getTweenComponents())
        .animate(_controller);
    _leftCalfAngle = TweenSequence(
            BodyTweenSequenceComponents([0, 0, 0, -15, -30], -60)
                .getTweenComponents())
        .animate(_controller);
    _rightCalfAngle = TweenSequence(
            BodyTweenSequenceComponents([-0, 0, 0, -10, -10], 0)
                .getTweenComponents())
        .animate(_controller);
    _bodyY1 = TweenSequence(BodyTweenSequenceComponents([0, -15, 0, -15, 0], 0)
            .getTweenComponents())
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bodyController.dispose();
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
                loadingStatus,
                _kickAnimation.value,
                _bodyAngle.value,
                _leftArmAngle.value,
                _rightArmAngle.value,
                _leftForearmAngle.value,
                _rightForearmAngle.value,
                _leftThighAngle.value,
                _rightThighAngle.value,
                _leftCalfAngle.value,
                _rightCalfAngle.value,
                _bodyY1.value,
                firstRightLegAngle,
                _ballJumpingAnimation.value,
                _ballFlyingAnimation.value,
                _ballFallingAnimation.value,
                animationStatus,
              ),
              child: const SizedBox(
                width: 180,
                height: 180,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RunAndKickPainter extends CustomPainter {
  final double kickAnimationValue;
  final double bodyAngleValue;
  final double leftArmAngleValue;
  final double rightArmAngleValue;
  final double leftForearmAngleValue;
  final double rightForearmAngleValue;
  final double leftThighAngleValue;
  final double rightThighAngleValue;
  final double leftCalfAngleValue;
  final double rightCalfAngleValue;
  final double bodyY1Value;
  final double firstRightLegAngle;
  final double ballJumpingAnimationValue;
  final double ballFlyingAnimationValue;
  final double ballFallingAnimationValue;
  final LoadingAnimationStatus status;
  final AnimationStatus animationStatus;

  _RunAndKickPainter(
      this.status,
      this.kickAnimationValue,
      this.bodyAngleValue,
      this.leftArmAngleValue,
      this.rightArmAngleValue,
      this.leftForearmAngleValue,
      this.rightForearmAngleValue,
      this.leftThighAngleValue,
      this.rightThighAngleValue,
      this.leftCalfAngleValue,
      this.rightCalfAngleValue,
      this.bodyY1Value,
      this.firstRightLegAngle,
      this.ballJumpingAnimationValue,
      this.ballFlyingAnimationValue,
      this.ballFallingAnimationValue,
      this.animationStatus);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 10.5
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width / 20
      ..strokeCap = StrokeCap.round;

    final Paint goalPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 10.5
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 30
      ..strokeCap = StrokeCap.round;

    const double ballRadius = 20;
    const double headRadius = 25;
    final double bodyX1 = size.width / 7;
    final double tableX = bodyX1 + size.width / 2.2;
    final double tableLength = size.width / 5;
    final double tableHeight = size.height / 1.5;

    FigureLinesCalculator figure = FigureLinesCalculator(
        size,
        bodyX1,
        bodyY1Value,
        ballRadius,
        bodyAngleValue,
        leftArmAngleValue,
        leftForearmAngleValue,
        rightArmAngleValue,
        rightForearmAngleValue,
        leftThighAngleValue,
        rightThighAngleValue,
        leftCalfAngleValue,
        rightCalfAngleValue,
        firstRightLegAngle);
    figure.calculateComponents();
    final double ballX = figure.ballComponents.dx +
        (size.width - figure.ballComponents.dx) * kickAnimationValue;
    final double ballY =
        figure.ballComponents.dy * (ballJumpingAnimationValue * 0.1 + 0.9);
    if (status == LoadingAnimationStatus.playerRunning) {
      drawMovingFigure(figure, canvas, linePaint, headRadius);
      drawMovingBall(figure, canvas, linePaint, ballX, ballY, ballRadius);
    } else if (status == LoadingAnimationStatus.goalIncoming) {
      drawMovingFigure(figure, canvas, linePaint, headRadius);
      drawMovingBall(figure, canvas, linePaint, ballX, ballY, ballRadius);
      drawMovingGoal(figure, canvas, goalPaint, bodyX1, ballRadius, size);
    } else if (status == LoadingAnimationStatus.playerShooting) {
      drawStandingGoal(figure, canvas, goalPaint, bodyX1, ballRadius, size);
      drawFlyingBall(figure, canvas, linePaint, bodyX1, ballRadius, size);
      drawMovingFigure(figure, canvas, linePaint, headRadius);
    } else if (status == LoadingAnimationStatus.ballFlying) {
      if (animationStatus != AnimationStatus.reverse) {
        drawFlyingBall(figure, canvas, linePaint, bodyX1, ballRadius, size);
      }
      drawStandingGoal(figure, canvas, goalPaint, bodyX1, ballRadius, size);
      drawMovingFigure(figure, canvas, linePaint, headRadius);
      drawFallingBall(figure, canvas, linePaint, bodyX1, ballRadius, size);
    } else if (status == LoadingAnimationStatus.goalScored) {
      drawMovingGoalAway(figure, canvas, goalPaint, bodyX1, ballRadius, size);
      drawMovingFigure(figure, canvas, linePaint, headRadius);
      drawMovingBallAway(figure, canvas, linePaint, bodyX1, ballRadius, size);
    } else if (status == LoadingAnimationStatus.tableIncoming) {
      drawMovingFigure(figure, canvas, linePaint, headRadius);
      drawMovingTable(figure, canvas, goalPaint, bodyX1, tableX, tableLength,
          tableHeight, size);
      drawMovingBeer(
          canvas, goalPaint, tableX, tableLength, tableHeight, bodyX1, size);
    } else if (status == LoadingAnimationStatus.playerDrinking) {
      drawMovingFigure(figure, canvas, linePaint, headRadius);
      drawStandingTable(
          canvas, goalPaint, tableX, tableLength, tableHeight, size);
      drawDrinkingBeer(
          figure, canvas, goalPaint, tableX, tableLength, tableHeight, size);
    } else if (status == LoadingAnimationStatus.tableLeaving) {
      drawMovingFigure(figure, canvas, linePaint, headRadius);
      drawMovingTableAway(
          canvas, goalPaint, tableX, tableLength, tableHeight, size);
      drawMovingBeerAway(
          canvas, goalPaint, tableX, tableLength, tableHeight, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawMovingFigure(FigureLinesCalculator figure, Canvas canvas,
      Paint linePaint, double headRadius) {
    canvas.drawLine(
        figure.bodyComponents[0], figure.bodyComponents[1], linePaint);
    canvas.drawLine(
        figure.leftArmComponents[0], figure.leftArmComponents[1], linePaint);
    canvas.drawLine(
        figure.rightArmComponents[0], figure.rightArmComponents[1], linePaint);
    canvas.drawLine(figure.leftForearmComponents[0],
        figure.leftForearmComponents[1], linePaint);
    canvas.drawLine(figure.rightForearmComponents[0],
        figure.rightForearmComponents[1], linePaint);
    canvas.drawLine(figure.leftThighComponents[0],
        figure.leftThighComponents[1], linePaint);
    canvas.drawLine(figure.rightThighComponents[0],
        figure.rightThighComponents[1], linePaint);
    canvas.drawLine(
        figure.leftCalfComponents[0], figure.leftCalfComponents[1], linePaint);
    canvas.drawLine(figure.rightCalfComponents[0],
        figure.rightCalfComponents[1], linePaint);
    canvas.drawCircle(figure.headComponents, headRadius, linePaint);
  }

  void drawMovingBall(FigureLinesCalculator figure, Canvas canvas,
      Paint linePaint, double ballX, double ballY, double ballRadius) {
    canvas.drawCircle(Offset(ballX, ballY), ballRadius, linePaint);
  }

  void drawStandingBall(FigureLinesCalculator figure, Canvas canvas,
      Paint linePaint, double ballRadius) {
    canvas.drawCircle(
        Offset(figure.ballComponents.dx, figure.ballComponents.dy),
        ballRadius,
        linePaint);
  }

  void drawFlyingBall(FigureLinesCalculator figure, Canvas canvas,
      Paint linePaint, double bodyX1, double ballRadius, Size size) {
    final double goalX = bodyX1 + size.width / 2 + size.width / 1.65;
    final double ballX = figure.ballComponents.dx +
        (goalX - figure.ballComponents.dx) * ballFlyingAnimationValue;
    final double ballY = figure.ballComponents.dy +
        (0 + ballRadius * 3 - figure.ballComponents.dy) *
            (ballFlyingAnimationValue);

    canvas.drawCircle(Offset(ballX, ballY), ballRadius, linePaint);
  }

  void drawFallingBall(FigureLinesCalculator figure, Canvas canvas,
      Paint linePaint, double bodyX1, double ballRadius, Size size) {
    final double goalX = bodyX1 + size.width / 2;
    final double upperRightGoalX = goalX + size.width / 1.3;
    final double bottomRightGoalX = goalX + size.width / 1.75 + size.width / 3;
    final double ballX = upperRightGoalX +
        (upperRightGoalX - bottomRightGoalX) * kickAnimationValue;
    final double ballY = (size.height - ballRadius) +
        (ballRadius * 3 - (size.height - ballRadius)) *
            (ballFallingAnimationValue);
    canvas.drawCircle(Offset(ballX, ballY), ballRadius, linePaint);
  }

  void drawMovingBallAway(FigureLinesCalculator figure, Canvas canvas,
      Paint linePaint, double bodyX1, double ballRadius, Size size) {
    final double goalX = bodyX1 + size.width / 2;
    final double upperRightGoalX = goalX + size.width / 1.3;
    final double leftBottomPostX = goalX + size.width / 1.85;
    final double lineFromLeftToRightUpper = upperRightGoalX -
        leftBottomPostX; //první poloha - stojí pod horním rohem
    final double ballX = (0 - size.width) +
        (goalX + size.width / 1.85 + size.width) *
            (kickAnimationValue - 1).abs();
    final double ballY = size.height - ballRadius;
    canvas.drawCircle(
        Offset(ballX + lineFromLeftToRightUpper, ballY), ballRadius, linePaint);
  }

  void drawMovingGoal(FigureLinesCalculator figure, Canvas canvas,
      Paint goalPaint, double bodyX1, double ballRadius, Size size) {
    final double goalX =
        bodyX1 + (size.width - bodyX1) * kickAnimationValue + size.width / 2;
    Offset leftPostOffset = Offset(goalX + size.width / 1.85, size.height);
    Offset rightPostOffset =
        Offset(goalX + size.width / 1.85 + size.width / 3, size.height);
    GoalPaint goal =
        GoalPaint(leftPostOffset, rightPostOffset, size.height - ballRadius);
    canvas.drawPath(goal.returnGoalPaint(), goalPaint);
  }

  void drawStandingGoal(FigureLinesCalculator figure, Canvas canvas,
      Paint goalPaint, double bodyX1, double ballRadius, Size size) {
    final double goalX = bodyX1 + size.width / 2;
    Offset leftPostOffset = Offset(goalX + size.width / 1.85, size.height);
    Offset rightPostOffset =
        Offset(goalX + size.width / 1.85 + size.width / 3, size.height);
    GoalPaint goal =
        GoalPaint(leftPostOffset, rightPostOffset, size.height - ballRadius);
    canvas.drawPath(goal.returnGoalPaint(), goalPaint);
  }

  void drawMovingGoalAway(FigureLinesCalculator figure, Canvas canvas,
      Paint goalPaint, double bodyX1, double ballRadius, Size size) {
    final double goalX = bodyX1 + size.width / 2;
    final double lineFromLeftToRight = size.width / 3;
    final double leftGoalX = (0 - size.width) +
        (goalX + size.width / 1.85 + size.width) *
            (kickAnimationValue - 1).abs();
    Offset leftPostOffset = Offset(leftGoalX, size.height);
    Offset rightPostOffset =
        Offset(leftGoalX + lineFromLeftToRight, size.height);
    GoalPaint goal =
        GoalPaint(leftPostOffset, rightPostOffset, size.height - ballRadius);
    canvas.drawPath(goal.returnGoalPaint(), goalPaint);
  }

  void drawMovingTable(
      FigureLinesCalculator figure,
      Canvas canvas,
      Paint goalPaint,
      double bodyX1,
      double tableX,
      double tableLength,
      double tableHeight,
      Size size) {
    final double tableX1 = tableX + (size.width - bodyX1) * kickAnimationValue;
    Offset leftLeg = Offset(tableX1, size.height);
    Offset rightLeg = Offset(tableX1 + tableLength, size.height);
    TablePaint table = TablePaint(leftLeg, rightLeg, tableHeight);
    canvas.drawPath(table.returnTablePaint(), goalPaint);
  }

  void drawStandingTable(Canvas canvas, Paint goalPaint, double tableX,
      double tableLength, double tableHeight, Size size) {
    Offset leftLeg = Offset(tableX, size.height);
    Offset rightLeg = Offset(tableX + tableLength, size.height);
    TablePaint table = TablePaint(leftLeg, rightLeg, tableHeight);
    canvas.drawPath(table.returnTablePaint(), goalPaint);
  }

  void drawMovingTableAway(Canvas canvas, Paint goalPaint, double tableX,
      double tableLength, double tableHeight, Size size) {
    double leftTableX =
        (0 - size.width) + (tableX + size.width) * kickAnimationValue;
    Offset leftLeg = Offset(leftTableX, size.height);
    Offset rightLeg = Offset(leftTableX + tableLength, size.height);
    TablePaint table = TablePaint(leftLeg, rightLeg, tableHeight);
    canvas.drawPath(table.returnTablePaint(), goalPaint);
  }

  void drawMovingBeerAway(Canvas canvas, Paint goalPaint, double tableX,
      double tableLength, double tableHeight, Size size) {
    double leftTableX =
        (0 - size.width) + (tableX + size.width) * kickAnimationValue;
    Offset bottomLeft = Offset(leftTableX - 10, size.height - tableHeight);
    Offset bottomRight = Offset(leftTableX + 10, size.height - tableHeight);
    BeerPaint beer = BeerPaint(bottomLeft, bottomRight, size.height / 5, false);
    canvas.drawPath(beer.returnBeerPaint(), goalPaint);
  }

  void drawMovingBeer(Canvas canvas, Paint goalPaint, double tableX,
      double tableLength, double tableHeight, double bodyX1, Size size) {
    final double beerX = tableX + (size.width - bodyX1) * kickAnimationValue;
    Offset bottomLeft = Offset(beerX - 10, size.height - tableHeight);
    Offset bottomRight = Offset(beerX + 10, size.height - tableHeight);
    BeerPaint beer = BeerPaint(bottomLeft, bottomRight, size.height / 5, true);
    canvas.drawPath(beer.returnBeerPaint(), goalPaint);
  }

  void drawStandingBeer(Canvas canvas, Paint goalPaint, double tableX,
      double tableLength, double tableHeight, Size size, bool foam) {
    Offset bottomLeft = Offset(tableX - 10, size.height - tableHeight);
    Offset bottomRight = Offset(tableX + 10, size.height - tableHeight);
    BeerPaint beer = BeerPaint(bottomLeft, bottomRight, size.height / 5, foam);
    canvas.drawPath(beer.returnBeerPaint(), goalPaint);
  }

  void drawDrinkingBeer(
      FigureLinesCalculator figure,
      Canvas canvas,
      Paint goalPaint,
      double tableX,
      double tableLength,
      double tableHeight,
      Size size) {
    if (figure.bodyY1 > 0) {
      Offset bottomLeft = Offset(figure.leftForearmComponents[1].dx - 20,
          figure.leftForearmComponents[1].dy);
      Offset bottomRight = figure.leftForearmComponents[1];
      BeerPaint beer = BeerPaint(
          bottomLeft, bottomRight, size.height / 5, figure.rightCalfAngle <= 0);
      double degree = (figure.bodyY1 * 6 * -45) * (math.pi / 180);
      drawRotated(
        canvas,
        Offset(
          figure.leftForearmComponents[1].dx + (10),
          figure.leftForearmComponents[1].dy,
        ),
        degree,
        () => canvas.drawPath(beer.returnBeerPaint(), goalPaint),
      );
    } else {
      drawStandingBeer(canvas, goalPaint, tableX, tableLength, tableHeight,
          size, figure.rightCalfAngle <= 0);
    }
  }

  void drawStandingFigure(FigureLinesCalculator figure, Canvas canvas,
      Paint linePaint, double headRadius) {
    canvas.drawLine(
        figure.bodyComponents[0], figure.bodyComponents[1], linePaint);
    canvas.drawLine(
        figure.leftArmComponents[0], figure.leftArmComponents[1], linePaint);
    canvas.drawLine(
        figure.rightArmComponents[0], figure.rightArmComponents[1], linePaint);
    canvas.drawLine(figure.leftForearmComponents[0],
        figure.leftForearmComponents[1], linePaint);
    canvas.drawLine(figure.rightForearmComponents[0],
        figure.rightForearmComponents[1], linePaint);
    canvas.drawLine(figure.leftThighComponents[0],
        figure.leftThighComponents[1], linePaint);
    canvas.drawLine(figure.rightThighComponents[0],
        figure.rightThighComponents[1], linePaint);
    canvas.drawLine(
        figure.leftCalfComponents[0], figure.leftCalfComponents[1], linePaint);
    canvas.drawLine(figure.rightCalfComponents[0],
        figure.rightCalfComponents[1], linePaint);
    canvas.drawCircle(figure.headComponents, headRadius, linePaint);
  }

  void drawRotated(
    Canvas canvas,
    Offset center,
    double angle,
    VoidCallback drawFunction,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    drawFunction();
    canvas.restore();
  }

  void writeText(Canvas canvas, Size size) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 30,
    );
    const textSpan = TextSpan(
      text: 'Načítám...',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height + textPainter.height);
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }
}
