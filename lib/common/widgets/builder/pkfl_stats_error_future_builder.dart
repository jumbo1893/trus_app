import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';

import '../../../colors.dart';
import '../../../features/main/screen_controller.dart';
import '../../../models/helper/pkfl_all_individual_stats_with_spinner.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class PkflStatsErrorFutureBuilder<T> extends ConsumerWidget {
  final Future<PkflAllIndividualStatsWithSpinner> future;
  final Stream<PkflAllIndividualStatsWithSpinner> rebuildStream;
  final BuildContext context;

  const PkflStatsErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.context,
    required this.rebuildStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<PkflAllIndividualStatsWithSpinner>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          Future.delayed(
              Duration.zero,
              () => showErrorDialog(
                  snapshot.error!.toString(),
                  () => ref
                      .read(screenControllerProvider)
                      .changeFragment(HomeScreen.id),
                  context));
          return const Loader();
        }
        return StreamBuilder<PkflAllIndividualStatsWithSpinner>(
            stream: rebuildStream,
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(
                        streamSnapshot.error!.toString(),
                        () => ref
                            .read(screenControllerProvider)
                            .changeFragment(HomeScreen.id),
                        context));
                return const Loader();
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: streamSnapshot.data?.pkflAllIndividualStats.length ??
                    snapshot.data!.pkflAllIndividualStats.length,
                itemBuilder: (context, index) {
                  var data =
                      streamSnapshot.data?.pkflAllIndividualStats[index] ??
                          snapshot.data!.pkflAllIndividualStats[index];
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
                                  data.listViewTitle(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              subtitle: Text(
                                data.toStringForListView(
                                    streamSnapshot.data?.option ??
                                        snapshot.data!.option),
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
            });
      },
    );
  }
}
