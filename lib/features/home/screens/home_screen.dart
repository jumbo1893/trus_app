import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/home/birthday_text.dart';
import 'package:trus_app/features/app_notice/widgets/app_notice_bottom_sheet.dart';
import 'package:trus_app/features/match_participation/widgets/participation_response_bottom_sheet.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/home/screens/rotating_stats_widget.dart';
import 'package:trus_app/models/api/app_notice/app_notice.dart';
import 'package:trus_app/models/api/home/home_setup.dart';

import '../../../common/widgets/football/football_match_box.dart';
import '../../../common/widgets/home/random_fact_box.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../controller/home_notifier.dart';

class HomeScreen extends CustomConsumerStatefulWidget {
  static const String id = "home-screen";

  const HomeScreen({Key? key})
    : super(key: key, title: "Trusí appka", name: id);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  static const double sectionSpacing = 16;
  final Set<int> _presentedNoticeIds = {};
  final Set<int> _presentedParticipationMatchIds = {};
  late final ProviderSubscription<AsyncValue<AppNotice?>> _noticeSubscription;
  late final ProviderSubscription<AsyncValue<HomeSetup>> _setupSubscription;
  Future<void> _sheetQueue = Future.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _noticeSubscription = ref.listenManual<AsyncValue<AppNotice?>>(
      homeNotifierProvider.select((state) => state.appNotice),
      (_, next) {
        final notice = next.asData?.value;
        if (notice == null || !_presentedNoticeIds.add(notice.id)) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final notifier = ref.read(homeNotifierProvider.notifier);
          _enqueueSheet(() async {
            await AppNoticeBottomSheet.show(
              context,
              notice: notice,
              onAction: notifier.onAppNoticeAction,
            );
            await notifier.markAppNoticeShown(notice.id);
          });
        });
      },
      fireImmediately: true,
    );
    _setupSubscription = ref.listenManual<AsyncValue<HomeSetup>>(
      homeNotifierProvider.select((state) => state.setup),
      (_, next) {
        final prompt = next.asData?.value.participationPrompt;
        final matchId = prompt?.footballMatch.id;
        if (prompt == null ||
            matchId == null ||
            !_presentedParticipationMatchIds.add(matchId)) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _enqueueSheet(() async {
            final choice = await ParticipationResponseBottomSheet.show(
              context,
              footballMatch: prompt.footballMatch,
              currentPlayer: prompt.currentPlayer,
              eligiblePlayers: prompt.eligiblePlayers,
              reconsideration: prompt.reconsideration,
            );
            if (choice == null || !mounted) return;
            final notifier = ref.read(homeNotifierProvider.notifier);
            if (choice.createNewPlayer) {
              notifier.startNewPlayerParticipation(
                prompt.footballMatch,
                choice.status,
                comment: choice.comment,
              );
            } else {
              await notifier.respondToParticipation(
                prompt.footballMatch,
                choice.status,
                player: choice.player,
                comment: choice.comment,
              );
            }
          });
        });
      },
      fireImmediately: true,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    _presentedParticipationMatchIds.clear();
    ref.read(homeNotifierProvider.notifier).load().catchError((_) {});
  }

  void _enqueueSheet(Future<void> Function() showSheet) {
    _sheetQueue = _sheetQueue.then<void>((_) {}, onError: (_, __) {}).then((
      _,
    ) async {
      if (!mounted) return;
      await showSheet();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _noticeSubscription.close();
    _setupSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleImagePath = isDark
        ? 'images/nazev_background_dark.png'
        : 'images/nazev_background.png';

    return Scaffold(
      body: RefreshIndicator(
        color: context.appColors.legacyAccent,
        backgroundColor: context.appColors.cardBackground,
        onRefresh: notifier.load,
        notificationPredicate: (n) => n.depth == 0,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          children: [
            state.setup.when(
              data: (setup) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(titleImagePath, height: 76, width: 331),
                    const SizedBox(height: sectionSpacing),

                    FootballMatchBox(
                      isNextMatch: true,
                      dashboardMatch: setup.nextMatch,
                      appTeamApiModel: appTeam,
                      onAddPlayers: notifier.onButtonAddPlayersClick,
                      onAddGoals: notifier.onButtonAddGoalsClick,
                      onAddBeer: notifier.onButtonAddBeerClick,
                      onAddFine: notifier.onButtonAddFineClick,
                      onDetailMatch: notifier.onButtonDetailMatchClick,
                      onParticipation: notifier.onParticipationClick,
                      onCommonMatches: notifier.onCommonMatchesClick,
                      onRedirect: notifier.onRedirect,
                    ),
                    const SizedBox(height: sectionSpacing),

                    FootballMatchBox(
                      isNextMatch: false,
                      dashboardMatch: setup.lastMatch,
                      appTeamApiModel: appTeam,
                      onAddPlayers: notifier.onButtonAddPlayersClick,
                      onAddGoals: notifier.onButtonAddGoalsClick,
                      onAddBeer: notifier.onButtonAddBeerClick,
                      onAddFine: notifier.onButtonAddFineClick,
                      onDetailMatch: notifier.onButtonDetailMatchClick,
                      onParticipation: notifier.onParticipationClick,
                      onCommonMatches: notifier.onCommonMatchesClick,
                      onRedirect: notifier.onRedirect,
                    ),
                    const SizedBox(height: sectionSpacing),

                    BirthdayText(nextBirthdayText: setup.nextBirthday),
                    const SizedBox(height: sectionSpacing),

                    RotatingStatsWidget(
                      statsBoards: setup.statsBoards,
                      onRedirect: notifier.onRedirect,
                    ),
                    const SizedBox(height: sectionSpacing),

                    RandomFactBox(facts: setup.randomFacts),

                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const _HomePlaceholder(),
              error: (_, __) => const _HomePlaceholder(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 600, child: Center(child: Text("")));
  }
}
