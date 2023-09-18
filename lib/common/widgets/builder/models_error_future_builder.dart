import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/error.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../colors.dart';
import '../../../features/general/error/api_executor.dart';
import '../dialog/error_dialog.dart';
import '../loader.dart';

class ModelsErrorFutureBuilder<T> extends StatelessWidget {
  final Future<List<ModelToString>> future;
  final Stream<List<ModelToString>>? rebuildStream;
  final Function(ModelToString model) onPressed;
  final BuildContext context;
  final VoidCallback onDialogCancel;
  const ModelsErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.onPressed,
    required this.context,
    required this.onDialogCancel,
    this.rebuildStream,
  }) : super(key: key);

  void showErrorDialog(String snapshotError) {
    var dialog = ErrorDialog("Chyba!", snapshotError, () => onDialogCancel());
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModelToString>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        else if (snapshot.hasError) {
          Future.delayed(Duration.zero, () => showErrorDialog(snapshot.error!.toString()));
          return const Loader();
        }
        return StreamBuilder<List<ModelToString>>(
          stream: rebuildStream,
          builder: (context, streamSnapshot) {
            if (streamSnapshot.hasError) {
              Future.delayed(Duration.zero, () => showErrorDialog(streamSnapshot.error!.toString()));
              return const Loader();
            }
            return ListView.builder(
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
            );
          }
        );
      },
    );
  }
}