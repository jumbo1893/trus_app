import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/football/warning_text.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';

import '../../../models/api/football/detail/football_match_detail.dart';
import '../enabled_icon_button.dart';

class FootballMatchBox extends StatelessWidget implements PreferredSizeWidget {
  const FootballMatchBox({
    super.key,
    required this.padding,
    required this.isNextMatch,
    required this.detail,
    required this.appTeamApiModel,

    // callbacks z notifieru:
    required this.onAddPlayers,
    required this.onAddGoals,
    required this.onAddBeer,
    required this.onAddFine,
    required this.onDetailMatch,
    required this.onCommonMatches,
  });

  final double padding;
  final bool isNextMatch;

  final FootballMatchDetail? detail;
  final AppTeamApiModel? appTeamApiModel;

  // notifier callbacky
  final void Function(FootballMatchApiModel match) onAddPlayers;
  final void Function(FootballMatchApiModel match) onAddGoals;
  final void Function(FootballMatchApiModel match) onAddBeer;
  final void Function(FootballMatchApiModel match) onAddFine;
  final void Function(FootballMatchApiModel match) onDetailMatch;
  final void Function(FootballMatchApiModel match) onCommonMatches;

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  String _getFootballMatchText(FootballMatchApiModel? match) {
    if (match == null) return "Zatím neznámý";
    return isNextMatch
        ? match.toStringForNextMatchHomeScreen()
        : match.toStringForLastMatchHomeScreen();
  }

  List<WarningText> _warnings(FootballMatchDetail? d, int matchId) {
    if (d == null) return [];

    final texts = <WarningText>[];

    if (matchId == -1) {
      texts.add(const WarningText(
        text: "Je potřeba doplnit hráče!",
        warningType: WarningType.error,
      ));
    }

    if (isNextMatch) {
      texts.add(WarningText(
        text:
        "Průměrný rok narození domácích: ${d.homeTeamAverageBirthYear} X hostů : ${d.awayTeamAverageBirthYear}",
        warningType: WarningType.info,
      ));

      if (d.homeTeamBestScorer != null && d.awayTeamBestScorer != null) {
        texts.add(WarningText(
          text:
          "Nejlepší střelec domácích: ${d.homeTeamBestScorer} X hostů : ${d.awayTeamBestScorer}",
          warningType: WarningType.info,
        ));
      }
    }

    return texts;
  }

  bool _isMatchButtonEnabled(FootballMatchApiModel? footballMatch, int matchId) {
    if (footballMatch == null) return false;
    if (matchId == -1) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width - padding * 2;
    const double insidePadding = 3.0;

    final match = detail?.footballMatch;

    final matchId = (detail == null)
        ? -1
        : (detail!.footballMatch
        .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(appTeamApiModel) ??
        -1);

    final footballBoxButtonWidth = width / 6 - insidePadding / 7;
    final warnings = _warnings(detail, matchId);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
          padding: const EdgeInsets.all(insidePadding),
          width: width,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black54),
              left: BorderSide(color: Colors.black54),
              right: BorderSide(color: Colors.black54),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    (match != null && match.isCurrentlyPlaying())
                        ? "Aktuálně hraný zápas"
                        : (isNextMatch ? "Příští zápas" : "Poslední zápas"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _getFootballMatchText(match),
                    textAlign: TextAlign.center,
                    key: const ValueKey('football_text'),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (detail != null)
          Container(
            margin: const EdgeInsets.only(left: 5.0, right: 5.0),
            width: width,
            decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
            child: Row(
              children: [
                SizedBox(
                  width: footballBoxButtonWidth,
                  child: EnabledIconButton(
                    onPressed: () => onAddPlayers(match!),
                    icon: const Icon(Icons.person_add),
                    enabled: true,
                    text: "Přidat hráče",
                  ),
                ),
                SizedBox(
                  width: footballBoxButtonWidth,
                  child: EnabledIconButton(
                    onPressed: () => onAddGoals(match!),
                    icon: const Icon(Icons.sports_soccer),
                    enabled: _isMatchButtonEnabled(match, matchId),
                    text: "Přidat góly",
                  ),
                ),
                SizedBox(
                  width: footballBoxButtonWidth,
                  child: EnabledIconButton(
                    onPressed: () => onAddBeer(match!),
                    icon: const Icon(Icons.sports_bar),
                    enabled: _isMatchButtonEnabled(match, matchId),
                    text: "Přidat piva",
                  ),
                ),
                SizedBox(
                  width: footballBoxButtonWidth,
                  child: EnabledIconButton(
                    onPressed: () => onAddFine(match!),
                    icon: const Icon(Icons.savings),
                    enabled: _isMatchButtonEnabled(match, matchId),
                    text: "Přidat pokuty",
                  ),
                ),
                SizedBox(
                  width: footballBoxButtonWidth,
                  child: EnabledIconButton(
                    onPressed: () => onDetailMatch(match!),
                    icon: const Icon(Icons.summarize),
                    enabled: true,
                    text: "Detail zápasu",
                  ),
                ),
                SizedBox(
                  width: footballBoxButtonWidth,
                  child: EnabledIconButton(
                    onPressed: () => onCommonMatches(match!),
                    icon: const Icon(Icons.compare),
                    enabled: true,
                    hasRightBorder: false,
                    text: "Vzájemné zápasy",
                  ),
                ),
              ],
            ),
          ),

        Container(
          margin: const EdgeInsets.only(left: 5.0, right: 5.0),
          width: width,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.black54),
              right: BorderSide(color: Colors.black54),
            ),
          ),
          child: Column(children: warnings),
        ),

        Container(
          margin: const EdgeInsets.only(left: 5.0, right: 5.0),
          width: width,
          decoration: warnings.isNotEmpty
              ? const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black54),
            ),
          )
              : null,
        ),
      ],
    );
  }
}