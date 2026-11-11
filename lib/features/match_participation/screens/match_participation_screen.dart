import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_widget.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/match_participation/controller/match_participation_notifier.dart';
import 'package:trus_app/features/match_participation/widgets/participation_response_bottom_sheet.dart';
import 'package:trus_app/features/user/widgets/user_avatar.dart';
import 'package:trus_app/models/api/participation/match_participation_detail.dart';
import 'package:trus_app/models/api/participation/match_participation_member.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class MatchParticipationScreen extends CustomConsumerWidget {
  static const String id = 'match-participation-screen';
  final int? matchId;

  const MatchParticipationScreen({super.key, this.matchId})
    : super(title: 'Účast na zápase', name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footballMatchId =
        matchId ?? ref.watch(screenVariablesNotifierProvider).footballMatchId;
    if (footballMatchId == null) {
      return const Scaffold(body: Center(child: Text('Zápas nebyl vybrán.')));
    }

    final provider = matchParticipationNotifierProvider(footballMatchId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: state.detail.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 420,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 420,
                child: Center(child: Text('Účast se nepodařilo načíst.')),
              ),
            ],
          ),
          data: (detail) => _ParticipationContent(
            detail: detail,
            onRespondFor: (player) async {
              final choice = await ParticipationResponseBottomSheet.show(
                context,
                footballMatch: detail.footballMatch,
                currentPlayer: player,
                eligiblePlayers: const [],
                initialPlaying: _playingFor(detail, player.id),
                initialComment: _noteFor(detail, player.id),
              );
              if (choice == null || !context.mounted) return;
              await notifier.respond(
                choice.status,
                player: player,
                playing: choice.playing,
                comment: choice.comment,
              );
            },
            onRespond: () async {
              final choice = await ParticipationResponseBottomSheet.show(
                context,
                footballMatch: detail.footballMatch,
                currentPlayer: detail.currentPlayer,
                eligiblePlayers: detail.eligiblePlayers,
                initialPlaying: _playingFor(detail, detail.currentPlayer?.id),
                initialComment: _noteFor(detail, detail.currentPlayer?.id),
              );
              if (choice == null || !context.mounted) return;
              if (choice.createNewPlayer) {
                notifier.startNewPlayerFlow(
                  choice.status,
                  comment: choice.comment,
                  playing: choice.playing,
                );
              } else {
                await notifier.respond(
                  choice.status,
                  player: choice.player,
                  playing: choice.playing,
                  comment: choice.comment,
                );
              }
            },
            onDeleteResponse: notifier.deleteResponse,
          ),
        ),
      ),
    );
  }
}

List<MatchParticipationMember> _allMembers(MatchParticipationDetail detail) => [
  ...detail.attendingPlayers,
  ...detail.attendingFans,
  ...detail.maybePlayers,
  ...detail.maybeFans,
  ...detail.notAttendingPlayers,
  ...detail.notAttendingFans,
];

bool? _playingFor(MatchParticipationDetail detail, int? id) {
  for (final member in _allMembers(detail)) {
    if (member.player.id == id) return member.isPlaying;
  }
  return null;
}

String? _noteFor(MatchParticipationDetail detail, int? id) {
  for (final member in _allMembers(detail)) {
    if (member.player.id == id) return member.note;
  }
  return null;
}

class _ParticipationContent extends StatefulWidget {
  final MatchParticipationDetail detail;
  final Future<void> Function() onRespond;
  final Future<void> Function(PlayerApiModel) onRespondFor;
  final Future<void> Function(int playerId) onDeleteResponse;

  const _ParticipationContent({
    required this.detail,
    required this.onRespond,
    required this.onRespondFor,
    required this.onDeleteResponse,
  });

  @override
  State<_ParticipationContent> createState() => _ParticipationContentState();
}

class _ParticipationContentState extends State<_ParticipationContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        _ParticipationOverview(
          detail: detail,
          onRespond: () => widget.onRespond(),
        ),
        if (detail.currentPlayer != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 12),
              ),
              icon: const Icon(Icons.person_add_alt, size: 16),
              label: const Text('Zadat za někoho jiného'),
              onPressed: () async {
                final players = detail.eligiblePlayers
                    .where((player) => player.id != detail.currentPlayer?.id)
                    .toList();
                final player = await showDialog<PlayerApiModel>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Za koho odpovídáš?'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: players.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  player.name.isEmpty
                                      ? '?'
                                      : player.name
                                            .substring(0, 1)
                                            .toUpperCase(),
                                ),
                              ),
                              title: Text(player.name),
                              subtitle: Text(player.fan ? 'Fanoušek' : 'Hráč'),
                              onTap: () => Navigator.pop(ctx, player),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
                if (player != null && context.mounted) {
                  await widget.onRespondFor(player);
                }
              },
            ),
          ),
        const SizedBox(height: 12),
        _ParticipationRoster(
          detail: detail,
          onDeleteResponse: widget.onDeleteResponse,
        ),
      ],
    );
  }
}

const _playingGreen = Color(0xFF2F8B46);
const _nonPlayingTeal = Color(0xFF218C83);
const _maybeOrange = Color(0xFFE78A24);
const _notGoingRed = Color(0xFFD85656);

class _ParticipationOverview extends StatelessWidget {
  final MatchParticipationDetail detail;
  final VoidCallback onRespond;

  const _ParticipationOverview({required this.detail, required this.onRespond});

  @override
  Widget build(BuildContext context) {
    final playing = detail.attendingPlayers.where((m) => m.isPlaying).length;
    final notPlaying =
        detail.attendingPlayers.length - playing + detail.attendingFans.length;
    final maybe = detail.maybePlayers.length + detail.maybeFans.length;
    final absent =
        detail.notAttendingPlayers.length + detail.notAttendingFans.length;
    final currentPlaying = _playingFor(detail, detail.currentPlayer?.id);
    final status = detail.currentStatus;
    final label = switch (status) {
      MatchParticipationStatus.attending =>
        currentPlaying == false ? 'JDU JAKO FANOUŠEK' : 'JDU A HRAJU',
      MatchParticipationStatus.maybe =>
        currentPlaying == false ? 'MOŽNÁ JAKO FANOUŠEK' : 'MOŽNÁ JAKO HRÁČ',
      MatchParticipationStatus.notAttending => 'NEJDU',
      null => 'VYBER ÚČAST',
    };
    final color = switch (status) {
      MatchParticipationStatus.attending =>
        currentPlaying == false ? _nonPlayingTeal : _playingGreen,
      MatchParticipationStatus.maybe => _maybeOrange,
      MatchParticipationStatus.notAttending => _notGoingRed,
      null => _playingGreen,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onRespond,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      status == null ? 'Vybrat' : 'Změnit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.expand_more, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(36),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Přidat poznámku',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Text(
              'ÚČAST HRÁČŮ',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              '$playing hraje · minimum 6',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 5),
        _ParticipationBar(
          playing: playing,
          notPlaying: notPlaying,
          maybe: maybe,
          absent: absent,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _CountChip('Jdu a hraju', playing, _playingGreen),
            _CountChip('Možná', maybe, _maybeOrange),
            _CountChip('Fanoušek', notPlaying, _nonPlayingTeal),
            _CountChip('Nejdu', absent, _notGoingRed),
          ],
        ),
      ],
    );
  }
}

class _ParticipationBar extends StatelessWidget {
  final int playing, notPlaying, maybe, absent;
  const _ParticipationBar({
    required this.playing,
    required this.notPlaying,
    required this.maybe,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final other = notPlaying + maybe + absent;
    final afterMinimum = playing > 6 ? playing : 6;
    final total = afterMinimum + other;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 12,
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: context.appColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              if (playing > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: width * playing / total,
                    height: 8,
                    color: _playingGreen,
                  ),
                ),
              for (final segment in <(int, int, Color)>[
                (afterMinimum, maybe, _maybeOrange),
                (afterMinimum + maybe, notPlaying, _nonPlayingTeal),
                (afterMinimum + maybe + notPlaying, absent, _notGoingRed),
              ])
                if (segment.$2 > 0)
                  Positioned(
                    left: width * segment.$1 / total,
                    top: 0,
                    child: Container(
                      width: width * segment.$2 / total,
                      height: 8,
                      color: segment.$3,
                    ),
                  ),
              Positioned(
                left: (width * 6 / total - 1).clamp(0, width - 2),
                top: 0,
                child: Container(
                  width: 2,
                  height: 12,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: color.withAlpha(22),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      '$label  $count',
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}

class _ParticipationRoster extends StatefulWidget {
  static const _avatarBackground = Color(0xFFE5E7EB);
  static const _avatarInitial = Color(0xFFE66A1F);
  final MatchParticipationDetail detail;
  final Future<void> Function(int playerId) onDeleteResponse;
  const _ParticipationRoster({
    required this.detail,
    required this.onDeleteResponse,
  });

  @override
  State<_ParticipationRoster> createState() => _ParticipationRosterState();
}

class _ParticipationRosterState extends State<_ParticipationRoster> {
  final _exiting = <int>{};
  final _entering = <int>{};
  late List<(MatchParticipationMember, String, Color, IconData)>
  _displayMembers;
  int _updateGeneration = 0;

  @override
  void initState() {
    super.initState();
    _displayMembers = _membersFor(widget.detail);
  }

  @override
  void didUpdateWidget(covariant _ParticipationRoster oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _membersFor(widget.detail);
    final previousById = {
      for (final row in _displayMembers)
        if (row.$1.player.id != null) row.$1.player.id!: row.$2,
    };
    final changed = <int>{};
    final added = <int>{};
    for (final row in next) {
      final id = row.$1.player.id;
      if (id == null) continue;
      final previous = previousById[id];
      if (previous == null) {
        added.add(id);
      } else if (previous != row.$2) {
        changed.add(id);
      }
    }
    final generation = ++_updateGeneration;
    if (changed.isNotEmpty) {
      _exiting.addAll(changed);
      Future<void>.delayed(const Duration(milliseconds: 430), () {
        if (!mounted || generation != _updateGeneration) return;
        setState(() {
          _displayMembers = _membersFor(widget.detail);
          _exiting.removeAll(changed);
          _entering.addAll(changed);
          _entering.addAll(added);
        });
        _revealEntries({...changed, ...added});
      });
    } else {
      _displayMembers = next;
      _entering.addAll(added);
      _revealEntries(added);
    }
  }

  void _revealEntries(Set<int> ids) {
    if (ids.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entering.removeAll(ids));
    });
  }

  List<(MatchParticipationMember, String, Color, IconData)> _membersFor(
    MatchParticipationDetail detail,
  ) => [
    for (final member in [...detail.attendingPlayers, ...detail.attendingFans])
      if (member.isPlaying)
        (member, 'Jdu a hraju', _playingGreen, Icons.check_circle),
    for (final member in [...detail.maybePlayers, ...detail.maybeFans])
      if (member.isPlaying)
        (member, 'Možná jako hráč', _maybeOrange, Icons.help),
    for (final member in [...detail.attendingPlayers, ...detail.attendingFans])
      if (!member.isPlaying)
        (member, 'Jdu jako fanoušek', _nonPlayingTeal, Icons.check_circle),
    for (final member in [...detail.maybePlayers, ...detail.maybeFans])
      if (!member.isPlaying)
        (member, 'Možná jako fanoušek', _maybeOrange, Icons.help),
    for (final member in [
      ...detail.notAttendingPlayers,
      ...detail.notAttendingFans,
    ])
      (member, 'Nejdu', _notGoingRed, Icons.cancel),
  ];

  @override
  Widget build(BuildContext context) {
    final members = _displayMembers;
    if (members.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++) ...[
            AnimatedSwitcher(
              key: ValueKey('slot-${members[i].$1.player.id}'),
              duration: const Duration(milliseconds: 420),
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                alignment: Alignment.topCenter,
                child: FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.35, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
              ),
              child:
                  _exiting.contains(members[i].$1.player.id) ||
                      _entering.contains(members[i].$1.player.id)
                  ? SizedBox(
                      key: ValueKey('removed-${members[i].$1.player.id}'),
                      width: double.infinity,
                    )
                  : ListTile(
                      key: ValueKey('member-${members[i].$1.player.id}'),
                      dense: true,
                      leading: PopupMenuButton<_AvatarAction>(
                        tooltip: 'Možnosti hráče',
                        onSelected: (action) {
                          if (action == _AvatarAction.delete) {
                            _removeAttendance(members[i].$1);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: _AvatarAction.profile,
                            child: Text('Zobrazit profil'),
                          ),
                          if (members[i].$1.canDelete &&
                              members[i].$1.player.id != null)
                            const PopupMenuItem(
                              value: _AvatarAction.delete,
                              child: Text('Smazat účast'),
                            ),
                        ],
                        child: SizedBox(
                          width: 46,
                          height: 46,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Center(child: _avatar(members[i].$1)),
                              ),
                              const Positioned(
                                right: 0,
                                bottom: 0,
                                child: IgnorePointer(
                                  child: Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: _ParticipationRoster._avatarInitial,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      title: Text(
                        members[i].$1.player.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: members[i].$3.withAlpha(32),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              members[i].$2,
                              style: TextStyle(
                                color: members[i].$3,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (_memberNote(members[i].$1) case final note?)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      note,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: Icon(
                        members[i].$4,
                        color: members[i].$3,
                        size: 20,
                      ),
                    ),
            ),
            if (i < members.length - 1) const Divider(height: 1, indent: 72),
          ],
        ],
      ),
    );
  }

  String _initial(String name) => name.isEmpty ? '?' : name[0].toUpperCase();

  Widget _avatar(MatchParticipationMember member) {
    final fallback = Text(
      _initial(member.player.name),
      style: const TextStyle(
        color: _ParticipationRoster._avatarInitial,
        fontWeight: FontWeight.bold,
      ),
    );
    return member.avatarUserId == null
        ? CircleAvatar(
            radius: 20,
            backgroundColor: _ParticipationRoster._avatarBackground,
            child: fallback,
          )
        : UserAvatar(
            userId: member.avatarUserId!,
            radius: 20,
            backgroundColor: _ParticipationRoster._avatarBackground,
            fallback: fallback,
          );
  }

  Future<void> _removeAttendance(MatchParticipationMember member) async {
    final id = member.player.id;
    if (id == null || !mounted || _exiting.contains(id)) return;
    setState(() => _exiting.add(id));
    await Future<void>.delayed(const Duration(milliseconds: 430));
    if (!mounted) return;
    try {
      await widget.onDeleteResponse(id);
    } finally {
      if (mounted) setState(() => _exiting.remove(id));
    }
  }

  String? _memberNote(MatchParticipationMember member) {
    final note =
        member.note ??
        (member.comments.isEmpty ? '' : member.comments.last.text);
    if (note.trim().isNotEmpty) return note.trim();
    final actor = member.respondedBy;
    if (actor != null && actor.id != member.player.id) {
      return 'Zadal hráč ${actor.name}';
    }
    return null;
  }
}

enum _AvatarAction { profile, delete }
