import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/common/widgets/header/header_card.dart';
import 'package:trus_app/common/widgets/rows/app_read_only_field.dart';
import 'package:trus_app/common/widgets/rows/form/form_card.dart';
import 'package:trus_app/common/widgets/rows/form/form_field_wrapper.dart';
import 'package:trus_app/common/widgets/rows/form/form_row.dart';
import 'package:trus_app/features/football/repository/football_api_service.dart';
import 'package:trus_app/features/football/repository/planned_match_api_service.dart';
import 'package:trus_app/features/football/screens/planned_match_editor.dart';
import 'package:trus_app/features/football/widgets/planned_match_photo.dart';
import 'package:trus_app/features/football/widgets/planned_match_status_button.dart';
import 'package:trus_app/features/match/widget/match_score_bar.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/chat/chat_controller.dart';
import 'package:trus_app/features/chat/chat_screen.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/match_participation/screens/match_participation_screen.dart';
import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
import 'package:trus_app/models/api/match/planned_match.dart';
import 'package:trus_app/theme/app_colors.dart';

class PlannedMatchSheet extends ConsumerStatefulWidget {
  final int? id;
  final int? footballMatchId;
  final bool startEditing;
  final bool showParticipationButton;
  final bool showPlannedMatchTab;

  const PlannedMatchSheet({
    super.key,
    this.id,
    this.footballMatchId,
    this.startEditing = false,
    this.showParticipationButton = true,
    this.showPlannedMatchTab = true,
  });

  @override
  ConsumerState<PlannedMatchSheet> createState() => _PlannedMatchSheetState();
}

class _PlannedMatchSheetState extends ConsumerState<PlannedMatchSheet> {
  late Future<PlannedMatch> planned;
  late Future<FootballMatchDetail> footballOnlyDetail;
  late bool editing;
  late bool showPlannedTab;

  @override
  void initState() {
    super.initState();
    editing = widget.startEditing;
    showPlannedTab = widget.startEditing;
    if (widget.showPlannedMatchTab) {
      _reload();
    } else {
      footballOnlyDetail = ref
          .read(footballApiServiceProvider)
          .getFootballMatchDetail(widget.footballMatchId!);
    }
  }

  void _reload() => planned = widget.id != null
      ? ref.read(plannedMatchApiProvider).get(widget.id!)
      : ref
            .read(plannedMatchApiProvider)
            .getByFootballMatch(widget.footballMatchId!);

  @override
  Widget build(BuildContext context) {
    if (!widget.showPlannedMatchTab) return _footballOnlySheet(context);
    return Material(
      color: context.appColors.backgroundPrimary,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.86,
        child: FutureBuilder<PlannedMatch>(
          future: planned,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Detail se nepodařilo načíst.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final match = snapshot.data!;
            return FutureBuilder<FootballMatchDetail?>(
              future: match.footballMatchId == null
                  ? Future.value(null)
                  : ref
                        .read(footballApiServiceProvider)
                        .getFootballMatchDetail(match.footballMatchId!),
              builder: (context, footballSnapshot) {
                if (footballSnapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final detail = footballSnapshot.data;
                final tabs = <Tab>[
                  if (detail != null) const Tab(text: 'Detail zápasu'),
                  const Tab(text: 'Plánovaný zápas'),
                ];
                if (detail?.mutualMatches.isNotEmpty == true) {
                  tabs.add(const Tab(text: 'H2H'));
                }
                return DefaultTabController(
                  length: tabs.length,
                  initialIndex: showPlannedTab && detail != null ? 1 : 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          match.opponent?.isNotEmpty == true
                              ? match.opponent!
                              : _typeName(match.type),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TabBar(tabs: tabs, isScrollable: true),
                      Expanded(
                        child: TabBarView(
                          children: [
                            if (detail != null)
                              _footballTab(
                                detail,
                                participation: match.isScheduled,
                              ),
                            editing && (match.isScheduled || match.isCancelled)
                                ? PlannedMatchEditor(
                                    match: match,
                                    onSaved: (saved) => setState(() {
                                      ref.invalidate(
                                        plannedMatchPhotoProvider(saved.id),
                                      );
                                      planned = Future.value(saved);
                                      editing = false;
                                    }),
                                    onCancel: () =>
                                        setState(() => editing = false),
                                  )
                                : _plannedTab(match),
                            if (detail?.mutualMatches.isNotEmpty == true)
                              _h2hTab(detail!),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _footballOnlySheet(BuildContext context) => Material(
    color: context.appColors.backgroundPrimary,
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.86,
      child: FutureBuilder<FootballMatchDetail>(
        future: footballOnlyDetail,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Detail se nepodařilo načíst.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final detail = snapshot.data!;
          final hasH2h = detail.mutualMatches.isNotEmpty;
          return DefaultTabController(
            length: hasH2h ? 2 : 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    detail.footballMatch.toStringForTitle(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TabBar(
                  tabs: [
                    const Tab(text: 'Detail zápasu'),
                    if (hasH2h) const Tab(text: 'H2H'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _footballTab(detail),
                      if (hasH2h) _h2hTab(detail),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _cards(List<Widget> items, {double bottomPadding = 24}) => ListView(
    padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
    children: items
        .map(
          (item) => item is ListTile
              ? Card(child: item)
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: item,
                ),
        )
        .toList(),
  );

  Widget _plannedTab(PlannedMatch match) => Stack(
    children: [
      _cards([
        ListTile(
          leading: const Icon(Icons.chat_bubble_outline),
          title: const Text('Chat plánovaného zápasu'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pop();
            ref
                .read(screenNotifierProvider.notifier)
                .changeByFragmentId(ChatScreen.id);
            ref
                .read(chatControllerProvider.notifier)
                .load('planned-${match.id}');
          },
        ),
        if (match.hasPhoto)
          PlannedMatchPhoto(id: match.id, height: 180, width: double.infinity),
        ListTile(
          title: const Text('Typ'),
          subtitle: Text(_typeName(match.type)),
        ),
        ListTile(
          title: const Text('Datum'),
          subtitle: Text(matchDateToString(match.date, includeTime: true)),
        ),
        if (match.opponent?.isNotEmpty == true)
          ListTile(
            title: const Text('Soupeř'),
            subtitle: Text(match.opponent!),
          ),
        if (match.home != null)
          ListTile(
            title: const Text('Místo'),
            subtitle: Text(match.home! ? 'Doma' : 'Venku'),
          ),
        if (match.description?.isNotEmpty == true)
          ListTile(
            title: const Text('Popis'),
            subtitle: Text(match.description!),
          ),
        ListTile(
          title: const Text('Sezona'),
          subtitle: Text(_seasonName(match.seasonId)),
        ),
        ListTile(
          title: const Text('Stav'),
          subtitle: Text(_statusName(match.status)),
        ),
      ], bottomPadding: 100),
      if (!match.isScheduled && !match.isCancelled && match.matchId != null)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: FilledButton.icon(
            icon: Icon(
              match.isInProgress ? Icons.sports_soccer : Icons.list_alt,
            ),
            label: Text(
              match.isInProgress ? 'Otevřít živý zápas' : 'Otevřít zápas',
            ),
            onPressed: () {
              Navigator.of(context).pop();
              openPlannedMatchByStatus(ref.read, match);
            },
          ),
        ),
      if (match.isScheduled || match.isCancelled)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Material(
            elevation: 8,
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Upravit'),
                      onPressed: () => setState(() {
                        showPlannedTab = true;
                        editing = true;
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PlannedMatchStatusButton(
                      match: match,
                      onChanged: (result) {
                        if (result.matchId != null &&
                            (result.isCompleted || result.isInProgress)) {
                          Navigator.of(context).pop();
                          navigateAfterStatusChange(ref.read, result);
                          return;
                        }
                        setState(() => planned = Future.value(result));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );

  String _seasonName(int? id) {
    if (id == null) return 'Automatická sezona';
    final options = ref.watch(plannedSeasonOptionsProvider).asData?.value;
    if (options != null) {
      for (final season in options) {
        if (season.id == id) return season.name;
      }
    }
    return 'Sezona $id';
  }

  Widget _footballTab(FootballMatchDetail detail, {bool participation = true}) {
    final match = detail.footballMatch;
    final meta = [
      if (match.round > 0) '${match.round}. kolo',
      if (match.league.name.isNotEmpty) match.league.name,
      matchDateToString(match.date, includeTime: true),
    ].join(' · ');
    final score = match.simpleResultToString();
    final basicFields = <Widget>[
      if (match.stadium?.isNotEmpty == true)
        _readOnlyField('Stadion', match.stadium!),
      if (match.referee?.isNotEmpty == true)
        _readOnlyField('Rozhodčí', match.referee!),
      if (detail.weather != null)
        _readOnlyField('Počasí', detail.weatherToFootballDetail()),
    ];
    final extraFields = <Widget>[
      if (detail.homeTeamBestScorer != null)
        _readOnlyField(
          'Nejlepší střelec domácích',
          '${detail.homeTeamBestScorer}',
        ),
      if (detail.awayTeamBestScorer != null)
        _readOnlyField(
          'Nejlepší střelec hostů',
          '${detail.awayTeamBestScorer}',
        ),
      if (match.refereeComment?.isNotEmpty == true)
        _readOnlyField('Komentář rozhodčího', match.refereeComment!),
    ];
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HeaderCard(
                title:
                    '${match.homeTeam?.name ?? 'Domácí'}  ${score.isEmpty ? '–' : score}  ${match.awayTeam?.name ?? 'Hosté'}',
                text: meta,
              ),
            ),
            if (basicFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              FormCard(
                children: [
                  if (basicFields.length >= 2)
                    FormRow(children: basicFields.take(2).toList())
                  else
                    basicFields.first,
                  ...basicFields.skip(2),
                ],
              ),
            ],
            if (extraFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              FormCard(
                children: [
                  if (detail.homeTeamBestScorer != null &&
                      detail.awayTeamBestScorer != null)
                    FormRow(children: extraFields.take(2).toList())
                  else
                    ...extraFields.take(
                      extraFields.length -
                          (match.refereeComment?.isNotEmpty == true ? 1 : 0),
                    ),
                  if (match.refereeComment?.isNotEmpty == true)
                    extraFields.last,
                ],
              ),
            ],
          ],
        ),
        if (match.id != null && widget.showParticipationButton && participation)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'planned-match-participation-${match.id}',
              icon: const Icon(Icons.how_to_reg_outlined),
              label: const Text('Účast v zápase'),
              onPressed: () async {
                final id = match.id!;
                final variables = ref.read(
                  screenVariablesNotifierProvider.notifier,
                );
                final navigation = ref.read(screenNotifierProvider.notifier);
                Navigator.of(context).pop();
                variables.setFootballMatchId(id);
                await navigation.changeByFragmentId(
                  MatchParticipationScreen.id,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _readOnlyField(String label, String value) => FormFieldWrapper(
    label: label,
    child: AppReadOnlyField(value: value, allowWrap: true),
  );

  Widget _h2hTab(FootballMatchDetail detail) => _cards([
    if (detail.aggregateMatches != null || detail.aggregateScore != null)
      ListTile(
        title: const Text('Bilance'),
        subtitle: Text(
          '${detail.aggregateMatches ?? '—'} · skóre ${detail.aggregateScore ?? '—'}',
        ),
      ),
    ...detail.mutualMatches.map(
      (match) => ListTile(
        title: Text(match.toStringForTitle()),
        subtitle: Text(matchDateToString(match.date, includeTime: true)),
        trailing: Text(match.simpleResultToString()),
      ),
    ),
  ]);
}

String _typeName(String type) => switch (type) {
  'TRAINING' => 'Trénink',
  'FRIENDLY' => 'Přípravný zápas',
  'LEAGUE' => 'Ligový zápas',
  'CUP' => 'Pohár',
  'TEAMBUILDING' => 'Teambuilding',
  _ => type,
};

String _statusName(String status) => switch (status) {
  'SCHEDULED' => 'Naplánováno',
  'IN_PROGRESS' => 'Probíhá',
  'CANCELLED' => 'Zrušeno',
  'COMPLETED' => 'Odehráno',
  _ => status,
};
