import 'package:flutter/material.dart';
import 'package:trus_app/models/api/interfaces/add_to_string.dart';

import '../../../features/main/widget/appbar/appbar_headline.dart';
import '../listview/listview_add_model.dart';
import '../listview/listview_add_model_double.dart';

class AddListBuilder extends StatelessWidget {
  final List<AddToString> items;

  final bool goal;

  final bool doubleListview;

  final String? appBarText;
  final VoidCallback? onBackButtonPressed;

  final void Function(int index) onAdd;
  final void Function(int index) onRemove;

  /// pro double list view
  final void Function(int index)? onFirstAdd;
  final void Function(int index)? onFirstRemove;
  final void Function(int index)? onSecondAdd;
  final void Function(int index)? onSecondRemove;

  const AddListBuilder({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.goal,
    this.doubleListview = false,
    this.appBarText,
    this.onBackButtonPressed,
    this.onFirstAdd,
    this.onFirstRemove,
    this.onSecondAdd,
    this.onSecondRemove,
  });

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;

    return Scaffold(
      appBar: appBarText != null
          ? AppBarHeadline(
        text: appBarText!,
      )
          : null,
      body: Padding(
        padding: const EdgeInsets.only(top: padding),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final addToString = items[index];

            return InkWell(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                  left: 8,
                  right: 8,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: (!doubleListview)
                      ? ListviewAddModel(
                    padding: 16,
                    addToString: addToString,
                    onNumberAdded: () => onAdd(index),
                    onNumberRemoved: () => onRemove(index),
                    goal: goal,
                  )
                      : ListviewAddModelDouble(
                    padding: 16,
                    addToString: addToString,
                    onFirstNumberAdded: () => onFirstAdd?.call(index),
                    onFirstNumberRemoved: () => onFirstRemove?.call(index),
                    onSecondNumberAdded: () => onSecondAdd?.call(index),
                    onSecondNumberRemoved: () => onSecondRemove?.call(index),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
