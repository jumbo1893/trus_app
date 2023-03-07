import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/widgets/dropdown/season_dropdown.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final VoidCallback onPlusButtonPressed;
  final Function(MatchModel matchModel) setMatch;
  const MatchScreen({
    Key? key,
    required this.onPlusButtonPressed,
    required this.setMatch,
  }) : super(key: key);

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  SeasonModel? selectedValue;

  void setSelectedSeason(SeasonModel seasonModel) {
    setState(() {
      selectedValue = seasonModel;
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: size.width/2-padding, child: SeasonDropdown(onSeasonSelected: (seasonModel) => setSelectedSeason(seasonModel!), allSeasons: true, otherSeason: true,)),
                ],
              ),
              StreamBuilder<List<MatchModel>>(
                  stream: ref.watch(matchControllerProvider).matchesBySeason(selectedValue?.id ?? ""),
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
                              onTap: () => widget.setMatch(match),
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.grey,
                                ))),
                                child: ListTile(
                                  title: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: padding*2),
                                    child: Text(
                                      match.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  subtitle: Text(
                                    match.toStringForMatchList(),
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
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: widget.onPlusButtonPressed,
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
  }
}
