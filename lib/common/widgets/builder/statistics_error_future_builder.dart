import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/helper/list_models.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../colors.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/main/screen_controller.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class StatisticsErrorFutureBuilder<T> extends ConsumerWidget {
  final Future<ListModels> future;
  final Stream<ListModels> rebuildStream;
  final Stream<String>? overallStream;
  final Function(ModelToString model) onPressed;
  final BuildContext context;
  final VoidCallback? overAllStatsInit;
  final bool includeOverAllStream;

  const StatisticsErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.onPressed,
    required this.context,
    required this.overallStream,
    required this.rebuildStream,
    required this.overAllStatsInit,
    required this.includeOverAllStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<ListModels>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          Future.delayed(
              Duration.zero,
              () => showErrorDialog(
                  snapshot,
                  () => ref
                      .read(screenControllerProvider)
                      .changeFragment(HomeScreen.id),
                  context));
          return const Loader();
        }
        return StreamBuilder<ListModels>(
            stream: rebuildStream,

            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(
                        streamSnapshot,
                        () => ref
                            .read(screenControllerProvider)
                            .changeFragment(HomeScreen.id),
                        context));
                return const Loader();
              }
              return Column(
                children: [
                  Builder(
                    builder: (context) {
                      return includeOverAllStream ? StreamBuilder<String>(
                          stream: overallStream,
                          builder: (context, overallSnapshot) {
                            if (overallSnapshot.hasError) {
                              Future.delayed(
                                  Duration.zero,
                                  () => showErrorDialog(
                                      overallSnapshot,
                                      () => ref
                                          .read(screenControllerProvider)
                                          .changeFragment(HomeScreen.id),
                                      context));
                              return const Loader();
                            } else if (overallSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              overAllStatsInit!();
                              return const Loader();
                            }
                            return InkWell(
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
                                    title: const Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Text(
                                        "Celkem:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                    subtitle: Text(
                                      overallSnapshot.data!,
                                      style: const TextStyle(
                                          color: listviewSubtitleColor),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }) : Container();
                    }
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: null,
                      itemCount:
                          streamSnapshot.data?.modelList.length ?? snapshot.data!.modelList.length,
                      itemBuilder: (context, index) {
                        var data =
                            streamSnapshot.data?.modelList[index] ?? snapshot.data!.modelList[index];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => onPressed(data),
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
                                      data.toStringForListView(),
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
                    ),
                  ),
                ],
              );
            });
      },
    );
  }
}
