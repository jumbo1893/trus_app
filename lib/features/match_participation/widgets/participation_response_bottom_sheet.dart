import 'package:flutter/material.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';

class ParticipationChoice {
  final MatchParticipationStatus status;
  final PlayerApiModel? player;
  final bool createNewPlayer;
  final String? comment;

  const ParticipationChoice.respond(this.status, {this.player, this.comment})
    : createNewPlayer = false;

  const ParticipationChoice.createPlayer(this.status, {this.comment})
    : player = null,
      createNewPlayer = true;
}

class ParticipationResponseBottomSheet extends StatefulWidget {
  final FootballMatchApiModel footballMatch;
  final PlayerApiModel? currentPlayer;
  final List<PlayerApiModel> eligiblePlayers;
  final bool reconsideration;

  const ParticipationResponseBottomSheet({
    super.key,
    required this.footballMatch,
    required this.currentPlayer,
    required this.eligiblePlayers,
    required this.reconsideration,
  });

  static Future<ParticipationChoice?> show(
    BuildContext context, {
    required FootballMatchApiModel footballMatch,
    required PlayerApiModel? currentPlayer,
    required List<PlayerApiModel> eligiblePlayers,
    bool reconsideration = false,
  }) {
    return showModalBottomSheet<ParticipationChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ParticipationResponseBottomSheet(
        footballMatch: footballMatch,
        currentPlayer: currentPlayer,
        eligiblePlayers: eligiblePlayers,
        reconsideration: reconsideration,
      ),
    );
  }

  @override
  State<ParticipationResponseBottomSheet> createState() =>
      _ParticipationResponseBottomSheetState();
}

class _ParticipationResponseBottomSheetState
    extends State<ParticipationResponseBottomSheet> {
  MatchParticipationStatus? _selectedStatus;
  final TextEditingController _commentController = TextEditingController();

  String? get _comment {
    final value = _commentController.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onStatusSelected(MatchParticipationStatus status) {
    if (widget.currentPlayer != null) {
      Navigator.of(
        context,
      ).pop(ParticipationChoice.respond(status, comment: _comment));
      return;
    }
    setState(() => _selectedStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selectedStatus = _selectedStatus;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selectedStatus == null
                  ? _buildStatusStep(context)
                  : _buildPlayerStep(context, selectedStatus),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStep(BuildContext context) {
    final colors = context.appColors;
    return Column(
      key: const ValueKey('status-step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: colors.textMuted.withAlpha(60),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        Icon(Icons.sports_soccer, size: 38, color: colors.accent),
        const SizedBox(height: 10),
        Text(
          widget.reconsideration
              ? 'Už ses rozhodl?'
              : 'Dorazíš na příští zápas?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.footballMatch.toStringForTitle(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          widget.footballMatch.toStringForDateSubtitle(),
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary),
        ),
        if (widget.currentPlayer != null) ...[
          const SizedBox(height: 8),
          Text(
            'Odpovídáš jako ${widget.currentPlayer!.name}',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 18),
        TextField(
          controller: _commentController,
          maxLength: 1000,
          maxLines: 3,
          minLines: 1,
          decoration: const InputDecoration(
            labelText: 'Komentář (volitelné)',
            hintText: 'Třeba důvod, proč nemůžeš dorazit…',
            prefixIcon: Icon(Icons.chat_bubble_outline),
          ),
        ),
        const SizedBox(height: 10),
        _StatusButton(
          label: 'Zúčastním se',
          icon: Icons.check_circle_outline,
          color: Colors.green.shade700,
          onPressed: () =>
              _onStatusSelected(MatchParticipationStatus.attending),
        ),
        const SizedBox(height: 10),
        _StatusButton(
          label: 'Možná',
          icon: Icons.help_outline,
          color: Colors.orange.shade700,
          onPressed: () => _onStatusSelected(MatchParticipationStatus.maybe),
        ),
        const SizedBox(height: 10),
        _StatusButton(
          label: 'Nezúčastním se',
          icon: Icons.cancel_outlined,
          color: colors.errorForeground,
          onPressed: () =>
              _onStatusSelected(MatchParticipationStatus.notAttending),
        ),
      ],
    );
  }

  Widget _buildPlayerStep(
    BuildContext context,
    MatchParticipationStatus status,
  ) {
    final colors = context.appColors;
    return Column(
      key: const ValueKey('player-step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _selectedStatus = null),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                'Kdo jsi?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Účet zatím není spárovaný s hráčem ani fanouškem. Vyber se ze seznamu; odpověď „${status.label}“ i komentář si zapamatujeme.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 14),
        for (final player in widget.eligiblePlayers)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: colors.backgroundSecondary,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.accentSoft,
                child: Icon(Icons.person_outline, color: colors.accent),
              ),
              title: Text(
                player.name,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${player.fan ? "Fanoušek" : "Hráč"}${player.active ? "" : " · neaktivní"}',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right, color: colors.accent),
              onTap: () => Navigator.of(context).pop(
                ParticipationChoice.respond(
                  status,
                  player: player,
                  comment: _comment,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).pop(ParticipationChoice.createPlayer(status, comment: _comment)),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Nejsem na seznamu – vytvořit osobu'),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withAlpha(120)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
