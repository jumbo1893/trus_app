import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_detail.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';

import '../../../colors.dart';
import '../../../common/widgets/custom_text.dart';
import '../../match/controller/match_controller.dart';
import '../utils.dart';

class PkflCommonMatchesScreen extends ConsumerStatefulWidget {
  final bool isFocused;
  final VoidCallback backToMainMenu;

  const PkflCommonMatchesScreen({
    required this.isFocused,
    required this.backToMainMenu,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PkflCommonMatchesScreen> createState() =>
      _PkflCommonMatchesScreenState();
}

class _PkflCommonMatchesScreenState extends ConsumerState<PkflCommonMatchesScreen> {

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    if (widget.isFocused) {
      return Scaffold(
        body: FutureBuilder<PkflMatchDetail>(
            future: ref
                .read(matchControllerProvider)
                .returnPkflMatchDetail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              List<PkflMatchApiModel> commonMatches = sortMatchesByDate(snapshot.data!.commonMatches, true);
              String aggregateMatches = snapshot.data!.aggregateMatches?? "";
              String aggregateScore = snapshot.data!.aggregateScore?? "";
              return Column(
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0, left: 8, right: 8),
                      child: Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                ))),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              "Vzájemné zápasy V/R/P: $aggregateMatches",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                          subtitle: Text(
                            "Celkové skóre: $aggregateScore",
                            style: const TextStyle(
                                color: listviewSubtitleColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: commonMatches.length,
                      itemBuilder: (context, index) {
                        var match = commonMatches[index];
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
                  ),
                ],
              );
            }),
      );
    }
    else {
      return Container();
    }
  }
}
