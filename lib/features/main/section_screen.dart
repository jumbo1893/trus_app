import '../fine/screens/fine_screen.dart';
import '../season/screens/season_screen.dart';
import '../notification/screen/notification_screen.dart';
import 'widget/section_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../statistics/screens/unified_statistics_screen.dart';
import 'controller/screen_notifier.dart';
import '../ai/screens/ai_assistant_screen.dart';
import '../player/screens/player_screen.dart';

import '../steps/screens/step_screen.dart';

import '../achievement/screens/achievement_screen.dart';
import 'controller/main_notifier.dart';

import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/fine_match_screen.dart';

import '../match/screens/match_screen.dart';

import '../football/screens/football_fixtures_screen.dart';
import '../football/table/screens/football_table_screen.dart';

class SectionScreen extends CustomConsumerStatefulWidget {
  final String section;
  const SectionScreen({super.key, required this.section, required String title})
    : super(title: title, name: section);
  @override
  ConsumerState<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends ConsumerState<SectionScreen> {
  @override
  Widget build(BuildContext context) {
    void open(String id) =>
        ref.read(screenNotifierProvider.notifier).changeByFragmentId(id);
    Widget tile(IconData icon, String title, String subtitle, String id) =>
        SectionLink(
          icon: icon,
          title: Text(title),
          subtitle: Text(subtitle),
          onTap: () => open(id),
        );
    final List<Widget> items;
    switch (widget.section) {
      case 'matches-hub':
        items = [
          tile(
            Icons.event,
            'Týmové zápasy',
            'Zápasy, sestavy a výsledky vašeho týmu',
            MatchScreen.id,
          ),
          tile(
            Icons.calendar_month,
            'Ligový program',
            'Rozpis zápasů v soutěži',
            FootballFixturesScreen.id,
          ),
          tile(
            Icons.leaderboard,
            'Ligová tabulka',
            'Pořadí týmů v soutěži',
            FootballTableScreen.id,
          ),
        ];
      case 'entries-hub':
        items = [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Vyber, co chceš zapsat. Zápas můžeš zkontrolovat a změnit přímo v zápisu.',
            ),
          ),
          tile(
            Icons.sports_bar,
            'Zapsat piva',
            'Piva a panáky · seznam nebo čárkování',
            BeerSimpleScreen.id,
          ),
          tile(
            Icons.savings,
            'Zapsat pokuty',
            'Pro jednoho nebo více hráčů',
            FineMatchScreen.id,
          ),
          tile(
            Icons.sports_soccer,
            'Zapsat góly',
            'Vyber týmový zápas a zapiš střelce a asistence',
            MatchScreen.id,
          ),
        ];
      case 'statistics-hub':
        return const UnifiedStatisticsScreen();
      default:
        Widget row(IconData icon, String title, String id) => ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => open(id),
        );
        Widget group(List<Widget> children) => Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        );
        items = [
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              key: const PageStorageKey('more-matches'),
              leading: Icon(
                Icons.event_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Zápasy'),
              children: [
                row(Icons.sports_soccer_outlined, 'Odehrané', MatchScreen.id),
                row(
                  Icons.calendar_month_outlined,
                  'Program',
                  FootballFixturesScreen.id,
                ),
                row(
                  Icons.leaderboard_outlined,
                  'Tabulka',
                  FootballTableScreen.id,
                ),
              ],
            ),
          ),
          group([
            row(Icons.auto_awesome_outlined, 'TrusBot', AiAssistantScreen.id),
            row(
              Icons.emoji_events_outlined,
              'Achievementy',
              AchievementScreen.id,
            ),
            row(Icons.directions_walk, 'Kroky', StepScreen.id),
          ]),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              key: const PageStorageKey('more-team-management'),
              leading: Icon(
                Icons.groups_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Správa týmu'),
              children: [
                row(
                  Icons.receipt_long_outlined,
                  'Sazebník pokut',
                  FineScreen.id,
                ),
                row(Icons.group_outlined, 'Hráči', PlayerScreen.id),
                row(Icons.edit_calendar_outlined, 'Sezony', SeasonScreen.id),
              ],
            ),
          ),
          group([row(Icons.history, 'Historie úkonů', NotificationScreen.id)]),
          group([
            ListTile(
              leading: Icon(
                Icons.manage_accounts_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Účet a nastavení'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  ref.read(mainNotifierProvider.notifier).onUpperMenuTapped(),
            ),
          ]),
        ];
    }
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: items,
      ),
    );
  }
}
