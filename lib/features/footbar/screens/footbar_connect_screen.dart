import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/button/stream_visibility_button.dart';
import 'package:trus_app/common/widgets/loader.dart';

import '../../../common/utils/web_view_browser.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/rows/view/row_text_view_stream.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../controller/footbar_connect_controller.dart';

class FootbarConnectScreen extends CustomConsumerWidget {
  static const String id = "footbar-connect-screen";


  const FootbarConnectScreen({
    Key? key,
  }) : super(key: key, title: "Připojení k footbar", name: id);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(footbarConnectControllerProvider);
    if (ref.read(screenControllerProvider).isScreenFocused(FootbarConnectScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return Scaffold(
        body: FutureBuilder(
            future:
            controller.setupFootbarProfile(),
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
                loadModelFuture: controller.viewProfile(),
                columns: [
                  RowTextViewStream(
                    key: const ValueKey('footbar_active_text'),
                    size: size,
                    textFieldText: "Footbar účet:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.activeTextKey,
                  ),
                  const SizedBox(height: 10),

                  RowTextViewStream(
                    key: const ValueKey('footbar_nickname_text'),
                    size: size,
                    textFieldText: "Footbar přezdívka:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.nicknameKey,
                    showIfEmptyText: false,
                  ),
                  const SizedBox(height: 10),
                  RowTextViewStream(
                    key: const ValueKey('footbar_position_text'),
                    size: size,
                    textFieldText: "Footbar pozice:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.favPositionKey,
                    showIfEmptyText: false,
                  ),
                  const SizedBox(height: 10),
                  RowTextViewStream(
                    key: const ValueKey('footbar_height_text'),
                    size: size,
                    textFieldText: "Výška:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.heightKey,
                    showIfEmptyText: false,
                  ),
                  const SizedBox(height: 10),
                  RowTextViewStream(
                    key: const ValueKey('footbar_weight_text'),
                    size: size,
                    textFieldText: "Váha:",
                    padding: padding,
                    viewMixin: controller,
                    hashKey: controller.weightKey,
                    showIfEmptyText: false,
                  ),
                  const SizedBox(height: 10),
                  StreamVisibilityButton(
                    key: const ValueKey('footbar_connect_button'),
                    text: "Propojit s Footbar účtem",
                    onPressed: () async {
                      try {
                        final url = await controller.getUrlFootbarConnection();
                        await openFootbarWebView(url, context,  (code) async =>  {
                          if (await controller.exchangeFootbarCode(code)) {
                            showSnackBar(context: context, content: "Úspěšně připojeno"),
                            await controller.setupFootbarProfile().whenComplete(() async => await controller.viewProfile())
                          }
                          else {
                            showSnackBar(context: context, content: "Chyba při připojení")
                          }
                        });
                      } catch (e) {
                        debugPrint("Chyba při otevírání odkazu: $e");
                      }
                    }, booleanControllerMixin: controller, hashKey: controller.activeKey,
                  )
                ],
                loadingScreen: null,
              );
            }),
      );
    } else {
      return Container();
    }
  }
}
