import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/row_text_view_field_with_icon.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../bottomsheet/multi_select_bottom_sheet.dart';


class RowMultiSelect<T extends ModelToString> extends ConsumerStatefulWidget {
  final String label;
  final List<T> models;
  final List<T> selectedModels;
  final ValueChanged<List<T>> onChanged;
  final bool openBottomSheet;

  const RowMultiSelect({
    super.key,
    required this.label,
    required this.models,
    required this.selectedModels,
    required this.onChanged,
    this.openBottomSheet = false,
  });

  @override
  ConsumerState<RowMultiSelect<T>> createState() => _RowMultiSelectState<T>();
}

class _RowMultiSelectState<T extends ModelToString>
    extends ConsumerState<RowMultiSelect<T>> {
  bool _autoOpened = false;
  bool _opening = false;

  @override
  Widget build(BuildContext context) {
    final value = widget.selectedModels
        .map((e) => e.listViewTitle())
        .join(", ");

    if (widget.openBottomSheet && !_autoOpened && !_opening && widget.models.isNotEmpty) {
      _autoOpened = true;
      _opening = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await _openBottomSheet(
          context,
          widget.models,
          widget.selectedModels,
          widget.onChanged,
          widget.label,
        );

        if (!mounted) return;
        _opening = false;
      });
    }

    return InkWell(
      child: RowTextViewFieldWithIcon(
        textFieldText: widget.label,
        value: value,
        showIfEmptyText: true,
        allowWrap: false,
        onCalendarIconPressed: () => _openBottomSheet(
          context,
          widget.models,
          widget.selectedModels,
          widget.onChanged,
          widget.label,
        ),
        icon: Icons.add,
      ),
    );
  }

  Future<void> _openBottomSheet(
      BuildContext context,
      List<T> models,
      List<T> selectedModels,
      ValueChanged<List<T>> onChanged,
      String title,
      ) {
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
}