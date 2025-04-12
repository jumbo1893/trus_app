import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/player/widget/player_crud_widget.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../../models/enum/crud.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../controller/player_controller.dart';

class EditPlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "edit-player-screen";

  const EditPlayerScreen({
    Key? key,
  }) : super(key: key, title: "Upravit hráče", name: id);

  @override
  ConsumerState<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends ConsumerState<EditPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    PlayerApiModel player = ref.watch(screenControllerProvider).playerModel;
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(EditPlayerScreen.id)) {
      final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return FutureBuilder<void>(
          future:
              ref.watch(playerControllerProvider).setupEditPlayer(player.id!),
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
              loadModelFuture: ref.watch(playerControllerProvider).editPlayer(),
              loadingScreen: null,
              columns: [
                PlayerCrudWidget(
                    size: size,
                    iPlayerHashKey: ref.read(playerControllerProvider),
                    stringMixin: ref.watch(playerControllerProvider),
                    dateMixin: ref.watch(playerControllerProvider),
                    booleanMixin: ref.watch(playerControllerProvider),
                    dropdownMixin: ref.watch(playerControllerProvider)),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                CrudButton(
                  key: const ValueKey('confirm_button'),
                  text: "Potvrď změny",
                  context: context,
                  crud: Crud.update,
                  crudOperations: ref.read(playerControllerProvider),
                  onOperationComplete: (id) {
                    ref
                        .read(screenControllerProvider)
                        .changeFragment(PlayerScreen.id);
                  },
                  id: player.id!,
                ),
                CrudButton(
                  key: const ValueKey('delete_button'),
                  text: "Smaž hráče",
                  context: context,
                  crud: Crud.delete,
                  crudOperations: ref.read(playerControllerProvider),
                  onOperationComplete: (id) {
                    ref
                        .read(screenControllerProvider)
                        .changeFragment(PlayerScreen.id);
                  },
                  id: player.id!,
                  modelToString: player,
                ),
              ],
            );
          });
    } else {
      return Container();
    }
  }
}
