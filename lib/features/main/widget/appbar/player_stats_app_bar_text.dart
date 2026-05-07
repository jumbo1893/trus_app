import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trus_app/models/api/player/stats/player_stats.dart';
import 'package:trus_app/theme/app_colors.dart';

class PlayerStatsAppBarText extends StatefulWidget {
  final PlayerStats? stats;
  final Duration rotateEvery;
  final Duration highlightFor;

  const PlayerStatsAppBarText({
    Key? key,
    required this.stats,
    this.rotateEvery = const Duration(seconds: 5),
    this.highlightFor = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<PlayerStatsAppBarText> createState() => _PlayerStatsAppBarTextState();
}

class _PlayerStatsAppBarTextState extends State<PlayerStatsAppBarText>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;

  PlayerStats? _lastStats;
  bool _highlight = false;
  Timer? _highlightTimer;

  late final AnimationController _shakeController;
  late final Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _lastStats = widget.stats;

    _timer = Timer.periodic(widget.rotateEvery, (_) {
      if (mounted) {
        setState(() => _currentIndex++);
      }
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.00, 0), end: const Offset(-0.06, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.06, 0), end: const Offset(0.06, 0)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.06, 0), end: const Offset(0, 0)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _highlightTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  int? _computeChangedIndex(PlayerStats oldStats, PlayerStats newStats) {
    if (oldStats.playerAchievementCount.totalAchievements !=
        newStats.playerAchievementCount.totalAchievements ||
        oldStats.playerAchievementCount.accomplishedAchievements !=
            newStats.playerAchievementCount.accomplishedAchievements) {
      return 0;
    }

    if (oldStats.playerFootbarCount?.totalDistanceInKmToString() !=
        newStats.playerFootbarCount?.totalDistanceInKmToString()) {
      return 1;
    }

    if (oldStats.playerGoalCount.totalGoals !=
        newStats.playerGoalCount.totalGoals ||
        oldStats.playerGoalCount.totalAssists !=
            newStats.playerGoalCount.totalAssists) {
      return 2;
    }

    if (oldStats.playerFineCount.totalFines !=
        newStats.playerFineCount.totalFines) {
      return 3;
    }

    if (oldStats.playerBeerCount.totalBeers !=
        newStats.playerBeerCount.totalBeers ||
        oldStats.playerBeerCount.totalLiquors !=
            newStats.playerBeerCount.totalLiquors) {
      return 4;
    }

    return null;
  }

  void _triggerHighlight(int changedIndex) {
    if (!mounted) return;

    _highlightTimer?.cancel();

    setState(() {
      _currentIndex = changedIndex;
      _highlight = true;
    });

    _shakeController.forward(from: 0.0);

    _highlightTimer = Timer(widget.highlightFor, () {
      if (mounted) {
        setState(() => _highlight = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant PlayerStatsAppBarText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newStats = widget.stats;
    if (newStats == null) {
      _lastStats = null;
      return;
    }

    if (_lastStats != null) {
      final changedIndex = _computeChangedIndex(_lastStats!, newStats);
      if (changedIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _triggerHighlight(changedIndex);
          }
        });
      }
    }

    _lastStats = newStats;
  }

  TextStyle _valueStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerStats = widget.stats;
    if (playerStats == null) return const SizedBox.shrink();

    final appColors = context.appColors;
    final normalColor = appColors.textPrimary;
    final valueColor = _highlight ? appColors.appBarHighlight : normalColor;

    final totalAchievements = playerStats.playerAchievementCount.totalAchievements;
    final accomplishedAchievements =
        playerStats.playerAchievementCount.accomplishedAchievements;

    final totalGoals = playerStats.playerGoalCount.totalGoals;
    final totalAssists = playerStats.playerGoalCount.totalAssists;

    final totalFines = playerStats.playerFineCount.totalFines;

    final totalBeers = playerStats.playerBeerCount.totalBeers;
    final totalLiquors = playerStats.playerBeerCount.totalLiquors;

    final totalDistance =
        playerStats.playerFootbarCount?.totalDistanceInKmToString() ?? "0";

    final seasonName = playerStats.season.name;

    final items = [
      Row(
        key: const ValueKey("ach"),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$accomplishedAchievements / $totalAchievements",
            style: _valueStyle(valueColor),
          ),
          const SizedBox(width: 4),
          Icon(Icons.emoji_events, color: valueColor, size: 17),
        ],
      ),
      Row(
        key: const ValueKey("foot"),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$totalDistance km",
            style: _valueStyle(valueColor),
          ),
          const SizedBox(width: 4),
          Icon(Icons.directions_run, color: valueColor, size: 17),
        ],
      ),
      Row(
        key: const ValueKey("goals"),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$totalGoals ",
            style: _valueStyle(valueColor),
          ),
          Icon(Icons.sports_soccer, color: valueColor, size: 17),
          Text(
            " / $totalAssists ",
            style: _valueStyle(valueColor),
          ),
          Icon(Icons.handshake_outlined, color: valueColor, size: 17),
        ],
      ),
      Row(
        key: const ValueKey("fines"),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Pokuty: $totalFines Kč",
            style: _valueStyle(valueColor),
          ),
        ],
      ),
      Row(
        key: const ValueKey("beers"),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$totalBeers ",
            style: _valueStyle(valueColor),
          ),
          Icon(Icons.sports_bar, color: valueColor, size: 17),
          Text(
            " / $totalLiquors ",
            style: _valueStyle(valueColor),
          ),
          Icon(Icons.liquor, color: valueColor, size: 17),
        ],
      ),
    ];

    final index = _currentIndex % items.length;
    final currentWidget = items[index];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$seasonName | ",
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  SlideTransition(
                    position: _shakeAnimation,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(index),
                        child: currentWidget,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}