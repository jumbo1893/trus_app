import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/pkfl/controller/pkfl_controller.dart';
import 'package:trus_app/features/pkfl/pkfl_screens.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';

import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/rows/row_back_or_forward.dart';

class PkflMatchScreen extends ConsumerStatefulWidget {
  const PkflMatchScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PkflMatchScreen> createState() => _PkflMatchScreenState();
}

class _PkflMatchScreenState extends ConsumerState<PkflMatchScreen> {
  PkflScreens screen = PkflScreens.matchList;
  late PkflMatch pickedMatch;

  void changeScreens(PkflScreens screenFlow) {
    setState(() {
      screen = screenFlow;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pkflControllerProvider).snackBar().listen((event) {
      showSnackBarWithPostFrame(context: context, content: event);
    });
    const double padding = 8.0;
    switch (screen) {
      case PkflScreens.matchList:
        {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(padding),
              child: FutureBuilder<List<PkflMatch>>(
                  future: ref.read(pkflControllerProvider).getPkflMatches(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    }
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
                                  changeScreens(PkflScreens.matchDetail);
                                } else {
                                  changeScreens(
                                      PkflScreens.matchDetailWithoutResult);
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
      case PkflScreens.matchDetail:
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
                      changeScreens(PkflScreens.matchList);
                    },
                    onForwardChecked: () {
                      changeScreens(PkflScreens.mutualMatches);
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
                          future: ref
                              .read(pkflControllerProvider)
                              .getPkflMatchDetail(pickedMatch),
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
      case PkflScreens.matchDetailWithoutResult:
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
                      changeScreens(PkflScreens.matchList);
                    },
                    onForwardChecked: () {
                      changeScreens(PkflScreens.mutualMatches);
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
      case PkflScreens.mutualMatches:
        {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(children: [
                RowBackOrForward(
                  backText: "Zpět na seznam",
                  forwardText: "Zpět na detail",
                  onBackChecked: () {
                    changeScreens(PkflScreens.matchList);
                  },
                  onForwardChecked: () {
                    if (pickedMatch.detailEnabled()) {
                      changeScreens(PkflScreens.matchDetail);
                    } else {
                      changeScreens(PkflScreens.matchDetailWithoutResult);
                    }
                  },
                  padding: padding,
                  secondArrowForward: false,
                ),
                FutureBuilder<List<PkflMatch>>(
                    future: ref
                        .read(pkflControllerProvider)
                        .getMutualPkflMatches(pickedMatch),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      }
                      return Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var match = snapshot.data![index];
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {},
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
                                        match.toStringForMutualMatchesSubtitle(),
                                        style: const TextStyle(
                                            color: listviewSubtitleColor),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      );
                    }),
              ]),
            ),
          );
        }
    }
  }
}
