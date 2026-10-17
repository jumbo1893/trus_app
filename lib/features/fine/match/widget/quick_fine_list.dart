import 'package:flutter/material.dart';
import '../../../../models/api/receivedfine/received_fine_api_model.dart';

const fineCategoryOrder = ['FREQUENT', 'COMMON', 'RARE', 'AUTOMATIC'];
const fineCategoryTitles = {
  'FREQUENT': 'Časté pokuty',
  'COMMON': 'Běžné pokuty',
  'RARE': 'Méně časté pokuty',
  'AUTOMATIC': 'Automaticky udělované pokuty',
};

class QuickFineList extends StatelessWidget {
  final List<ReceivedFineApiModel> items;
  final ValueChanged<int> onAdd, onRemove;
  final bool correcting;
  final bool multiple;
  const QuickFineList({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    this.correcting = false,
    this.multiple = false,
  });
  @override
  Widget build(BuildContext context) {
    final order = [
      for (final category in fineCategoryOrder)
        for (var i = 0; i < items.length; i++)
          if (!items[i].fine.inactive &&
              (fineCategoryTitles.containsKey(items[i].fine.category)
                      ? items[i].fine.category
                      : 'COMMON') == category) i,
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
              if (position == 0 ||
                  items[order[position - 1]].fine.category != items[i].fine.category)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    fineCategoryTitles[items[i].fine.category] ?? 'Běžné pokuty',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              Card(
                child: ListTile(
                  title: Text(items[i].toStringForListView()),
                  subtitle: Text(multiple
                      ? 'Zapsáno vybraným hráčům: ${items[i].fineNumber >= 0 ? '+' : ''}${items[i].fineNumber}'
                      : 'Počet: ${items[i].fineNumber}'),
                  trailing: Icon(correcting ? Icons.remove : Icons.add),
                  onTap: items[i].fine.inactive
                      ? null
                      : () => correcting ? onRemove(i) : onAdd(i),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
