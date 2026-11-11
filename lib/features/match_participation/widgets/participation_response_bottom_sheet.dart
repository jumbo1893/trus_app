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
  final bool? playing;

  const ParticipationChoice.respond(
    this.status, {
    this.player,
    this.comment,
    this.playing,
  }) : createNewPlayer = false;

  const ParticipationChoice.createPlayer(
    this.status, {
    this.comment,
    this.playing,
  }) : player = null,
       createNewPlayer = true;
}

class ParticipationResponseBottomSheet extends StatefulWidget {
  final FootballMatchApiModel footballMatch;
  final PlayerApiModel? currentPlayer;
  final List<PlayerApiModel> eligiblePlayers;
  final bool reconsideration;
  final bool? initialPlaying;
  final String? initialComment;

  const ParticipationResponseBottomSheet({
    super.key,
    required this.footballMatch,
    required this.currentPlayer,
    required this.eligiblePlayers,
    required this.reconsideration,
    this.initialPlaying,
    this.initialComment,
  });

  static Future<ParticipationChoice?> show(
    BuildContext context, {
    required FootballMatchApiModel footballMatch,
    required PlayerApiModel? currentPlayer,
    required List<PlayerApiModel> eligiblePlayers,
    bool reconsideration = false,
    bool? initialPlaying,
    String? initialComment,
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
        initialPlaying: initialPlaying,
        initialComment: initialComment,
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
  bool _playing = true;
  bool? _selectedPlaying;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playing = widget.initialPlaying ?? !(widget.currentPlayer?.fan ?? false);
    _commentController.text = widget.initialComment ?? '';
  }

  String? get _comment {
    final value = _commentController.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onStatusSelected(MatchParticipationStatus status, {bool? playing}) {
    _selectedPlaying = playing;
    if (playing != null) _playing = playing;
    if (widget.currentPlayer != null) {
      _finish(status, widget.currentPlayer);
      return;
    }
    setState(() => _selectedStatus = status);
  }

  Future<void> _finish(
    MatchParticipationStatus status,
    PlayerApiModel? player, {
    bool create = false,
  }) async {
    final bool? playing = switch (status) {
      MatchParticipationStatus.attending =>
        _selectedPlaying ?? (player == null ? _playing : !player.fan),
      MatchParticipationStatus.maybe =>
        _selectedPlaying ?? (player == null ? _playing : !player.fan),
      MatchParticipationStatus.notAttending => null,
    };
    if (!mounted) return;
    Navigator.pop(
      context,
      create
          ? ParticipationChoice.createPlayer(
              status,
              comment: _comment,
              playing: playing,
            )
          : ParticipationChoice.respond(
              status,
              player: player,
              comment: _comment,
              playing: playing,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selectedStatus = _selectedStatus;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: selectedStatus == null
                ? _buildStatusStep(context)
                : _buildPlayerStep(context, selectedStatus),
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
        Text(
          widget.footballMatch.toStringNameWithOpponent(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          widget.footballMatch.toStringForDateSubtitle(),
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
        if (widget.currentPlayer != null) ...[
          const SizedBox(height: 4),
          Text(
            'Odpovídáš jako ${widget.currentPlayer!.name}',
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'POZNÁMKA',
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _commentController,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 140,
          maxLines: 2,
          minLines: 1,
          decoration: InputDecoration(
            hintText: 'Např. přijdu o 15 min později…',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'JDU ZA',
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        _SplitChoice(
          label: 'Jdu',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF2F8B46),
          onPressed: () =>
              _onStatusSelected(MatchParticipationStatus.attending),
          onSelected: (playing) => _onStatusSelected(
            MatchParticipationStatus.attending,
            playing: playing,
          ),
          playerOption: 'Jdu a hraju',
          fanOption: 'Jdu jako fanoušek',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SplitChoice(
                label: 'Možná',
                icon: Icons.help_outline,
                color: const Color(0xFFE78A24),
                compact: true,
                onPressed: () =>
                    _onStatusSelected(MatchParticipationStatus.maybe),
                onSelected: (playing) => _onStatusSelected(
                  MatchParticipationStatus.maybe,
                  playing: playing,
                ),
                playerOption: 'Možná jako hráč',
                fanOption: 'Možná jako fanoušek',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SmallChoice(
                label: 'Nejdu',
                icon: Icons.cancel_outlined,
                color: const Color(0xFF6B7280),
                onPressed: () =>
                    _onStatusSelected(MatchParticipationStatus.notAttending),
              ),
            ),
          ],
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
              onTap: () => _finish(status, player),
            ),
          ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () => _finish(status, null, create: true),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Nejsem na seznamu – vytvořit osobu'),
        ),
      ],
    );
  }
}

class _SmallChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _SmallChoice({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: color,
      minimumSize: const Size(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _SplitChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool compact;
  final VoidCallback onPressed;
  final ValueChanged<bool> onSelected;
  final String playerOption;
  final String fanOption;

  const _SplitChoice({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.onSelected,
    required this.playerOption,
    required this.fanOption,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(11),
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onPressed,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(11),
            ),
            child: SizedBox(
              height: 46,
              child: compact
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 18, color: Colors.white),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(icon, size: 20, color: Colors.white),
                        const SizedBox(width: 9),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        Container(width: 1, height: 28, color: Colors.white70),
        PopupMenuButton<bool>(
          tooltip: 'Vybrat možnost $label',
          onSelected: onSelected,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 20,
          ),
          itemBuilder: (_) => [
            PopupMenuItem(value: true, child: Text(playerOption)),
            PopupMenuItem(value: false, child: Text(fanOption)),
          ],
        ),
      ],
    ),
  );
}
