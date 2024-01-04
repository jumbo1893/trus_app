import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../colors.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/main/screen_controller.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class ModelsErrorFutureBuilder<T> extends ConsumerWidget {
  final Future<List<ModelToString>> future;
  final Stream<List<ModelToString>>? rebuildStream;
  final Function(ModelToString model) onPressed;
  final BuildContext context;
  final bool? scrollable;

  const ModelsErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.onPressed,
    required this.context,
    this.rebuildStream,
    this.scrollable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<ModelToString>>(
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
        return StreamBuilder<List<ModelToString>>(
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
                physics: scrollable != null
                    ? (scrollable!
                        ? null
                        : const NeverScrollableScrollPhysics())
                    : null,
                itemCount: streamSnapshot.data?.length ?? snapshot.data!.length,
                itemBuilder: (context, index) {
                  var data =
                      streamSnapshot.data?[index] ?? snapshot.data![index];
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
                              key:
                                  ValueKey('list_tile_${data.listViewTitle()}'),
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  key:
                                      ValueKey('title_${data.listViewTitle()}'),
                                  data.listViewTitle(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              subtitle: Text(
                                key: ValueKey(
                                    data.listViewTitle().split(" - ").length < 2
                                        ? data.listViewTitle().split(" - ")[0]
                                        : data.listViewTitle().split(" - ")[1]),
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
            });
      },
    );
  }
}
