import 'package:flutter/material.dart';
import 'package:trus_app/models/api/interfaces/add_to_string.dart';

import '../listview/listview_add_model_double.dart';

class AddListBuilderDouble extends StatelessWidget {
  final List<AddToString> items;
  final ScrollController? scrollController;
  final bool compact;
  final String? Function(int)? changeLabel;

  final void Function(int index) onBeerAdd;
  final void Function(int index) onBeerRemove;
  final void Function(int index) onLiquorAdd;
  final void Function(int index) onLiquorRemove;

  const AddListBuilderDouble({
    super.key,
    this.scrollController,
    this.compact = false,
    this.changeLabel,
    required this.items,
    required this.onBeerAdd,
    required this.onBeerRemove,
    required this.onLiquorAdd,
    required this.onLiquorRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.only(bottom: compact ? 12 : 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: compact ? 6 : 10),
      itemBuilder: (context, index) {
        final addToString = items[index];

        return ListviewAddModelDouble(
          addToString: addToString,
          compact: compact,
          changeLabel: changeLabel?.call(index),
          onFirstNumberAdded: () => onBeerAdd(index),
          onFirstNumberRemoved: () => onBeerRemove(index),
          onSecondNumberAdded: () => onLiquorAdd(index),
          onSecondNumberRemoved: () => onLiquorRemove(index),
        );
      },
    );
  }
}
