import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/confirmation_dialog.dart';
import '../../../models/user_model.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {

  Future<void> rewriteUserPermissions(UserModel user) async {
    if(user.id == ref.read(authControllerProvider).getCurrentUserId()) {
      showSnackBar(
        context: context,
        content: "Nelze měnit práva u aktuálně přihlášené osoby.",
      );
      return;
    }
    final bool newWritePermission = !user.writePermission;
    if(await ref.read(authControllerProvider).setWritePermissions(context, user, !user.writePermission)) {
      showSnackBar(
        context: context,
        content: "Úspěšně nastavena práva pro psaní u uživatele ${user.name} na $newWritePermission",
      );
    }
  }

  void showDeleteConfirmation(UserModel user) {
    var dialog = ConfirmationDialog("Opravdu změnit práva u uživatele ${user.name}?", () {
      rewriteUserPermissions(user);
    });
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<List<UserModel>>(
              stream: ref.watch(authControllerProvider).users(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var user = snapshot.data![index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => showDeleteConfirmation(user),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8, right: 8),
                            child: Container(
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                color: Colors.grey,
                              ))),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    user.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                subtitle: Text(
                                  user.toString(),
                                  style: const TextStyle(
                                      color: listviewSubtitleColor),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              }),
        ),
        );
  }
}
