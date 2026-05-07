import 'package:flutter/material.dart';

import '../../../models/api/interfaces/model_to_string.dart';
import '../bottomsheet/multi_select_bottom_sheet.dart';
import '../rows/form/fake_input.dart';

class AppMultiSelectField<T extends ModelToString> extends StatelessWidget {
  final String label;
  final String title;
  final List<T> models;
  final List<T> selectedModels;
  final ValueChanged<List<T>> onChanged;

  const AppMultiSelectField({
    super.key,
    required this.label,
    required this.title,
    required this.models,
    required this.selectedModels,
    required this.onChanged,
  });

  Future<void> _openBottomSheet(BuildContext context) {
    return showModalBottomSheet(
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

  String getPreviewText(List<T> models) {
    if (models.isEmpty) return "Vyber...";
    if (models.length <= 3) {
      return models.map((e) => e.listViewTitle()).join(", ");
    }
    return "${models.length} vybraných";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openBottomSheet(context),
      child: FakeInput(
        text: getPreviewText(selectedModels),
        icon: Icons.add,
      ),
    );
  }
}