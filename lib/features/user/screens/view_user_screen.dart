import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/user/controller/user_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/rows/view/row_text_view_stream.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
class ViewUserScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-user-screen";

  const ViewUserScreen({
    Key? key,
  }) : super(key: key, title: "Nastavení uživatele", name: id);

  @override
  ConsumerState<ViewUserScreen> createState() => _ViewUserScreenState();
}

class _ViewUserScreenState extends ConsumerState<ViewUserScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    const double padding = 8.0;
    return Scaffold(
        body: FutureBuilder<void>(
            future:
                ref.watch(userControllerProvider).setupUser(),
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
                loadModelFuture:
                    ref.watch(userControllerProvider).viewUser(),
                loadingScreen: null,
                columns: [
                  RowTextViewStream(
                    key: const ValueKey('user_name_text'),
                    size: size,
                    textFieldText: "Přezdívka:",
                    padding: padding,
                    viewMixin: ref.watch(userControllerProvider),
                    hashKey: ref.watch(userControllerProvider).nameKey(),
                  ),
                  RowTextViewStream(
                    key: const ValueKey('user_mail_text'),
                    size: size,
                    textFieldText: "Email:",
                    padding: padding,
                    viewMixin: ref.watch(userControllerProvider),
                    hashKey: ref.watch(userControllerProvider).emailKey(),
                  ),
                  RowTextViewStream(
                    key: const ValueKey('user_player_text'),
                    size: size,
                    textFieldText: "Spárování s hráčem:",
                    padding: padding,
                    viewMixin: ref.watch(userControllerProvider),
                    hashKey: ref.watch(userControllerProvider).playerKey(),
                    showIfEmptyText: false,
                  ),
                  RowTextViewStream(
                    key: const ValueKey('user_role_text'),
                    size: size,
                    textFieldText: "Práva:",
                    padding: padding,
                    viewMixin: ref.watch(userControllerProvider),
                    hashKey: ref.watch(userControllerProvider).roleKey(),
                    showIfEmptyText: false,
                  ),
                  RowTextViewStream(
                    key: const ValueKey('user_other_role_text'),
                    size: size,
                    textFieldText: "Jiné týmy:",
                    padding: padding,
                    viewMixin: ref.watch(userControllerProvider),
                    hashKey: ref.watch(userControllerProvider).otherRolesKey(),
                    showIfEmptyText: false,
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ref
              .read(screenControllerProvider)
              .changeFragment(EditPlayerScreen.id),
          elevation: 4.0,
          child: const Icon(Icons.edit),
        ));
  }
}
