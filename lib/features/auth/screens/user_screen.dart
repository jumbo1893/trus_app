import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';
import 'package:trus_app/models/api/user_api_model.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/confirmation_dialog.dart';
import '../../../models/user_model.dart';
import '../../general/error/api_executor.dart';

class UserScreen extends ConsumerStatefulWidget {
  final bool isFocused;
  final VoidCallback backToMainMenu;
  const UserScreen({
    required this.isFocused,
    required this.backToMainMenu,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {

  void showChangePermissionConfirmation(UserApiModel user) {
    var dialog = ConfirmationDialog(user.admin! ? "Opravdu chcete odebrat práva uživateli ${user.name}?" : "Opravdu chcete zpřístupnit práva uživateli ${user.name}?", () {
      changePermissions(user);
    });
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  Future<void> changePermissions(UserApiModel user) async {
    await executeApi<void>(() async {
      return await ref.read(authControllerProvider).changeWritePermissions(context, user);
    },() => widget.backToMainMenu.call(), context, true).whenComplete(() => setState(() {
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModelsErrorFutureBuilder(
              future: ref.watch(authControllerProvider).getModels(),
              onPressed: (user) => {showChangePermissionConfirmation(user as UserApiModel)},
              onDialogCancel: () => widget.backToMainMenu.call(),
              context: context,
            ),
          ),
         );
    }
    else {
      return Container();
    }
  }
}
