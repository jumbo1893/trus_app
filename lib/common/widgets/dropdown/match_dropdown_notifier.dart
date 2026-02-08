import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

class MatchDropdownNotifier extends StatelessWidget {
  final List<MatchApiModel> matches;
  final MatchApiModel? selected;
  final ValueChanged<MatchApiModel> onSelected;

  const MatchDropdownNotifier({
    super.key,
    required this.matches,
    required this.selected,
    required this.onSelected,
  });

  List<DropdownMenuItem<MatchApiModel>> _items(List<MatchApiModel> items) {
    return items.map((item) {
      final divider = item != items.last
          ? const Divider(height: 1)
          : const Divider(height: 1, color: Colors.white);

      return DropdownMenuItem<MatchApiModel>(
        value: item,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                item.listViewTitle(),
                maxLines: 2,
                minFontSize: 12,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              divider,
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return DropdownButtonHideUnderline(
      child: DropdownButton2<MatchApiModel>(
        isExpanded: true,
        value: selected ?? matches.first,
        items: _items(matches),
        selectedItemBuilder: (_) {
          return matches
              .map(
                (e) => Container(
              key: ValueKey("match_item_${e.name}"),
              alignment: Alignment.center,
              child: AutoSizeText(
                e.listViewTitle(),
                maxLines: 2,
                minFontSize: 12,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
              .toList();
        },
        onChanged: (value) {
          if (value != null) onSelected(value);
        },
      ),
    );
  }
}
