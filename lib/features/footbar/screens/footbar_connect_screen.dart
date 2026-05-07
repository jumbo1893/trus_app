import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/web_view_browser.dart';
import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/rows/app_read_only_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../../features/footbar/controller/footbar_sync_notifier.dart';
import '../controller/footbar_connect_notifier.dart';

class FootbarConnectScreen extends CustomConsumerWidget {
  static const String id = "footbar-connect-screen";

  const FootbarConnectScreen({
    Key? key,
  }) : super(key: key, title: "Připojení k Footbar", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectState = ref.watch(footbarConnectNotifierProvider);
    final connectNotifier = ref.read(footbarConnectNotifierProvider.notifier);

    final syncState = ref.watch(footbarSyncNotifierProvider);
    final syncNotifier = ref.read(footbarSyncNotifierProvider.notifier);

    return BaseFormScreen(
      headerTitle: "Footbar účet",
      headerText: connectState.active
          ? "Účet je propojený"
          : "Účet zatím není propojený",
      fields: [
        FormFieldWrapper(
          label: "Stav propojení",
          child: AppReadOnlyField(
            value: connectState.active ? "Propojen" : "Nepropojen",
          ),
        ),
        if (connectState.nickname.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Přezdívka",
            child: AppReadOnlyField(
              value: connectState.nickname,
              allowWrap: true,
            ),
          ),
        if (connectState.favPosition.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Footbar pozice",
            child: AppReadOnlyField(
              value: connectState.favPosition,
              allowWrap: true,
            ),
          ),
        if (connectState.height.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Výška",
            child: AppReadOnlyField(
              value: connectState.height,
            ),
          ),
        if (connectState.weight.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Váha",
            child: AppReadOnlyField(
              value: connectState.weight,
            ),
          ),
        FormFieldWrapper(
          label: "Poslední aktualizace statistik",
          child: AppReadOnlyField(
            value: syncState.lastSync,
            allowWrap: true,
          ),
        ),
      ],
      actions: [
        if (!connectState.active)
          ActionButtonItem(
            label: "Propojit Footbar",
            onPressed: () async {
              try {
                final url = await connectNotifier.getUrlFootbarConnection();

                await openFootbarWebView(
                  url,
                  context,
                      (code) async {
                    await connectNotifier.exchangeFootbarCode(code);
                  },
                );
              } catch (e) {
                debugPrint("Chyba při otevírání odkazu: $e");
              }
            },
            type: ActionButtonType.primary,
          ),
        ActionButtonItem(
          label: "Aktualizovat statistiky",
          onPressed: () => syncNotifier.syncAppTeamActivities(),
          type: connectState.active
              ? ActionButtonType.primary
              : ActionButtonType.secondary,
        ),
      ],
    );
  }
}