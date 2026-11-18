import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/models/api/participation/match_participation_detail.dart';

/// Help is acknowledged separately for each action, team and player. An action
/// that becomes available later therefore still gets its first introduction.
class ParticipationHelp {
  static Future<void> showIfNeeded(
    BuildContext context,
    MatchParticipationDetail detail,
    int teamId,
  ) async {
    final player = detail.currentPlayer;
    if (player?.id == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    final prefix = 'participation_help_v1_${teamId}_${player!.id}_';
    final members = [
      ...detail.attendingPlayers,
      ...detail.attendingFans,
      ...detail.maybePlayers,
      ...detail.maybeFans,
      ...detail.notAttendingPlayers,
      ...detail.notAttendingFans,
    ];
    final respondedIds = members.map((member) => member.player.id).toSet();
    final available = <String>[
      'own',
      if (detail.eligiblePlayers.any(
        (p) => p.id != player.id && !respondedIds.contains(p.id),
      ))
        'other',
      if (members.any((member) => member.canDelete))
        'delete',
    ];
    final unseen = available
        .where((key) => prefs.getBool('$prefix$key') != true)
        .toList();
    if (unseen.isEmpty) return;
    final understood = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ParticipationHelpDialog(steps: unseen),
    );
    if (understood == true) {
      for (final key in unseen) {
        await prefs.setBool('$prefix$key', true);
      }
    }
  }
}

class _ParticipationHelpDialog extends StatelessWidget {
  final List<String> steps;
  const _ParticipationHelpDialog({required this.steps});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Jak zadat účast'),
    content: SizedBox(
      width: 380,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (steps.contains('own'))
              const _HelpStep(
                number: '1',
                title: 'Tvoje účast',
                instruction:
                    'Klepni na zelené tlačítko a vyber ANO, MOŽNÁ nebo NE.',
                icon: Icons.check_circle,
                example: 'VYBER ÚČAST       Vybrat  ⌄',
                color: Color(0xFF2F8B46),
              ),
            if (steps.contains('other'))
              const _HelpStep(
                number: '2',
                title: 'Za někoho jiného',
                instruction:
                    'Klepni na tlačítko, potom vyber člověka ze seznamu.',
                icon: Icons.person_add_alt,
                example: '＋  Zadat za někoho jiného',
                color: Color(0xFF218C83),
              ),
            if (steps.contains('delete'))
              const _HelpStep(
                number: '3',
                title: 'Smazání účasti',
                instruction:
                    'Svůj záznam nebo záznam zadaný tebou posuň doleva.',
                icon: Icons.swipe_left,
                example: 'Petr Novák    ←  🗑',
                color: Color(0xFFD85656),
              ),
          ],
        ),
      ),
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Všemu rozumím'),
      ),
    ],
  );
}

class _HelpStep extends StatelessWidget {
  final String number;
  final String title;
  final String instruction;
  final IconData icon;
  final String example;
  final Color color;
  const _HelpStep({
    required this.number,
    required this.title,
    required this.instruction,
    required this.icon,
    required this.example,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number. $title', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(instruction),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.arrow_downward, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 19),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        example,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
