import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/footbar/controller/footbar_sync_notifier.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/rows/row_text_view_field.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';

class FootbarSyncScreen extends CustomConsumerWidget {
  static const String id = "footbar-sync-screen";


  const FootbarSyncScreen({
    Key? key,
  }) : super(key: key, title: "Sync Footbar aktivit", name: id);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(footbarSyncNotifierProvider);
    final notifier = ref.read(footbarSyncNotifierProvider.notifier);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            RowTextViewField(
              textFieldText: "Poslední aktualizace",
              value: state.lastSync,),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            SimpleCrudButton(
              onPressed: () async => notifier.syncAppTeamActivities(),
              text: "Aktualizovat statistiky týmu",
            ),
          ],
        ),
      ),
    );
  }
}
