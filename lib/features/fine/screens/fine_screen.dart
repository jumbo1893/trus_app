import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/fine_model.dart';

import '../controller/fine_controller.dart';

class FineScreen extends ConsumerWidget {
  final VoidCallback onPlusButtonPressed;
  final Function(FineModel fineModel) setFine;
  const FineScreen({
    Key? key,
    required this.onPlusButtonPressed,
    required this.setFine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<List<FineModel>>(
              stream: ref.watch(fineControllerProvider).fines(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var fine = snapshot.data![index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setFine(fine),
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
                                    fine.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                subtitle: Text(
                                  fine.toStringForFineList(),
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
