import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class MultiSelectBottomSheet<T extends ModelToString>
    extends ConsumerStatefulWidget {

  final String title;
  final List<T> models;
  final List<T> selectedModels;
  final ValueChanged<List<T>> onChanged;

  const MultiSelectBottomSheet({
    super.key,
    this.title = "Vyber položky",
    required this.models,
    required this.selectedModels,
    required this.onChanged,
  });

  @override
  ConsumerState<MultiSelectBottomSheet<T>> createState() =>
      _MultiSelectBottomSheetState<T>();
}


class _MultiSelectBottomSheetState<T extends ModelToString>
    extends ConsumerState<MultiSelectBottomSheet<T>> {

  late List<T> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = [...widget.selectedModels];
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.66,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(widget.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const Divider(color: Colors.black, height: 1),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                itemCount: widget.models.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.8,
                ),
                itemBuilder: (context, index) {
                  final item = widget.models[index];
                  final selected = _tempSelected
                      .any((e) => e.getId() == item.getId());

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selected
                            ? _tempSelected.removeWhere(
                                (e) => e.getId() == item.getId())
                            : _tempSelected.add(item);
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          value: selected,
                          onChanged: (_) {
                            setState(() {
                              selected
                                  ? _tempSelected.removeWhere(
                                      (e) => e.getId() == item.getId())
                                  : _tempSelected.add(item);
                            });
                          },
                        ),
                        Expanded(
                          child: Text(item.listViewTitle()),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              onPressed: () {
                widget.onChanged(_tempSelected);
                Navigator.pop(context);
              },
              child: const Text("Potvrdit", style: TextStyle(color: Colors.black)),

            )
          ],
        );
      },
    );
  }
}

