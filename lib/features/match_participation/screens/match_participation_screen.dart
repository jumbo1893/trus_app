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
          data: (detail) => _ParticipationContent(
            detail: detail,
            onRespond: () async {
              final choice = await ParticipationResponseBottomSheet.show(
                context,
                footballMatch: detail.footballMatch,
                currentPlayer: detail.currentPlayer,
                eligiblePlayers: detail.eligiblePlayers,
              );
              if (choice == null || !context.mounted) return;
              if (choice.createNewPlayer) {
                notifier.startNewPlayerFlow(
                  choice.status,
                  comment: choice.comment,
                );
              } else {
                await notifier.respond(
                  choice.status,
                  player: choice.player,
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
    );
  }
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

class _ParticipationContent extends StatelessWidget {
  final MatchParticipationDetail detail;
  final VoidCallback onRespond;
  final Future<void> Function(MatchParticipationComment? parent) onAddComment;
  final Future<void> Function(
    int commentId,
    MatchParticipationReaction reaction,
  )
  onReact;
  final Future<void> Function(MatchParticipationComment comment) onDelete;

  const _ParticipationContent({
    required this.detail,
    required this.onRespond,
    required this.onAddComment,
    required this.onReact,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 14),
        _ParticipationGroup(
          title: 'Zúčastní se',
          icon: Icons.check_circle_outline,
          accent: Colors.green.shade700,
          players: detail.attendingPlayers,
          fans: detail.attendingFans,
        ),
        const SizedBox(height: 12),
        _ParticipationGroup(
          title: 'Možná',
          icon: Icons.help_outline,
          accent: Colors.orange.shade700,
          players: detail.maybePlayers,
          fans: detail.maybeFans,
        ),
        const SizedBox(height: 12),
        _ParticipationGroup(
          title: 'Nezúčastní se',
          icon: Icons.cancel_outlined,
          accent: colors.errorForeground,
          players: detail.notAttendingPlayers,
          fans: detail.notAttendingFans,
        ),
        const SizedBox(height: 12),
        ParticipationDiscussionSection(
          comments: comments,
          canAddComment: detail.currentStatus != null,
          canDiscuss: canDiscuss,
          currentPlayerId: detail.currentPlayer?.id,
          onAddComment: () => onAddComment(null),
          onReply: onAddComment,
          onReact: onReact,
          onDelete: onDelete,
        ),
      ],
    );
  }
}

class _ParticipationGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<MatchParticipationMember> players;
  final List<MatchParticipationMember> fans;

  const _ParticipationGroup({
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
    return Card(
      color: colors.cardBackground,
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
            ),
            const SizedBox(height: 10),
            _MemberAudience(
              title: 'Fanoušci',
              icon: Icons.emoji_people_outlined,
              members: fans,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberAudience extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<MatchParticipationMember> members;

  const _MemberAudience({
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
              _MemberTile(member: members[index]),
              if (index < members.length - 1)
                Divider(color: colors.textMuted.withAlpha(35)),
            ],
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MatchParticipationMember member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              member.player.name,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
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
  }
}

class ParticipationDiscussionSection extends StatelessWidget {
  final List<MatchParticipationComment> comments;
  final bool canAddComment;
  final bool canDiscuss;
  final int? currentPlayerId;
  final VoidCallback onAddComment;
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
    required this.canAddComment,
    required this.canDiscuss,
    required this.currentPlayerId,
    required this.onAddComment,
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
                    onPressed: onAddComment,
                    icon: const Icon(Icons.add_comment_outlined),
                  ),
              ],
            ),
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
      padding: EdgeInsets.only(left: depth == 0 ? 8 : 16, top: 5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 5),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.author.name,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(comment.text, style: TextStyle(color: colors.textSecondary)),
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
                    onPressed: () =>
                        onReact(comment.id, MatchParticipationReaction.up),
                  ),
                  _ReactionButton(
                    icon: Icons.thumb_down_alt_outlined,
                    count: comment.downVotes,
                    selected:
                        comment.currentUserReaction ==
                        MatchParticipationReaction.down,
                    onPressed: () =>
                        onReact(comment.id, MatchParticipationReaction.down),
                  ),
                  TextButton(
                    onPressed: () => onReply(comment),
                    child: const Text('Odpovědět'),
                  ),
                  if (currentPlayerId == comment.author.id)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: colors.errorForeground,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => onDelete(comment),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Smazat'),
                    ),
                ],
              ),
            for (final reply in comment.replies)
              _CommentTile(
                comment: reply,
                canDiscuss: canDiscuss,
                currentPlayerId: currentPlayerId,
                onReply: onReply,
                onReact: onReact,
                onDelete: onDelete,
                depth: depth + 1,
              ),
          ],
        ),
      ),
    );
  }
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
