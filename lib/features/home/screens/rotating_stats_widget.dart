import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/api/home/stats_board_data.dart';
import '../widget/home_section_card.dart';

class RotatingStatsWidget extends StatefulWidget {
  final List<StatsBoardData> statsBoards;

  const RotatingStatsWidget({
    super.key,
    required this.statsBoards,
  });

  @override
  State<RotatingStatsWidget> createState() => _RotatingStatsWidgetState();
}

class _RotatingStatsWidgetState extends State<RotatingStatsWidget>
    with SingleTickerProviderStateMixin {
  static const Duration screenDuration = Duration(seconds: 10);
  static const Duration switchDuration = Duration(milliseconds: 550);

  late final AnimationController _progressController;
  Timer? _screenTimer;

  int _currentIndex = 0;
  bool _isForward = true;
  bool _isPaused = false;
  bool _isDragging = false;
  double _dragDx = 0;

  List<StatsBoardData> get _screens => widget.statsBoards;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: screenDuration,
    );

    if (_screens.isNotEmpty) {
      _startAutoCycle(fromStart: true);
    }
  }

  @override
  void didUpdateWidget(covariant RotatingStatsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_screens.isEmpty) {
      _screenTimer?.cancel();
      _progressController.stop();
      _currentIndex = 0;
      return;
    }

    if (_currentIndex >= _screens.length) {
      _currentIndex = 0;
    }

    if (oldWidget.statsBoards.length != widget.statsBoards.length) {
      _restartCycleFromZero();
    }
  }

  void _startAutoCycle({bool fromStart = false}) {
    if (_screens.isEmpty) return;

    _screenTimer?.cancel();

    if (fromStart) {
      _progressController.forward(from: 0);
    } else {
      _progressController.forward();
    }

    _screenTimer = Timer(_remainingDuration, () {
      if (!mounted) return;
      _goToNext(auto: true);
    });
  }

  Duration get _remainingDuration {
    final remainingMs =
    (screenDuration.inMilliseconds * (1 - _progressController.value))
        .round()
        .clamp(0, screenDuration.inMilliseconds);

    return Duration(milliseconds: remainingMs);
  }

  void _pauseAutoCycle() {
    if (_isPaused) return;

    _isPaused = true;
    _screenTimer?.cancel();
    _progressController.stop();
  }

  void _resumeAutoCycle() {
    if (!_isPaused) return;

    _isPaused = false;
    _startAutoCycle(fromStart: false);
  }

  void _restartCycleFromZero() {
    if (_screens.isEmpty) return;

    _screenTimer?.cancel();
    _progressController
      ..stop()
      ..reset();

    _isPaused = false;
    _startAutoCycle(fromStart: true);
  }

  void _goToNext({bool auto = false}) {
    if (_screens.isEmpty) return;

    setState(() {
      _isForward = true;
      _currentIndex = (_currentIndex + 1) % _screens.length;
    });

    _restartCycleFromZero();
  }

  void _goToPrevious() {
    if (_screens.isEmpty) return;

    setState(() {
      _isForward = false;
      _currentIndex = (_currentIndex - 1 + _screens.length) % _screens.length;
    });

    _restartCycleFromZero();
  }

  void _handlePressStart() {
    _pauseAutoCycle();
  }

  void _handlePressEnd() {
    if (_isDragging) return;
    _resumeAutoCycle();
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragDx = 0;
    _pauseAutoCycle();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    _dragDx += details.delta.dx;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    const velocityThreshold = 250.0;
    const distanceThreshold = 40.0;

    final velocity = details.primaryVelocity ?? 0;

    final shouldGoPrevious =
        velocity > velocityThreshold || _dragDx > distanceThreshold;

    final shouldGoNext =
        velocity < -velocityThreshold || _dragDx < -distanceThreshold;

    _isDragging = false;
    _dragDx = 0;

    if (shouldGoNext) {
      _goToNext();
      return;
    }

    if (shouldGoPrevious) {
      _goToPrevious();
      return;
    }

    _resumeAutoCycle();
  }

  @override
  void dispose() {
    _screenTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_screens.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);
    final screen = _screens[safeIndex];
    final currentKey = ValueKey(safeIndex);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _handlePressStart(),
      onTapUp: (_) => _handlePressEnd(),
      onTapCancel: _handlePressEnd,
      onHorizontalDragStart: _handleHorizontalDragStart,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: HomeSectionCard(
        padding: EdgeInsets.zero,
        child: AnimatedSize(
          duration: switchDuration,
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: switchDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final isIncoming = child.key == currentKey;

                      final slideInBegin = _isForward
                          ? const Offset(0.10, 0)
                          : const Offset(-0.10, 0);

                      final slideOutEnd = _isForward
                          ? const Offset(-0.06, 0)
                          : const Offset(0.06, 0);

                      final slide = Tween<Offset>(
                        begin: isIncoming ? slideInBegin : Offset.zero,
                        end: isIncoming ? Offset.zero : slideOutEnd,
                      ).animate(animation);

                      final fade = Tween<double>(
                        begin: isIncoming ? 0.75 : 1.0,
                        end: isIncoming ? 1.0 : 0.0,
                      ).animate(animation);

                      final rotation = Tween<double>(
                        begin: isIncoming
                            ? (_isForward ? 0.12 : -0.12)
                            : 0.0,
                        end: isIncoming
                            ? 0.0
                            : (_isForward ? -0.04 : 0.04),
                      ).animate(animation);

                      final scale = Tween<double>(
                        begin: isIncoming ? 0.985 : 1.0,
                        end: isIncoming ? 1.0 : 0.985,
                      ).animate(animation);

                      return AnimatedBuilder(
                        animation: animation,
                        child: child,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: fade,
                            child: SlideTransition(
                              position: slide,
                              child: Transform(
                                alignment: _isForward
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0012)
                                  ..rotateY(rotation.value)
                                  ..scale(scale.value),
                                child: child,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: _StatsTableView(
                      key: currentKey,
                      data: screen,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 3,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor:
                          _progressController.value.clamp(0.0, 1.0),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 3,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsTableView extends StatelessWidget {
  final StatsBoardData data;

  const _StatsTableView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );

    const headerStyle = TextStyle(
      color: Colors.black54,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    const cellStyle = TextStyle(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: titleStyle,
          ),
        ),
        const SizedBox(height: 12),
        _TableRow(
          values: data.headers,
          isHeader: true,
          textStyle: headerStyle,
        ),
        const SizedBox(height: 6),
        ...List.generate(data.rows.length, (index) {
          final row = data.rows[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == data.rows.length - 1 ? 0 : 6,
            ),
            child: _TableRow(
              values: row.columns,
              textStyle: cellStyle,
            ),
          );
        }),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final List<String> values;
  final bool isHeader;
  final TextStyle textStyle;

  const _TableRow({
    required this.values,
    required this.textStyle,
    this.isHeader = false,
  });

  String _valueAt(int index) {
    if (index >= values.length) return '';
    return values[index];
  }

  @override
  Widget build(BuildContext context) {
    final rowColor =
    isHeader ? Colors.black.withAlpha(20) : Colors.black.withAlpha(10);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isHeader ? 8 : 10,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              _valueAt(0),
              style: textStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              _valueAt(1),
              style: textStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              _valueAt(2),
              style: textStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}