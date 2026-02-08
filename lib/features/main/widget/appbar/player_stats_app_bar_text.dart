import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trus_app/models/api/player/stats/player_stats.dart';

import '../../../mixin/player_stats_mixin.dart';

class PlayerStatsAppBarText extends StatefulWidget {
  final PlayerStatsMixin playerStatsMixin;
  final String hashKey;

  const PlayerStatsAppBarText({
    Key? key,
    required this.playerStatsMixin,
    required this.hashKey,
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

  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Rotace zobrazení
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _currentIndex++);
    });

    // Shake animace
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
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
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
    if (oldStats.playerGoalCount.totalGoals !=
        newStats.playerGoalCount.totalGoals ||
        oldStats.playerGoalCount.totalAssists !=
            newStats.playerGoalCount.totalAssists) {
      return 1;
    }
    if (oldStats.playerFineCount.totalFines !=
        newStats.playerFineCount.totalFines) {
      return 2;
    }
    if (oldStats.playerBeerCount.totalBeers !=
        newStats.playerBeerCount.totalBeers ||
        oldStats.playerBeerCount.totalLiquors !=
            newStats.playerBeerCount.totalLiquors) {
      return 3;
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

    // 🔥 Spustíme třes
    _shakeController.forward(from: 0.0);

    // Vypneme highlight po 1 sekundě
    _highlightTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _highlight = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerStats?>(
      stream: widget.playerStatsMixin.playerStatsValue(widget.hashKey),
      initialData: widget.playerStatsMixin.playerStatsValues[widget.hashKey],
      builder: (context, snapshot) {
        final playerStats = snapshot.data;
        if (playerStats == null) return const SizedBox.shrink();

        // Porovnání s minulými hodnotami
        if (_lastStats != null) {
          final changedIndex = _computeChangedIndex(_lastStats!, playerStats);
          if (changedIndex != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _triggerHighlight(changedIndex);
            });
          }
        }
        _lastStats = playerStats;

        // Připravené hodnoty
        final totalAchievements =
            playerStats.playerAchievementCount.totalAchievements;
        final accomplishedAchievements =
            playerStats.playerAchievementCount.accomplishedAchievements;
        final totalGoals = playerStats.playerGoalCount.totalGoals;
        final totalAssists = playerStats.playerGoalCount.totalAssists;
        final totalFines = playerStats.playerFineCount.totalFines;
        final totalBeers = playerStats.playerBeerCount.totalBeers;
        final totalLiquors = playerStats.playerBeerCount.totalLiquors;
        final seasonName = playerStats.season.name;

        final Color valueColor = _highlight ? Colors.red : Colors.white;

        // Jednotlivé widgety
        final items = [
          Row(
            key: const ValueKey("ach"),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$accomplishedAchievements / $totalAchievements",
                  style: TextStyle(color: valueColor, fontSize: 18)),
              const SizedBox(width: 4),
              Icon(Icons.emoji_events, color: valueColor, size: 18),
            ],
          ),
          Row(
            key: const ValueKey("goals"),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$totalGoals ",
                  style: TextStyle(color: valueColor, fontSize: 18)),
              Icon(Icons.sports_soccer, color: valueColor, size: 18),
              Text(" / $totalAssists ",
                  style: TextStyle(color: valueColor, fontSize: 18)),
              Icon(Icons.handshake_outlined, color: valueColor, size: 18),
            ],
          ),
          Row(
            key: const ValueKey("fines"),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pokuty: $totalFines Kč",
                  style: TextStyle(color: valueColor, fontSize: 18)),
            ],
          ),
          Row(
            key: const ValueKey("beers"),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$totalBeers ",
                  style: TextStyle(color: valueColor, fontSize: 18)),
              Icon(Icons.sports_bar, color: valueColor, size: 18),
              Text(" / $totalLiquors ",
                  style: TextStyle(color: valueColor, fontSize: 18)),
              Icon(Icons.liquor, color: valueColor, size: 18),
            ],
          ),
        ];

        final index = _currentIndex % items.length;
        final currentWidget = items[index];

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$seasonName | ",
                      style: TextStyle(color: valueColor, fontSize: 18),
                    ),

                    // 🔥 celý přepínací widget se třese
                    SlideTransition(
                      position: _shakeAnimation,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: KeyedSubtree(
                          key: ValueKey(index),
                          child: currentWidget,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
