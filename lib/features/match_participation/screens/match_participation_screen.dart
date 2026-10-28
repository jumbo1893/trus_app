import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_widget.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/match_participation/controller/match_participation_notifier.dart';
import 'package:trus_app/features/match_participation/widgets/participation_response_bottom_sheet.dart';
import 'package:trus_app/features/match_participation/widgets/participation_comment_dialog.dart';
import 'package:trus_app/models/api/participation/match_participation_comment.dart';
import 'package:trus_app/models/api/participation/match_participation_detail.dart';
import 'package:trus_app/models/api/participation/match_participation_member.dart';
import 'package:trus_app/models/api/participation/match_participation_reaction.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class MatchParticipationScreen extends CustomConsumerWidget {
  static const String id = 'match-participation-screen';

  const MatchParticipationScreen({super.key})
    : super(title: 'Účast na zápase', name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footballMatchId = ref
        .watch(screenVariablesNotifierProvider)
        .footballMatchId;
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
          data: (detail) => _InitialParticipationPrompt(
            shouldPrompt: detail.currentStatus == null,
            onPrompt: () async {
              final choice = await ParticipationResponseBottomSheet.show(
                context,
                footballMatch: detail.footballMatch,
                currentPlayer: detail.currentPlayer,
                eligiblePlayers: detail.eligiblePlayers,
                initialPlaying: _playingFor(detail, detail.currentPlayer?.id),
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
            child: _ParticipationContent(
              detail: detail,
              onSendComment: (text) => notifier.addComment(text),
              onMoveSelf: (status, playing) => notifier.respond(
                status,
                player: detail.currentPlayer,
                playing: playing,
              ),
              onRespondFor: (player) async {
                final choice = await ParticipationResponseBottomSheet.show(
                  context,
                  footballMatch: detail.footballMatch,
                  currentPlayer: player,
                  eligiblePlayers: const [],
                  initialPlaying: _playingFor(detail, player.id),
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
              onAddComment: (parent) async {
                final text = await ParticipationCommentDialog.show(
                  context,
                  title: parent == null
                      ? 'Přidat komentář'
                      : 'Odpovědět uživateli ${parent.author.name}',
                );
                if (text == null || !context.mounted) return;
                await notifier.addComment(text, parentCommentId: parent?.id);
              },
              onReact: notifier.reactToComment,
              onDelete: (comment) async {
                final confirmed = await _confirmDeleteComment(
                  context,
                  hasReplies: comment.replies.isNotEmpty,
                );
                if (!confirmed || !context.mounted) return;
                await notifier.deleteComment(comment.id);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialParticipationPrompt extends StatefulWidget {
  final bool shouldPrompt;
  final Future<void> Function() onPrompt;
  final Widget child;

  const _InitialParticipationPrompt({
    required this.shouldPrompt,
    required this.onPrompt,
    required this.child,
  });

  @override
  State<_InitialParticipationPrompt> createState() =>
      _InitialParticipationPromptState();
}

class _InitialParticipationPromptState
    extends State<_InitialParticipationPrompt> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    if (widget.shouldPrompt && !_shown) {
      _shown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onPrompt();
      });
    }
    return widget.child;
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

Future<bool> _confirmDeleteComment(
  BuildContext context, {
  required bool hasReplies,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Smazat komentář?'),
          content: Text(
            hasReplies
                ? 'S komentářem se smažou také všechny jeho odpovědi a reakce.'
                : 'Komentář a jeho reakce budou trvale smazány.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Smazat'),
            ),
          ],
        ),
      ) ??
      false;
}

class _ParticipationContent extends StatefulWidget {
  final MatchParticipationDetail detail;
  final VoidCallback onRespond;
  final Future<void> Function(PlayerApiModel) onRespondFor;
  final Future<void> Function(MatchParticipationStatus, bool?) onMoveSelf;
  final Future<void> Function(MatchParticipationComment? parent) onAddComment;
  final Future<void> Function(String text) onSendComment;
  final Future<void> Function(
    int commentId,
    MatchParticipationReaction reaction,
  )
  onReact;
  final Future<void> Function(MatchParticipationComment comment) onDelete;

  const _ParticipationContent({
    required this.detail,
    required this.onRespond,
    required this.onRespondFor,
    required this.onMoveSelf,
    required this.onAddComment,
    required this.onSendComment,
    required this.onReact,
    required this.onDelete,
  });

  @override
  State<_ParticipationContent> createState() => _ParticipationContentState();
}

class _ParticipationContentState extends State<_ParticipationContent> {
  final _scrollController = ScrollController();
  final _commentKey = GlobalKey();
  final _commentController = TextEditingController();
  final _commentFocus = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _mention(PlayerApiModel player) {
    final mention = '@${player.name.trim()} ';
    _commentController.value = TextEditingValue(
      text: mention,
      selection: TextSelection.collapsed(offset: mention.length),
    );
    final target = _commentKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        alignment: 0.12,
      );
    }
    _commentFocus.requestFocus();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    await widget.onSendComment(text);
    if (mounted) _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final onRespond = widget.onRespond;
    final onRespondFor = widget.onRespondFor;
    final onMoveSelf = widget.onMoveSelf;
    final onAddComment = widget.onAddComment;
    final onReact = widget.onReact;
    final onDelete = widget.onDelete;
    final colors = context.appColors;
    final canDiscuss = detail.currentPlayer != null;
    final comments =
        [
            ...detail.attendingPlayers,
            ...detail.attendingFans,
            ...detail.maybePlayers,
            ...detail.maybeFans,
            ...detail.notAttendingPlayers,
            ...detail.notAttendingFans,
          ].expand((member) => member.comments).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Card(
          color: colors.cardBackground,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(Icons.sports_soccer, size: 34, color: colors.accent),
                const SizedBox(height: 10),
                Text(
                  detail.footballMatch.toStringForTitle(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  detail.footballMatch.toStringForDateSubtitle(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 14),
                Text(
                  detail.currentStatus == null
                      ? 'Zatím jsi neodpověděl.'
                      : 'Tvoje odpověď: ${detail.currentStatus!.label}',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onRespond,
                  icon: const Icon(Icons.how_to_reg),
                  label: Text(
                    detail.currentStatus == null
                        ? 'Odpovědět'
                        : 'Změnit odpověď',
                  ),
                ),
              ],
            ),
          ),
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
                  await onRespondFor(player);
                }
              },
            ),
          ),
        const SizedBox(height: 14),
        _ParticipationGroup(
          title: 'Zúčastní se',
          status: MatchParticipationStatus.attending,
          currentPlayerId: detail.currentPlayer?.id,
          onMoveSelf: onMoveSelf,
          onMemberTap: _mention,
          showPlaying: true,
          icon: Icons.check_circle_outline,
          accent: Colors.green.shade700,
          players: detail.attendingPlayers,
          fans: detail.attendingFans,
        ),
        const SizedBox(height: 12),
        _ParticipationGroup(
          title: 'Možná',
          status: MatchParticipationStatus.maybe,
          currentPlayerId: detail.currentPlayer?.id,
          onMoveSelf: onMoveSelf,
          onMemberTap: _mention,
          icon: Icons.help_outline,
          accent: Colors.orange.shade700,
          players: detail.maybePlayers,
          fans: detail.maybeFans,
        ),
        const SizedBox(height: 12),
        _ParticipationGroup(
          title: 'Nezúčastní se',
          status: MatchParticipationStatus.notAttending,
          currentPlayerId: detail.currentPlayer?.id,
          onMoveSelf: onMoveSelf,
          onMemberTap: _mention,
          icon: Icons.cancel_outlined,
          accent: colors.errorForeground,
          players: detail.notAttendingPlayers,
          fans: detail.notAttendingFans,
        ),
        const SizedBox(height: 12),
        ParticipationDiscussionSection(
          key: _commentKey,
          comments: comments,
          mentionNames: _allMembers(
            detail,
          ).map((member) => member.player.name).toSet().toList(),
          commentController: _commentController,
          commentFocus: _commentFocus,
          onSendComment: _sendComment,
          canAddComment: detail.currentStatus != null,
          canDiscuss: canDiscuss,
          currentPlayerId: detail.currentPlayer?.id,
          onReply: onAddComment,
          onReact: onReact,
          onDelete: onDelete,
        ),
      ],
    );
  }
}

class _ParticipationGroup extends StatelessWidget {
  final bool showPlaying;
  final MatchParticipationStatus status;
  final int? currentPlayerId;
  final Future<void> Function(MatchParticipationStatus, bool?) onMoveSelf;
  final void Function(PlayerApiModel) onMemberTap;
  final String title;
  final IconData icon;
  final Color accent;
  final List<MatchParticipationMember> players;
  final List<MatchParticipationMember> fans;

  const _ParticipationGroup({
    this.showPlaying = false,
    required this.status,
    required this.currentPlayerId,
    required this.onMoveSelf,
    required this.onMemberTap,
    required this.title,
    required this.icon,
    required this.accent,
    required this.players,
    required this.fans,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = players.length + fans.length;
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data == currentPlayerId,
      onAcceptWithDetails: (_) => onMoveSelf(
        status,
        status == MatchParticipationStatus.attending ? true : null,
      ),
      builder: (context, candidates, rejected) => Card(
        color: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: candidates.isNotEmpty ? accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 21),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$title ($total)',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _MemberAudience(
                title: 'Hráči',
                icon: Icons.sports_soccer_outlined,
                members: players,
                showPlaying: showPlaying,
                currentPlayerId: currentPlayerId,
                onMemberTap: onMemberTap,
                onTogglePlaying: showPlaying
                    ? (member) => onMoveSelf(status, !member.isPlaying)
                    : null,
              ),
              const SizedBox(height: 10),
              _MemberAudience(
                title: 'Fanoušci',
                icon: Icons.emoji_people_outlined,
                members: fans,
                showPlaying: showPlaying,
                currentPlayerId: currentPlayerId,
                onMemberTap: onMemberTap,
                onTogglePlaying: showPlaying
                    ? (member) => onMoveSelf(status, !member.isPlaying)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberAudience extends StatelessWidget {
  final bool showPlaying;
  final int? currentPlayerId;
  final void Function(PlayerApiModel) onMemberTap;
  final Future<void> Function(MatchParticipationMember)? onTogglePlaying;
  final String title;
  final IconData icon;
  final List<MatchParticipationMember> members;

  const _MemberAudience({
    required this.showPlaying,
    required this.currentPlayerId,
    required this.onMemberTap,
    required this.onTogglePlaying,
    required this.title,
    required this.icon,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: colors.accent),
              const SizedBox(width: 6),
              Text(
                '$title (${members.length})',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          if (members.isEmpty)
            Text('Zatím nikdo', style: TextStyle(color: colors.textMuted))
          else
            for (var index = 0; index < members.length; index++) ...[
              _MemberTile(
                member: members[index],
                showPlaying: showPlaying,
                isCurrentPlayer: members[index].player.id == currentPlayerId,
                onMemberTap: onMemberTap,
                onTogglePlaying: onTogglePlaying,
              ),
              if (index < members.length - 1)
                Divider(color: colors.textMuted.withAlpha(35)),
            ],
        ],
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  final bool showPlaying;
  final bool isCurrentPlayer;
  final Future<void> Function(MatchParticipationMember)? onTogglePlaying;
  final MatchParticipationMember member;
  final void Function(PlayerApiModel) onMemberTap;

  const _MemberTile({
    required this.member,
    required this.onMemberTap,
    required this.showPlaying,
    required this.isCurrentPlayer,
    required this.onTogglePlaying,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onMemberTap(member.player),
              onDoubleTap:
                  isCurrentPlayer && showPlaying && onTogglePlaying != null
                  ? () => onTogglePlaying!(member)
                  : null,
              child: Text(
                '${member.player.name}${showPlaying ? " · ${member.isPlaying ? "hrající" : "nehrající"}" : ""}'
                '${member.respondedBy != null ? "\nZadal/a: ${member.respondedBy!.name}" : ""}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (member.canDelete)
            IconButton(
              tooltip: 'Smazat účast',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Smazat účast: ${member.player.name}?'),
                    content: const Text(
                      'Smažou se také komentáře této účasti a jejich reakce.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Zrušit'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Smazat'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
                final id = ref
                    .read(screenVariablesNotifierProvider)
                    .footballMatchId;
                if (id != null) {
                  await ref
                      .read(matchParticipationNotifierProvider(id).notifier)
                      .deleteResponse(member.player.id!);
                }
              },
            ),
          if (!member.player.active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: colors.textMuted.withAlpha(20),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'neaktivní',
                style: TextStyle(color: colors.textMuted, fontSize: 10),
              ),
            ),
        ],
      ),
    );
    if (!isCurrentPlayer || member.player.id == null) return tile;
    return LongPressDraggable<int>(
      data: member.player.id!,
      feedback: Material(
        color: Colors.transparent,
        child: Chip(label: Text(member.player.name)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: tile),
      child: tile,
    );
  }
}

class ParticipationDiscussionSection extends StatelessWidget {
  final List<MatchParticipationComment> comments;
  final List<String> mentionNames;
  final TextEditingController commentController;
  final FocusNode commentFocus;
  final Future<void> Function() onSendComment;
  final bool canAddComment;
  final bool canDiscuss;
  final int? currentPlayerId;
  final Future<void> Function(MatchParticipationComment parent) onReply;
  final Future<void> Function(
    int commentId,
    MatchParticipationReaction reaction,
  )
  onReact;
  final Future<void> Function(MatchParticipationComment comment) onDelete;

  const ParticipationDiscussionSection({
    super.key,
    required this.comments,
    required this.mentionNames,
    required this.commentController,
    required this.commentFocus,
    required this.onSendComment,
    required this.canAddComment,
    required this.canDiscuss,
    required this.currentPlayerId,
    required this.onReply,
    required this.onReact,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final count = comments.fold<int>(
      0,
      (sum, comment) => sum + _commentCount(comment),
    );
    return Card(
      color: colors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.forum_outlined, size: 20, color: colors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Komentáře ($count)',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (canAddComment)
                  IconButton(
                    tooltip: 'Přidat komentář',
                    style: IconButton.styleFrom(
                      foregroundColor: colors.accent,
                      backgroundColor: colors.accentSoft,
                    ),
                    onPressed: commentFocus.requestFocus,
                    icon: const Icon(Icons.add_comment_outlined),
                  ),
              ],
            ),
            if (canAddComment) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: colors.accentSoft,
                    child: Icon(Icons.person, size: 18, color: colors.accent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      focusNode: commentFocus,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        hintText: 'Napiš komentář…',
                        counterText: '',
                        filled: true,
                        fillColor: colors.backgroundSecondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Odeslat komentář',
                    onPressed: onSendComment,
                    icon: Icon(Icons.send_rounded, color: colors.accent),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            if (comments.isEmpty)
              Text(
                'Zatím žádné komentáře',
                style: TextStyle(color: colors.textMuted),
              )
            else
              for (final comment in comments)
                _CommentTile(
                  comment: comment,
                  mentionNames: mentionNames,
                  canDiscuss: canDiscuss,
                  currentPlayerId: currentPlayerId,
                  onReply: onReply,
                  onReact: onReact,
                  onDelete: onDelete,
                ),
          ],
        ),
      ),
    );
  }

  int _commentCount(MatchParticipationComment comment) {
    return 1 +
        comment.replies.fold<int>(
          0,
          (sum, reply) => sum + _commentCount(reply),
        );
  }
}

class _CommentTile extends StatelessWidget {
  final MatchParticipationComment comment;
  final List<String> mentionNames;
  final bool canDiscuss;
  final int? currentPlayerId;
  final Future<void> Function(MatchParticipationComment parent) onReply;
  final Future<void> Function(
    int commentId,
    MatchParticipationReaction reaction,
  )
  onReact;
  final Future<void> Function(MatchParticipationComment comment) onDelete;
  final int depth;

  const _CommentTile({
    required this.comment,
    required this.mentionNames,
    required this.canDiscuss,
    required this.currentPlayerId,
    required this.onReply,
    required this.onReact,
    required this.onDelete,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : 24, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colors.accentSoft,
                child: Text(
                  comment.author.name.isEmpty
                      ? '?'
                      : comment.author.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: colors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.author.name,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 14,
                                    ),
                                    children: _commentSpans(
                                      comment.text,
                                      mentionNames,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (currentPlayerId == comment.author.id)
                          IconButton(
                            tooltip: 'Smazat komentář',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onDelete(comment),
                            icon: Icon(
                              Icons.delete_outline,
                              size: 17,
                              color: colors.errorForeground,
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                        _commentTime(context, comment.createdAt),
                        style: TextStyle(color: colors.textMuted, fontSize: 11),
                      ),
                    ),
                    if (canDiscuss)
                      Wrap(
                        spacing: 2,
                        children: [
                          _ReactionButton(
                            icon: Icons.thumb_up_alt_outlined,
                            count: comment.upVotes,
                            selected:
                                comment.currentUserReaction ==
                                MatchParticipationReaction.up,
                            onPressed: () => onReact(
                              comment.id,
                              MatchParticipationReaction.up,
                            ),
                          ),
                          _ReactionButton(
                            icon: Icons.thumb_down_alt_outlined,
                            count: comment.downVotes,
                            selected:
                                comment.currentUserReaction ==
                                MatchParticipationReaction.down,
                            onPressed: () => onReact(
                              comment.id,
                              MatchParticipationReaction.down,
                            ),
                          ),
                          TextButton(
                            onPressed: () => onReply(comment),
                            child: const Text('Odpovědět'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          for (final reply in comment.replies)
            _CommentTile(
              comment: reply,
              mentionNames: mentionNames,
              canDiscuss: canDiscuss,
              currentPlayerId: currentPlayerId,
              onReply: onReply,
              onReact: onReact,
              onDelete: onDelete,
              depth: depth + 1,
            ),
        ],
      ),
    );
  }
}

String _commentTime(BuildContext context, DateTime createdAt) {
  final local = createdAt.toLocal();
  final time = TimeOfDay.fromDateTime(local).format(context);
  return '${local.day}.${local.month}. · $time';
}

List<InlineSpan> _commentSpans(String text, List<String> names) {
  final mentions = names.where((name) => name.trim().isNotEmpty).toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  if (mentions.isEmpty) return [TextSpan(text: text)];
  final pattern = RegExp(
    '@(?:${mentions.map(RegExp.escape).join('|')})(?=\\s|[.,!?;:]|\$)',
  );
  final spans = <InlineSpan>[];
  var offset = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > offset) {
      spans.add(TextSpan(text: text.substring(offset, match.start)));
    }
    spans.add(
      TextSpan(
        text: match.group(0),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
    offset = match.end;
  }
  if (offset < text.length) spans.add(TextSpan(text: text.substring(offset)));
  return spans;
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onPressed;

  const _ReactionButton({
    required this.icon,
    required this.count,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: selected ? colors.accent : colors.textMuted,
        visualDensity: VisualDensity.compact,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text('$count'),
    );
  }
}
