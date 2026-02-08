import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/row_text_view_field_with_icon.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../bottomsheet/multi_select_bottom_sheet.dart';


class RowMultiSelect<T extends ModelToString> extends ConsumerWidget {
  final String label;
  final List<T> models;
  final List<T> selectedModels;
  final ValueChanged<List<T>> onChanged;

  const RowMultiSelect({
    super.key,
    required this.label,
    required this.models,
    required this.selectedModels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = selectedModels
        .map((e) => e.listViewTitle())
        .join(", ");

    return InkWell(
      child: RowTextViewFieldWithIcon(
        textFieldText: label,
        value: value,
        showIfEmptyText: true,
        allowWrap: false, onCalendarIconPressed: () =>
          _openBottomSheet(context, models, selectedModels, onChanged, label), icon: Icons.add,
      ),
    );
  }

  void _openBottomSheet(
      BuildContext context,
      List<T> models,
      List<T> selectedModels,
      ValueChanged<List<T>> onChanged,
      String title
      ) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => MultiSelectBottomSheet<T>(
        models: models,
        selectedModels: selectedModels,
        onChanged: onChanged,
        title: title,
      ),
    );
  }
}
