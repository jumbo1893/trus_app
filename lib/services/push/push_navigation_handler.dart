import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/main/ui/ui_feedback_notifier.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match/screens/match_detail_screen.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/features/player/controller/player_edit_notifier.dart';
import 'package:trus_app/features/player/player_notifier_args.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_notifier.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/models/api/notification/push/push_payload.dart';

class PushNavigationHandler {
  static void navigate(var ref, PushPayload payload) {
    final ui = ref.read(uiFeedbackProvider.notifier);
    final loadingToken = ui.startLoading("Otevírám notifikaci…");

    try {
      _navigateInternal(ref, payload);
    } finally {
      // Jen okamžitý loader na překlenutí mezi zavřením sheetu a inicializací cílové stránky.
      // Samotné stránky si následné API načítání řeší vlastním runUiWithResult loaderem.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 350), () {
          ui.stopLoading(loadingToken);
        });
      });
    }
  }

  static void _navigateInternal(var ref, PushPayload payload) {
    final screenNotifier = ref.read(screenNotifierProvider.notifier);
    final variables = ref.read(screenVariablesNotifierProvider.notifier);

    switch (payload.screenId) {
      case BeerSimpleScreen.id:
        if (payload.matchId != null) {
          variables.setMatchId(payload.matchId!);
        }
        screenNotifier.changeByFragmentId(BeerSimpleScreen.id);
        return;

      case MatchDetailScreen.id:
        if (payload.matchId != null) {
          final args = MatchNotifierArgs.footballMatchDetailByMatchId(payload.matchId!);

          // Pushka často oznamuje nově změněná data. Nechceme proto použít
          // starý detail/statistiky z memory cache ani už běžící provider se stejnými args.
          ref.read(matchRepositoryProvider).invalidateMatchDetailData(payload.matchId!);
          ref.invalidate(matchEditNotifierProvider(args));

          variables.setMatchId(payload.matchId!);
          variables.setMatchNotifierArgs(args);
          screenNotifier.changeByFragmentId(MatchDetailScreen.id);
          return;
        }

        if (payload.footballMatchId != null) {
          final args = MatchNotifierArgs.footballMatchDetailByFootballMatchId(
            payload.footballMatchId!,
          );

          // Stejný důvod jako výše: po kliknutí na push chceme čerstvý detail.
          ref.read(footballRepositoryProvider)
              .invalidateFootballMatchDetail(payload.footballMatchId!);
          ref.invalidate(matchEditNotifierProvider(args));

          variables.setFootballMatchId(payload.footballMatchId!);
          variables.setMatchNotifierArgs(args);
          screenNotifier.changeByFragmentId(MatchDetailScreen.id);
          return;
        }

        return;

      case ViewPlayerScreen.id:
        if (payload.playerId == null) {
          return;
        }

        final args = PlayerNotifierArgs.view(payload.playerId!);

        ref.read(playerRepositoryProvider).invalidatePlayerSetup(payload.playerId!);
        ref.invalidate(playerEditNotifierProvider(args));

        variables.setPlayerId(payload.playerId!);
        screenNotifier.changeByFragmentId(ViewPlayerScreen.id);
        return;

      case FineMatchScreen.id:
        if (payload.matchId != null) {
          variables.setMatchId(payload.matchId!);
        }
        screenNotifier.changeByFragmentId(FineMatchScreen.id);
        return;

      default:
        return;
    }
  }
}
