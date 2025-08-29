import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/football/warning_text.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/home/widget/i_football_match_box_callback.dart';
import 'package:trus_app/features/mixin/football_match_detail_controller_mixin.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';

import '../../../models/api/football/detail/football_match_detail.dart';
import '../enabled_icon_button.dart';

class FootballMatchBox extends StatefulWidget implements PreferredSizeWidget {
  const FootballMatchBox({
    super.key,
    required this.footballMatchBoxCallback,
    required this.footballMatchDetailControllerMixin,
    required this.padding,
    required this.isNextMatch,
    required this.hashKey,
    required this.appTeamApiModel,
  });

  final FootballMatchDetailControllerMixin footballMatchDetailControllerMixin;
  final double padding;
  final String hashKey;
  final bool isNextMatch;
  final IFootballMatchBoxCallback footballMatchBoxCallback;
  final AppTeamApiModel? appTeamApiModel;

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  State<FootballMatchBox> createState() => _FootballMatchBoxState();
}

class _FootballMatchBoxState extends State<FootballMatchBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  String getFootballMatchText(FootballMatchApiModel? match) {
    if (match == null) {
      return "Zatím neznámý";
    }
    if (widget.isNextMatch) {
      return match.toStringForNextMatchHomeScreen();
    }
    return match.toStringForLastMatchHomeScreen();
  }

  List<WarningText> returnWarnings(
      FootballMatchDetail? footballMatchDetail, int matchApiModelId) {
    List<WarningText> texts = [];
    if (footballMatchDetail == null) {
      return [];
    }
    if (matchApiModelId == -1) {
      texts.add(const WarningText(
        text: "Je potřeba doplnit hráče!",
        warningType: WarningType.error,
      ));
    }
    if (widget.isNextMatch) {
      texts.add(WarningText(
        text:
            "Průměrný rok narození domácích: ${footballMatchDetail.homeTeamAverageBirthYear} X hostů : ${footballMatchDetail.awayTeamAverageBirthYear}",
        warningType: WarningType.info,
      ));
      if (footballMatchDetail.homeTeamBestScorer != null &&
          footballMatchDetail.awayTeamBestScorer != null) {
        texts.add(WarningText(
          text:
              "Nejlepší střelec domácích: ${footballMatchDetail.homeTeamBestScorer} X hostů : ${footballMatchDetail.awayTeamBestScorer}",
          warningType: WarningType.info,
        ));
      }
    }
    return texts;
  }

  bool isMatchButtonEnabled(FootballMatchApiModel? footballMatch, matchId) {
    if (footballMatch == null) {
      return false;
    } else if (matchId == -1) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width - widget.padding * 2;
    const double insidePadding = 3.0;
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    return StreamBuilder<FootballMatchDetail?>(
        stream: widget.footballMatchDetailControllerMixin
            .footballMatchDetailValue(widget.hashKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          var footballMatchDetail = snapshot.data;
          int matchId;
          if (footballMatchDetail == null) {
            matchId = -1;
          } else {
            matchId = footballMatchDetail.footballMatch
                .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(
                    widget.appTeamApiModel);
          }
          double footballBoxButtonWidth = width / 6 - insidePadding / 7;
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
                      right: BorderSide(color: Colors.black54)),
                ),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                          footballMatchDetail?.footballMatch != null &&
                                  footballMatchDetail!.footballMatch
                                      .isCurrentlyPlaying()
                              ? "Aktuálně hraný zápas"
                              : (widget.isNextMatch
                                  ? "Příští zápas"
                                  : "Poslední zápas"),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                      Text(
                          getFootballMatchText(
                              footballMatchDetail?.footballMatch),
                          textAlign: TextAlign.center,
                          key: const ValueKey('football_text')),
                    ],
                  ),
                )),
              ),
              footballMatchDetail != null
                  ? Container(
                      margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: footballBoxButtonWidth,
                            child: EnabledIconButton(
                                onPressed: () => widget.footballMatchBoxCallback
                                    .onButtonAddPlayersClick(
                                        footballMatchDetail.footballMatch),
                                icon: const Icon(Icons.person_add),
                                enabled: true,
                                text: "Přidat hráče"),
                          ),
                          SizedBox(
                            width: footballBoxButtonWidth,
                            child: EnabledIconButton(
                                onPressed: () => widget.footballMatchBoxCallback
                                    .onButtonAddGoalsClick(
                                        footballMatchDetail.footballMatch),
                                icon: const Icon(Icons.sports_soccer),
                                enabled: isMatchButtonEnabled(
                                    footballMatchDetail.footballMatch, matchId),
                                text: "Přidat góly"),
                          ),
                          SizedBox(
                            width: footballBoxButtonWidth,
                            child: EnabledIconButton(
                                onPressed: () => widget.footballMatchBoxCallback
                                    .onButtonAddBeerClick(
                                        footballMatchDetail.footballMatch),
                                icon: const Icon(Icons.sports_bar),
                                enabled: isMatchButtonEnabled(
                                    footballMatchDetail.footballMatch, matchId),
                                text: "Přidat piva"),
                          ),
                          SizedBox(
                            width: footballBoxButtonWidth,
                            child: EnabledIconButton(
                                onPressed: () => widget.footballMatchBoxCallback
                                    .onButtonAddFineClick(
                                        footballMatchDetail.footballMatch),
                                icon: const Icon(Icons.savings),
                                enabled: isMatchButtonEnabled(
                                    footballMatchDetail.footballMatch, matchId),
                                text: "Přidat pokuty"),
                          ),
                          SizedBox(
                            width: footballBoxButtonWidth,
                            child: EnabledIconButton(
                                onPressed: () => widget.footballMatchBoxCallback
                                    .onButtonDetailMatchClick(
                                        footballMatchDetail.footballMatch),
                                icon: const Icon(Icons.summarize),
                                enabled: true,
                                text: "Detail zápasu"),
                          ),
                          SizedBox(
                            width: footballBoxButtonWidth,
                            child: EnabledIconButton(
                                onPressed: () => widget.footballMatchBoxCallback
                                    .onCommonMatchesClick(
                                        footballMatchDetail.footballMatch),
                                icon: const Icon(Icons.compare),
                                enabled: true,
                                hasRightBorder: false,
                                text: "Vzájemné zápasy"),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Container(
                margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                width: width,
                decoration: const BoxDecoration(
                  border: Border(
                      left: BorderSide(color: Colors.black54),
                      right: BorderSide(color: Colors.black54)),
                ),
                child: Column(
                    children: returnWarnings(footballMatchDetail, matchId)),
              ),
              Container(
                margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                width: width,
                decoration:
                    returnWarnings(footballMatchDetail, matchId).isNotEmpty
                        ? const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black54),
                            ),
                          )
                        : null,
              )
            ],
          );
        });
  }
}
