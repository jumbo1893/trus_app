import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/notification/controller/notifications_notifier.dart';
import '../../../common/widgets/builder/notifications_list_builder.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';

class NotificationScreen extends CustomConsumerWidget {
  static const String id = 'notification-screen';
  const NotificationScreen({super.key})
    : super(title: 'Historie úkonů', name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsNotifierProvider);
    final notifier = ref.read(notificationsNotifierProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Zaznamenaná oznámení týmu. Nejde o úplný přehled.',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Obnovit historii',
                    onPressed: notifier.reload,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child: NotificationListBuilder(
                notificationsList: state.notifications,
                onRetry: notifier.reload,
                footer: state.showNextButton
                    ? Column(
                        children: [
                          if (state.olderFailed)
                            const Text(
                              'Starší úkony se nepodařilo načíst. Zkus to znovu.',
                              textAlign: TextAlign.center,
                            ),
                          TextButton.icon(
                            onPressed: state.loadingOlder
                                ? null
                                : notifier.nextPage,
                            icon: state.loadingOlder
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.expand_more),
                            label: Text(
                              state.loadingOlder
                                  ? 'Načítání starších úkonů…'
                                  : 'Načíst starší',
                            ),
                          ),
                        ],
                      )
                    : const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'To jsou všechny zaznamenané úkony.',
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
