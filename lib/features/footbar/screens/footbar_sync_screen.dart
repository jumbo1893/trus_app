import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/footbar/controller/footbar_sync_controller.dart';

import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/rows/view/row_text_view_stream.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';

class FootbarSyncScreen extends CustomConsumerWidget {
  static const String id = "footbar-sync-screen";


  const FootbarSyncScreen({
    Key? key,
  }) : super(key: key, title: "Sync Footbar aktivit", name: id);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(footbarSyncControllerProvider);
    if (ref.read(screenControllerProvider).isScreenFocused(FootbarSyncScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return Scaffold(
        body: FutureBuilder(
            future:
            controller.setupLastSync(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                        () => showErrorDialog(snapshot, () {
                      ref
                          .read(screenControllerProvider)
                          .changeFragment(HomeScreen.id);
                    }, context));
                return const Loader();
              }
              return ColumnFutureBuilder(
                loadModelFuture: controller.viewLastUpdate(),
                columns: [
                  RowTextViewStream(
                    key: const ValueKey('footbar_sync_date_text'),
                    size: size,
                    textFieldText: "Poslední aktualizace",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.lastUpdateKey,
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  CustomButton(
                      text: "Aktualizovat statistiky týmu",
                      onPressed: () async => await controller.syncAppTeamActivities().whenComplete(() async => await controller.viewLastUpdate()) )
                ],
                loadingScreen: null,
              );
            }),
      );
    } else {
      return Container();
    }
  }
}
