import 'package:flutter/material.dart';
import 'package:trus_app/models/api/interfaces/add_to_string.dart';

import '../listview/listview_add_model.dart';
import '../listview/listview_add_model_double.dart';

class AddListBuilder extends StatelessWidget {
  final List<AddToString> items;
  final bool goal;
  final bool doubleListview;

  final void Function(int index) onAdd;
  final void Function(int index) onRemove;

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
    this.onFirstAdd,
    this.onFirstRemove,
    this.onSecondAdd,
    this.onSecondRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final addToString = items[index];

        return !doubleListview
            ? ListviewAddModel(
          addToString: addToString,
          onNumberAdded: () => onAdd(index),
          onNumberRemoved: () => onRemove(index),
          goal: goal,
        )
            : ListviewAddModelDouble(
          addToString: addToString,
          onFirstNumberAdded: () => onFirstAdd?.call(index),
          onFirstNumberRemoved: () => onFirstRemove?.call(index),
          onSecondNumberAdded: () => onSecondAdd?.call(index),
          onSecondNumberRemoved: () => onSecondRemove?.call(index),
        );
      },
    );
  }
}