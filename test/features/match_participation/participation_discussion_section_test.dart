import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/match_participation/screens/match_participation_screen.dart';
import 'package:trus_app/models/api/participation/match_participation_comment.dart';
import 'package:trus_app/models/api/participation/match_participation_reaction.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/theme/app_theme.dart';

void main() {
  testWidgets(
    'discussion header has finite width with the global button theme',
    (tester) async {
      final player = PlayerApiModel(
        id: 7,
        name: 'Matěj',
        birthday: DateTime(2000),
        fan: false,
        active: true,
      );
      final comment = MatchParticipationComment(
        id: 1,
        author: player,
        text: 'Dorazím později.',
        createdAt: DateTime(2026, 8, 28),
        upVotes: 0,
        downVotes: 0,
        currentUserReaction: null,
        replies: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SizedBox(
              width: 328,
              child: ParticipationDiscussionSection(
                comments: [comment],
                canAddComment: true,
                canDiscuss: true,
                currentPlayerId: player.id,
                onAddComment: () {},
                onReply: (_) async {},
                onReact: (_, MatchParticipationReaction reaction) async {},
                onDelete: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Komentáře (1)'), findsOneWidget);
      expect(find.byTooltip('Přidat komentář'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
