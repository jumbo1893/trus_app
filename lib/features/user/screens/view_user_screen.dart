import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/user/controller/view_user_notifier.dart';

import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/rows/row_custom_dropdown.dart';
import '../../../common/widgets/rows/row_text_view_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
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
    final notifier = ref.read(viewUserNotifierProvider.notifier);
    final state = ref.watch(viewUserNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          RowTextViewField(
            textFieldText: "Přezdívka",
            value: state.name,),
          const SizedBox(height: 10),
          RowTextViewField(
            textFieldText: "Email",
            value: state.email,),
          const SizedBox(height: 10),
          RowCustomDropdown(
              text: 'Spárování s hráčem',
              hint: 'Vyber hráče',
              state: state,
              notifier: notifier),
          const SizedBox(height: 10),
          RowTextViewField(
            textFieldText: "Práva",
            value: state.userTeamRole?.roleToString() ?? "Bez práv"),
          const SizedBox(height: 10),
          RowTextViewField(
              textFieldText: "Jiné týmy",
              value: state.otherRoles,
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          SimpleCrudButton(
            onPressed: () async => notifier.commit(),
            text: "Potvrď změny",
          ),
        ],
      ),
    );
  }
}
