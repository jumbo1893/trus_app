import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'season_recap_data.dart';
import 'season_recap_sheet.dart';

class SeasonRecapDashboardCard extends ConsumerWidget {
  final void Function(int) onOpen;
  const SeasonRecapDashboardCard({super.key, required this.onOpen});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recaps = ref.watch(seasonRecapsProvider).asData?.value;
    // Older unread summaries stay in history, not a backlog of dashboard prompts.
    if (recaps == null || recaps.isEmpty || recaps.first.opened) {
      return const SizedBox.shrink();
    }
    final latest = recaps.first;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome),
        title: Text('Zobrazit souhrn za sezonu ${latest.seasonName}'),
        subtitle: const Text('Tvoje sezona v číslech a zážitcích'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onOpen(latest.id),
      ),
    );
  }
}

class SeasonRecapHistoryCard extends ConsumerWidget {
  const SeasonRecapHistoryCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recaps = ref.watch(seasonRecapsProvider);
    String date(String value) {
      final d = DateTime.parse(value);
      return '${d.day}. ${d.month}. ${d.year}';
    }

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.history),
        title: const Text('Sezonní souhrny'),
        children: recaps.when(
          loading: () => [
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ],
          error: (_, __) => [
            ListTile(
              title: const Text('Historii se nepodařilo načíst.'),
              trailing: TextButton(
                onPressed: () => ref.invalidate(seasonRecapsProvider),
                child: const Text('Znovu'),
              ),
            ),
          ],
          data: (items) => items.isEmpty
              ? [
                  const ListTile(
                    title: Text('Souhrn se objeví po skončení sezony.'),
                  ),
                ]
              : items
                    .map(
                      (r) => ListTile(
                        title: Text(r.seasonName),
                        subtitle: Text('${date(r.from)} – ${date(r.to)}'),
                        trailing: Icon(
                          r.opened ? Icons.chevron_right : Icons.fiber_new,
                        ),
                        onTap: () => showSeasonRecap(context, r.id),
                      ),
                    )
                    .toList(),
        ),
      ),
    );
  }
}
