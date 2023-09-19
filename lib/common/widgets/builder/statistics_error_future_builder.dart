import 'package:flutter/material.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../colors.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class StatisticsErrorFutureBuilder<T> extends StatelessWidget {
  final Future<List<ModelToString>> future;
  final Stream<List<ModelToString>> rebuildStream;
  final Stream<String> overallStream;
  final Function(ModelToString model) onPressed;
  final BuildContext context;
  final VoidCallback backToMainMenu;
  final VoidCallback overAllStatsInit;
  const StatisticsErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.onPressed,
    required this.context,
    required this.backToMainMenu,
    required this.overallStream,
    required this.rebuildStream,
    required this.overAllStatsInit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModelToString>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        else if (snapshot.hasError) {
          Future.delayed(Duration.zero, () => showErrorDialog(snapshot.error!.toString(), () => backToMainMenu(), context));
          return const Loader();
        }
        return StreamBuilder<List<ModelToString>>(
          stream: rebuildStream,
          builder: (context, streamSnapshot) {
            if (streamSnapshot.hasError) {
              Future.delayed(Duration.zero, () =>
                  showErrorDialog(streamSnapshot.error!.toString(), () => backToMainMenu(), context));
              return const Loader();
            }
            return Column(
              children: [
                StreamBuilder<String>(
                  stream: overallStream,
                  builder: (context, overallSnapshot) {
                    if (overallSnapshot.hasError) {
                      Future.delayed(Duration.zero, () =>
                          showErrorDialog(overallSnapshot.error!.toString(), () => backToMainMenu(), context));
                      return const Loader();
                    }
                    else if (overallSnapshot.connectionState == ConnectionState.waiting) {
                      overAllStatsInit();
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
                  }
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: streamSnapshot.data?.length ?? snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var data = streamSnapshot.data?[index] ?? snapshot.data![index];
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
              ],
            );
          }
        );
      },
    );
  }
}