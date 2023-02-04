import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/features/pkfl/controller/pkfl_controller.dart';
import 'package:trus_app/features/pkfl/exception/bad_format_exception.dart';
import 'package:trus_app/features/pkfl/screenflow.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_match_detail_task.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_matches_task.dart';
import 'package:trus_app/features/pkfl/utils.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import 'package:trus_app/models/pkfl/pkfl_match_detail.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/dropdown/season_dropdown.dart';
import '../../../common/widgets/rows/row_back_or_forward.dart';

class PkflMatchScreen extends ConsumerStatefulWidget {
  const PkflMatchScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PkflMatchScreen> createState() => _PkflMatchScreenState();
}

class _PkflMatchScreenState extends ConsumerState<PkflMatchScreen> {
  ScreenFlow screenFlow = ScreenFlow.matchList;
  late PkflMatch pickedMatch;

  void changeScreens(ScreenFlow screenFlow) {
    setState(() {
      this.screenFlow = screenFlow;
    });
  }

  /*Future<List<PkflMatch>> getPkflMatches() async {
    String url = "";
    List<PkflMatch> matches = [];
    await ref.read(pkflControllerProvider).url().then((value) => url = value);
    RetrieveMatchesTask matchesTask = RetrieveMatchesTask(url);
    try {
      await matchesTask.returnPkflMatches().then((value) => matches = value);
    } catch (e, stacktrace) {
      print(stacktrace);
      showSnackBar(context: context, content: e.toString());
    }
    return matches;
  }*/

  Future<PkflMatch> getPkflMatchDetail() async {
    RetrieveMatchDetailTask matchTask =
        RetrieveMatchDetailTask(pickedMatch.urlResult);
    try {
      await matchTask.returnPkflMatchDetail().then(
        (value) {
          pickedMatch.pkflMatchDetail = value;
        },
      );
    } catch (e, stacktrace) {
      print(stacktrace);
      showSnackBar(context: context, content: e.toString());
    }
    return pickedMatch;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pkflControllerProvider).snackBar().listen((event) {
      showSnackBar(context: context, content: event);
    });
    const double padding = 8.0;
    switch (screenFlow) {
      case ScreenFlow.matchList:
        {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(padding),
              child: FutureBuilder<List<PkflMatch>>(
                  future: ref.read(pkflControllerProvider).getPkflMatches(),
                  builder: (context, snapshot) {
                    print(snapshot.connectionState);
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    }
                    sortMatchesByDate(snapshot.data!, false);
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var match = snapshot.data![index];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                pickedMatch = match;
                                if (pickedMatch.detailEnabled()) {
                                  changeScreens(ScreenFlow.matchDetail);
                                } else {
                                  changeScreens(
                                      ScreenFlow.matchDetailWithoutResult);
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.grey,
                                ))),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: padding * 2),
                                    child: Text(
                                      match.toStringNameWithOpponent(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  subtitle: Text(
                                    match.toStringForSubtitle(),
                                    style: const TextStyle(
                                        color: listviewSubtitleColor),
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  }),
            ),
          );
        }
      case ScreenFlow.matchDetail:
        {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(
                children: [
                  RowBackOrForward(
                    backText: "Zpět na seznam",
                    forwardText: "Vzájemné zápasy",
                    onBackChecked: () {
                      changeScreens(ScreenFlow.matchList);
                    },
                    onForwardChecked: () {
                      changeScreens(ScreenFlow.mutualMatches);
                    },
                    padding: padding,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(pickedMatch.toStringNameWithOpponent(),
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    children: [
                      CustomText(text: pickedMatch.returnFirstDetailsOfMatch()),
                      FutureBuilder<PkflMatch>(
                          future: getPkflMatchDetail(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Loader();
                            }
                            return Column(
                              children: [
                                CustomText(
                                    text: pickedMatch
                                        .returnSecondDetailsOfMatch()),
                              ],
                            );
                          })
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      case ScreenFlow.matchDetailWithoutResult:
        {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(
                children: [
                  RowBackOrForward(
                    backText: "Zpět na seznam",
                    forwardText: "Vzájemné zápasy",
                    onBackChecked: () {
                      changeScreens(ScreenFlow.matchList);
                    },
                    onForwardChecked: () {
                      changeScreens(ScreenFlow.mutualMatches);
                    },
                    padding: padding,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(pickedMatch.toStringNameWithOpponent(),
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    children: [
                      CustomText(text: pickedMatch.returnFirstDetailsOfMatch())
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      case ScreenFlow.mutualMatches:
        {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(
                children: [
                  RowBackOrForward(
                    backText: "Zpět na seznam",
                    forwardText: "Zpět na detail",
                    onBackChecked: () {
                      changeScreens(ScreenFlow.matchList);
                    },
                    onForwardChecked: () {
                      if (pickedMatch.detailEnabled()) {
                        changeScreens(ScreenFlow.matchDetail);
                      } else {
                        changeScreens(ScreenFlow.matchDetailWithoutResult);
                      }
                    },
                    padding: padding,
                    secondArrowForward: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(pickedMatch.toStringNameWithOpponent(),
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    children: [
                      CustomText(text: pickedMatch.returnFirstDetailsOfMatch())
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    }
  }
}
