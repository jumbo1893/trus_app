import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class MultiSelectBottomSheet<T extends ModelToString>
    extends ConsumerStatefulWidget {
  final String title;
  final List<T> models;
  final List<T> selectedModels;
  final ValueChanged<List<T>> onChanged;
  final bool Function(T model)? isInitiallyHidden;
  final String hiddenItemsButtonText;

  const MultiSelectBottomSheet({
    super.key,
    this.title = "Vyber položky",
    required this.models,
    required this.selectedModels,
    required this.onChanged,
    this.isInitiallyHidden,
    this.hiddenItemsButtonText = "Zobrazit skryté položky",
  });

  @override
  ConsumerState<MultiSelectBottomSheet<T>> createState() =>
      _MultiSelectBottomSheetState<T>();
}

class _MultiSelectBottomSheetState<T extends ModelToString>
    extends ConsumerState<MultiSelectBottomSheet<T>> {
  late List<T> _tempSelected;

  bool _showHiddenModels = false;

  @override
  void initState() {
    super.initState();
    _tempSelected = [...widget.selectedModels];
  }

  bool _isSelected(T item) {
    return _tempSelected.any((e) => e.getId() == item.getId());
  }

  bool _isHidden(T item) {
    return widget.isInitiallyHidden?.call(item) ?? false;
  }

  List<T> get _hiddenModels {
    return widget.models.where(_isHidden).toList();
  }

  List<T> get _visibleModels {
    return widget.models.where((item) {
      if (!_isHidden(item)) {
        return true;
      }

      // Již vybraný neaktivní hráč zůstane viditelný,
      // aby se při editaci starého zápasu "neztratil".
      if (_isSelected(item)) {
        return true;
      }

      return _showHiddenModels;
    }).toList();
  }

  void _toggleSelection(T item) {
    setState(() {
      if (_isSelected(item)) {
        _tempSelected.removeWhere((e) => e.getId() == item.getId());
      } else {
        _tempSelected.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hiddenModelsCount = _hiddenModels.length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.66,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(color: context.appColors.border, height: 1),

            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(top: 8),
                itemCount: _visibleModels.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.8,
                ),
                itemBuilder: (context, index) {
                  final item = _visibleModels[index];
                  final selected = _isSelected(item);

                  return InkWell(
                    onTap: () => _toggleSelection(item),
                    child: Row(
                      children: [
                        Checkbox(
                          value: selected,
                          onChanged: (_) => _toggleSelection(item),
                        ),
                        Expanded(
                          child: Text(
                            item.listViewTitle(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            if (hiddenModelsCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showHiddenModels = !_showHiddenModels;
                    });
                  },
                  icon: Icon(
                    _showHiddenModels
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                  label: Text(
                    _showHiddenModels
                        ? "Skrýt neaktivní hráče"
                        : "${widget.hiddenItemsButtonText} ($hiddenModelsCount)",
                  ),
                ),
              ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.all<Color>(context.appColors.legacyAccent),
                      shape:
                      WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: context.appColors.legacyAccent),
                        ),
                      ),
                    ),
                    onPressed: () {
                      widget.onChanged(_tempSelected);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Potvrdit",
                      style: TextStyle(color: context.appColors.buttonForeground),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}