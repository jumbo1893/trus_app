import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/builder/enabled_notifications_list_builder.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../controller/enabled_notifications_notifier.dart';

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
    final state = ref.watch(enabledNotificationsNotifierProvider);
    final notifier = ref.read(enabledNotificationsNotifierProvider.notifier);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            Expanded(
              child: EnabledNotificationsListBuilder(
                notificationsList: state.enabledNotifications,
                notifier: notifier,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomButton(
                text: "Potvrď změny",
                onPressed: notifier.commit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
