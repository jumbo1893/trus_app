import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/user/controller/user_notifier.dart';

import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';


class UserScreen extends CustomConsumerStatefulWidget {
  static const String id = "user-screen";

  const UserScreen({
    Key? key,
  }) : super(key: key, title: "Nastavení uživatelů", name: id);

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModelToStringListview(
              state: ref.watch(userNotifierProvider),
              notifier: ref.read(userNotifierProvider.notifier)),
        ),
       );
  }
}
