import 'package:flutter/material.dart';
import '../../../../common/utils/search_text.dart';
import '../../../../common/widgets/listview/listview_add_model.dart';
import '../../../../models/api/receivedfine/received_fine_api_model.dart';

int quickFineRank(String name) {
  final n = normalizeSearchText(name);
  if (n == 'prekop') return 0;
  if (n == 'treti polocas') return 1;
  if (n == 'pozdni prichod do zacatku') return 2;
  if (n.contains('pozdni prichod') &&
      n.contains('pred') &&
      (n.contains('utkani') || n.contains('zapas')))
    return 2;
  return 3;
}

class QuickFineList extends StatelessWidget {
  final List<ReceivedFineApiModel> items;
  final ValueChanged<int> onAdd, onRemove;
  const QuickFineList({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) {
    final preferred =
        [
          for (var i = 0; i < items.length; i++)
            if (!items[i].fine.inactive &&
                quickFineRank(items[i].fine.name) < 3)
              i,
        ]..sort(
          (a, b) => quickFineRank(
            items[a].fine.name,
          ).compareTo(quickFineRank(items[b].fine.name)),
        );
    final order = [
      ...preferred,
      for (var i = 0; i < items.length; i++)
        if (!preferred.contains(i)) i,
    ];
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: order.length,
      itemBuilder: (context, position) {
        final i = order[position];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (preferred.isNotEmpty &&
                  (position == 0 || position == preferred.length))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    position == 0 ? 'Časté pokuty' : 'Ostatní pokuty',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ListviewAddModel(
                addToString: items[i],
                onNumberAdded: () => onAdd(i),
                onNumberRemoved: () => onRemove(i),
                goal: true,
                enabled: !items[i].fine.inactive,
              ),
            ],
          ),
        );
      },
    );
  }
}
