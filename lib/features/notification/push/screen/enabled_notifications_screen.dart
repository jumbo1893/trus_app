import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/notification/push/controller/enabled_notification_controller.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';
import 'package:trus_app/models/api/notification/push/notification_type.dart';

import '../../../../common/utils/utils.dart';
import '../../../../common/widgets/builder/column_future_builder.dart';
import '../../../../common/widgets/button/edit_models_button.dart';
import '../../../../common/widgets/loader.dart';
import '../../../../common/widgets/rows/crud/row_long_text_switch_stream.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../home/screens/home_screen.dart';
import '../../../main/screen_controller.dart';

class EnabledNotificationsScreen extends CustomConsumerStatefulWidget {
  static const String id = "enabled-notification-screen";

  const EnabledNotificationsScreen({
    Key? key,
  }) : super(key: key, title: "Oznámení", name: id);

  @override
  ConsumerState<EnabledNotificationsScreen> createState() =>
      _EnabledNotificationsScreenState();
}

class _EnabledNotificationsScreenState
    extends ConsumerState<EnabledNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    var controller = ref.watch(enabledNotificationController);
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(EnabledNotificationsScreen.id)) {
      final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return FutureBuilder<void>(
          future: controller.setupEnabledNotifications(),
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
                loadModelFuture: controller.enabledNotifications(),
                loadingScreen: null,
                columns: booleanWidgetList(controller));
          });
    } else {
      return Container();
    }
  }

  List<Widget> booleanWidgetList(
      EnabledNotificationController controller) {
    List<Widget> returnList = [];
    const double padding = 8.0;
    for (EnabledPushNotification enabledPushNotification
        in controller.enabledNotificationsList) {
      String enabledNotificationText =
          notificationTypeToServer(enabledPushNotification.type);
      returnList.add(
        RowLongTextSwitchStream(
          key: ValueKey("${enabledNotificationText}_field"),
          padding: padding,
          textFieldText: enabledPushNotification.listViewTitle(),
          booleanControllerMixin: controller,
          hashKey: enabledNotificationText,
        ),
      );
    }
    returnList.add(EditModelsButton(
      key: const ValueKey('confirm_button'),
      text: "Potvrď",
      context: context,
      editModelsFunction: () => controller.editModels(),
      onOperationComplete: () => ref
          .read(screenControllerProvider)
          .changeFragment(HomeScreen.id),
    ));
    return returnList;
  }
}
