import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/user/controller/view_user_notifier.dart';

import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../../common/widgets/rows/app_read_only_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
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
    final state = ref.watch(viewUserNotifierProvider);
    final notifier = ref.read(viewUserNotifierProvider.notifier);

    return BaseFormScreen(
      headerTitle: state.name,
      headerText: state.email,
      fields: [
        FormFieldWrapper(
          label: "Spárování s hráčem",
          child: CustomDropdownSheet(
            state: state,
            notifier: notifier,
            hint: "Vyber hráče",
          ),
        ),
        FormFieldWrapper(
          label: "Práva",
          child: AppReadOnlyField(
            value: state.userTeamRole?.roleToString() ?? "Bez práv",
            allowWrap: true,
          ),
        ),
        if (state.otherRoles.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Jiné týmy",
            child: AppReadOnlyField(
              value: state.otherRoles,
              allowWrap: true,
            ),
          ),
      ],
      actions: [
        ActionButtonItem(
          label: "Potvrdit změny",
          onPressed: () => notifier.commit(),
          type: ActionButtonType.primary,
        ),
      ],
    );
  }
}