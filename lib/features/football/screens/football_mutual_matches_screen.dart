import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/api/football/helper/mutual_matches.dart';

import '../../../colors.dart';
import '../../../models/api/football/football_match_api_model.dart';
import '../../match/controller/match_controller.dart';
import '../utils.dart';

class FootballMutualMatchesScreen extends ConsumerStatefulWidget {
  final Future<MutualMatches> getMutualMatches;

  const FootballMutualMatchesScreen({
    required this.getMutualMatches,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FootballMutualMatchesScreen> createState() =>
      _FootballMutualMatchesScreenState();
}

class _FootballMutualMatchesScreenState
    extends ConsumerState<FootballMutualMatchesScreen> {
  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
      return Scaffold(
        body: FutureBuilder<MutualMatches>(
            future: widget.getMutualMatches,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              List<FootballMatchApiModel> mutualMatches =
                  sortMatchesByDate(snapshot.data!.mutualMatches, true);
              String aggregateMatches = snapshot.data!.aggregateMatches ?? "";
              String aggregateScore = snapshot.data!.aggregateScore ?? "";
              return Column(
                children: [
                  InkWell(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
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
                              "Bilance zápasů V/R/P: $aggregateMatches",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          subtitle: Text(
                            "Celkové skóre: $aggregateScore",
                            style:
                                const TextStyle(color: listviewSubtitleColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: mutualMatches.length,
                      itemBuilder: (context, index) {
                        var match = mutualMatches[index];
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
                                    match.toStringForMutualMatchesSubtitle(ref.read(matchControllerProvider).isHomeMatch(match)),
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
}
