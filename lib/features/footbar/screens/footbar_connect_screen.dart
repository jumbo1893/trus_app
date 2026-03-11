import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/web_view_browser.dart';
import '../../../common/widgets/button/simple_crud_button.dart';
import '../../../common/widgets/rows/row_text_view_field.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../controller/footbar_connect_notifier.dart';

class FootbarConnectScreen extends CustomConsumerWidget {
  static const String id = "footbar-connect-screen";

  const FootbarConnectScreen({
    Key? key,
  }) : super(key: key, title: "Připojení k footbar", name: id);
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(footbarConnectNotifierProvider);
    final notifier = ref.watch(footbarConnectNotifierProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          RowTextViewField(
            textFieldText: "Footbar účet",
            value: state.active? "Propojen" : "Nepropojen",
          showIfEmptyText: false,),
          const SizedBox(height: 10),
          RowTextViewField(
            textFieldText: "Přezdívka",
            value: state.nickname,
            showIfEmptyText: false,),
          const SizedBox(height: 10),
          RowTextViewField(
            textFieldText: "Footbar pozice:",
            value: state.favPosition,
            showIfEmptyText: false,),
          const SizedBox(height: 10),
          RowTextViewField(
            textFieldText: "Výška:",
            value: state.height,
            showIfEmptyText: false,),
          const SizedBox(height: 10),
          RowTextViewField(
            textFieldText: "Váha:",
            value: state.weight,
            showIfEmptyText: false,),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          Visibility(
            visible: !state.active,
            child: SimpleCrudButton(
              onPressed: () async {
                try {
                  final url = await notifier.getUrlFootbarConnection();
                  await openFootbarWebView(url, context,  (code) async =>  {
                    notifier.exchangeFootbarCode(code)
                  });
                } catch (e) {
                  debugPrint("Chyba při otevírání odkazu: $e");
                }
              },
              text: "Propojit s Footbar účtem",
            ),
          ),
        ],
      ),
    );
  }
}
