import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/user/controller/user_controller.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/confirmation_dialog.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../general/error/api_executor.dart';
import '../../main/screen_controller.dart';


class UserScreen extends CustomConsumerStatefulWidget {
  static const String id = "user-screen";

  const UserScreen({
    Key? key,
  }) : super(key: key, title: "Nastavení uživatelů", name: id);

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  void showChangePermissionConfirmation(UserApiModel user) {
    var dialog = ConfirmationDialog(
        user.admin!
            ? "Opravdu chcete odebrat práva uživateli ${user.name}?"
            : "Opravdu chcete zpřístupnit práva uživateli ${user.name}?", () {
      changePermissions(user);
    });
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  Future<void> changePermissions(UserApiModel user) async {
    await executeApi<void>(() async {
      return await ref
          .read(userControllerProvider)
          .changeWritePermissions(user);
    }, () => ref.read(screenControllerProvider).changeFragment(HomeScreen.id),
            context, true)
        .whenComplete(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (ref.read(screenControllerProvider).isScreenFocused(UserScreen.id)) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModelsErrorFutureBuilder(
            future: ref.watch(userControllerProvider).getModels(),
            onPressed: (user) =>
                {showChangePermissionConfirmation(user as UserApiModel)},
            context: context,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
