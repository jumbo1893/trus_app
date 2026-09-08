import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/home/birthday_text.dart';
import 'package:trus_app/features/app_notice/widgets/app_notice_bottom_sheet.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/home/screens/rotating_stats_widget.dart';
import 'package:trus_app/models/api/app_notice/app_notice.dart';
import 'package:trus_app/models/api/home/home_setup.dart';
import 'package:trus_app/services/permissions/authenticated_permissions_provider.dart';
import 'package:trus_app/services/crash_reporting_service.dart';

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
  late final ProviderSubscription<AsyncValue<AppNotice?>> _noticeSubscription;
  late final ProviderSubscription<AsyncValue<HomeSetup>> _setupSubscription;
  Future<void> _sheetQueue = Future.value();
  bool _permissionsStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _noticeSubscription = ref.listenManual<AsyncValue<AppNotice?>>(
      homeNotifierProvider.select((state) => state.appNotice),
      (_, next) {
        final notice = next.asData?.value;
        if (notice == null ||
            notice.dismissible ||
            !_presentedNoticeIds.add(notice.id)) {
          return;
        }

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
        if (next.hasValue && !_permissionsStarted) {
          _permissionsStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _enqueueSheet(
              () => ref.read(authenticatedPermissionsProvider.future),
            );
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    // Permission dialogs also trigger resumed. Keep queued/presented prompts
    // reserved for this screen's lifetime so they cannot stack up again.
    ref.read(homeNotifierProvider.notifier).load(background: true);
  }

  void _enqueueSheet(Future<void> Function() showSheet) {
    _sheetQueue = _sheetQueue
        .then<void>((_) {}, onError: (_, __) {})
        .then((_) async {
          if (!mounted) return;
          await showSheet();
        })
        .catchError((Object error, StackTrace stack) async {
          await CrashReportingService.recordError(
            error,
            stack,
            reason: 'Home sheet failed',
          );
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
            if (state.refreshFailed && state.setup.hasValue)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_off_outlined),
                  title: const Text('Zobrazuji poslední načtená data'),
                  subtitle: const Text(
                    'Aktualizace se nepodařila. Zkontroluj připojení.',
                  ),
                  trailing: TextButton(
                    onPressed: notifier.load,
                    child: const Text('Obnovit'),
                  ),
                ),
              ),
            state.setup.when(
              data: (setup) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      titleImagePath,
                      key: const ValueKey('home_logo'),
                      height: 76,
                      width: 331,
                    ),
                    const SizedBox(height: sectionSpacing),
                    for (final isNext
                        in setup.lastMatch?.needsEntry == true
                            ? [false, true]
                            : [true, false]) ...[
                      if (!isNext && setup.lastMatch?.needsEntry == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Dokončit zápis posledního zápasu',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      FootballMatchBox(
                        isNextMatch: isNext,
                        dashboardMatch: isNext
                            ? setup.nextMatch
                            : setup.lastMatch,
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
                    ],
                    if (setup.participationPrompt case final prompt?)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.how_to_reg_outlined),
                          title: const Text('Potvrď účast na příštím zápase'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => notifier.onParticipationClick(
                            prompt.footballMatch,
                          ),
                        ),
                      ),

                    if (state.appNotice.asData?.value case final notice?)
                      if (notice.dismissible &&
                          !_presentedNoticeIds.contains(notice.id))
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.campaign_outlined),
                            title: Text(notice.title),
                            subtitle: const Text('Novinky v aplikaci'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await AppNoticeBottomSheet.show(
                                context,
                                notice: notice,
                                onAction: notifier.onAppNoticeAction,
                              );
                              if (!mounted) return;
                              setState(
                                () => _presentedNoticeIds.add(notice.id),
                              );
                              await notifier.markAppNoticeShown(notice.id);
                            },
                          ),
                        ),
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
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Přehled se nepodařilo načíst',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Zkontroluj připojení a zkus to znovu.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: notifier.load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Zkusit znovu'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
