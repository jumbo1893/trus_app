import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/button/confirm_button.dart';
import 'package:trus_app/features/user/controller/user_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/rows/crud/row_api_model_dropdown_stream.dart';
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
    var controller = ref.watch(userControllerProvider);
    return Scaffold(
        body: FutureBuilder<void>(
            future:
            controller.setupUser(),
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
                controller.viewUser(),
                loadingScreen: null,
                columns: [
                  RowTextViewStream(
                    key: const ValueKey('user_name_text'),
                    size: size,
                    textFieldText: "Přezdívka:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.nameKey(),
                  ),
                  RowTextViewStream(
                    key: const ValueKey('user_mail_text'),
                    size: size,
                    textFieldText: "Email:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.emailKey(),
                  ),
                  RowApiModelDropDownStream(
                    key: const ValueKey('user_player_text'),
                    size: size,
                    text: "Spárování s hráčem:",
                    padding: padding,
                    dropdownControllerMixin: controller,
                    hashKey: controller.playerKey(),
                    editEnabled: true,
                    hint: 'Vyber hráče',
                  ),
                  RowTextViewStream(
                    key: const ValueKey('user_role_text'),
                    size: size,
                    textFieldText: "Práva:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.roleKey(),
                    showIfEmptyText: false,
                  ),
                  RowTextViewStream(
                    key: const ValueKey('user_other_role_text'),
                    size: size,
                    textFieldText: "Jiné týmy:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.otherRolesKey(),
                    showIfEmptyText: false,
                  ),
                  const SizedBox(height: 10),
                  ConfirmButton(
                    text: "Potvrď změny",
                    context: context,
                    confirmOperations: controller,
                    id: -1,
                    onOperationComplete: () {
                      ref
                          .read(screenControllerProvider)
                          .changeFragment(HomeScreen.id);
                    },
                  ),
                ],
              );
            }),
        );
  }
}
