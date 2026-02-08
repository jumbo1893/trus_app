import 'package:flutter/material.dart';
import 'package:trus_app/models/api/interfaces/add_to_string.dart';

import '../../../features/main/widget/appbar/appbar_headline.dart';
import '../listview/listview_add_model_double.dart';

class AddListBuilderDouble extends StatelessWidget {
  final String? appBarText;
  final List<AddToString> items;

  final void Function(int index) onBeerAdd;
  final void Function(int index) onBeerRemove;
  final void Function(int index) onLiquorAdd;
  final void Function(int index) onLiquorRemove;

  const AddListBuilderDouble({
    super.key,
    this.appBarText,
    required this.items,
    required this.onBeerAdd,
    required this.onBeerRemove,
    required this.onLiquorAdd,
    required this.onLiquorRemove,
  });

  @override
  Widget build(BuildContext context) {
    const double paddingTop = 8.0;

    return Scaffold(
      appBar: appBarText != null
          ? AppBarHeadline(
        text: appBarText!,
      )
          : null,
      body: Padding(
        padding: const EdgeInsets.only(top: paddingTop),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final addToString = items[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey)),
                ),
                child: ListviewAddModelDouble(
                  padding: 16,
                  addToString: addToString,
                  onFirstNumberAdded: () => onBeerAdd(index),
                  onFirstNumberRemoved: () => onBeerRemove(index),
                  onSecondNumberAdded: () => onLiquorAdd(index),
                  onSecondNumberRemoved: () => onLiquorRemove(index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
