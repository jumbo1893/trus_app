import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../controller/player_controller.dart';
import '../widget/player_crud_widget.dart';

class AddPlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-player-screen";

  const AddPlayerScreen({
    Key? key,
  }) : super(key: key, title: "Přidat hráče", name: id);

  @override
  ConsumerState<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends ConsumerState<AddPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(AddPlayerScreen.id)) {
      final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return FutureBuilder<void>(
          future: ref.watch(playerControllerProvider).setupNewPlayer(),
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
              loadModelFuture: ref.watch(playerControllerProvider).newPlayer(),
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
                CrudButton(
                  key: const ValueKey('confirm_button'),
                  text: "Potvrď",
                  context: context,
                  crud: Crud.create,
                  crudOperations: ref.read(playerControllerProvider),
                  onOperationComplete: (id) {
                    ref
                        .read(screenControllerProvider)
                        .changeFragment(PlayerScreen.id);
                  },
                )
              ],
            );
          });
    } else {
      return Container();
    }
  }
}
