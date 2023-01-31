import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';

import '../../../models/season_model.dart';
import '../controller/season_controller.dart';

class SeasonScreen extends ConsumerWidget {
  final VoidCallback onPlusButtonPressed;
  final Function(SeasonModel seasonModel) setSeason;
  const SeasonScreen({
    Key? key,
    required this.onPlusButtonPressed,
    required this.setSeason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<List<SeasonModel>>(
              stream: ref.watch(seasonControllerProvider).seasons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var season = snapshot.data![index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setSeason(season),
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
                                    season.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                subtitle: Text(
                                  season.toStringForSeasonList(),
                                  style: const TextStyle(
                                      color: listviewSubtitleColor),
                                ),
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
        floatingActionButton: FloatingActionButton(
          onPressed: onPlusButtonPressed,
          elevation: 4.0,
          child: const Icon(Icons.add),
        ));
  }
}
