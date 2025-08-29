import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../colors.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/main/screen_controller.dart';
import '../../../features/mixin/model_to_string_list_controller_mixin.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class ModelsCacheBuilder<T> extends ConsumerWidget {
  final Future<void> listSetup;
  final ModelToStringListControllerMixin modelToStringListControllerMixin;
  final Function(ModelToString model) onPressed;
  final String hashKey;
  final bool? scrollable;

  const ModelsCacheBuilder({
    Key? key,
    required this.listSetup,
    required this.onPressed,
    required this.hashKey,
    required this.modelToStringListControllerMixin,
    this.scrollable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<void>(
      future: listSetup,
      builder: (context, snapshot) {
         if (snapshot.hasError) {
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
        /*return FutureBuilder<void>(
          future: setupView,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("mám error");
              Future.delayed(
                  Duration.zero,
                      () => showErrorDialog(
                      snapshot,
                          () => ref
                          .read(screenControllerProvider)
                          .changeFragment(HomeScreen.id),
                      context));
              return const Loader();
            }*/
            return StreamBuilder<List<ModelToString>>(
              stream: modelToStringListControllerMixin.modelToStringListValue(hashKey),
              builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting || !streamSnapshot.hasData) {
                  return const Loader();
                }

                final modelToStringList = streamSnapshot.data ?? [];

                return ListView.builder(
                  shrinkWrap: true,
                  physics: scrollable != null
                      ? (scrollable! ? null : const NeverScrollableScrollPhysics())
                      : null,
                  itemCount: modelToStringList.length,
                  itemBuilder: (context, index) {
                    final data = modelToStringList[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => onPressed(data),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: ListTile(
                                key: ValueKey('list_tile_${data.listViewTitle()}'),
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    key: ValueKey('title_${data.listViewTitle()}'),
                                    data.listViewTitle(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  key: ValueKey(
                                    data.listViewTitle().split(" - ").length < 2
                                        ? data.listViewTitle().split(" - ")[0]
                                        : data.listViewTitle().split(" - ")[1],
                                  ),
                                  data.toStringForListView(),
                                  style: const TextStyle(color: listviewSubtitleColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        //);
      //},
    );
  }
}
