import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/builder/enabled_notifications_list_builder.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../controller/enabled_notifications_notifier.dart';
import '../state/enabled_notifications_state.dart';

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
            PushStatusCard(
              pushPermissionInfo: state.pushPermissionInfo,
              sendingTestPush: state.sendingTestPush,
              refreshingPushStatus: state.refreshingPushStatus,
              onRefresh: notifier.refreshPushPermissionInfo,
              onSendTestPush: notifier.sendTestPushToThisDevice,
              onRequestPermission: notifier.requestPermissionAndRefresh,
            ),
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

class PushStatusCard extends StatelessWidget {
  final AsyncValue<PushPermissionInfo> pushPermissionInfo;
  final bool sendingTestPush;
  final bool refreshingPushStatus;
  final VoidCallback onRefresh;
  final VoidCallback onSendTestPush;
  final VoidCallback onRequestPermission;

  const PushStatusCard({
    super.key,
    required this.pushPermissionInfo,
    required this.sendingTestPush,
    required this.refreshingPushStatus,
    required this.onRefresh,
    required this.onSendTestPush,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return pushPermissionInfo.when(
      loading: () => const _PushStatusLoadingCard(),
      error: (error, _) => _PushStatusErrorCard(
        error: error,
        onRefresh: onRefresh,
      ),
      data: (info) => _PushStatusLoadedCard(
        info: info,
        sendingTestPush: sendingTestPush,
        refreshingPushStatus: refreshingPushStatus,
        onRefresh: onRefresh,
        onSendTestPush: onSendTestPush,
        onRequestPermission: onRequestPermission,
      ),
    );
  }
}

class _PushStatusLoadingCard extends StatelessWidget {
  const _PushStatusLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text("Ověřuji stav push notifikací..."),
            ),
          ],
        ),
      ),
    );
  }
}

class _PushStatusErrorCard extends StatelessWidget {
  final Object error;
  final VoidCallback onRefresh;

  const _PushStatusErrorCard({
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Stav push notifikací se nepodařilo ověřit",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRefresh,
              child: const Text("Zkusit znovu"),
            ),
          ],
        ),
      ),
    );
  }
}

class _PushStatusLoadedCard extends StatelessWidget {
  final PushPermissionInfo info;
  final bool sendingTestPush;
  final bool refreshingPushStatus;
  final VoidCallback onRefresh;
  final VoidCallback onSendTestPush;
  final VoidCallback onRequestPermission;

  const _PushStatusLoadedCard({
    required this.info,
    required this.sendingTestPush,
    required this.refreshingPushStatus,
    required this.onRefresh,
    required this.onSendTestPush,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = info.ready
        ? Colors.green
        : info.denied
        ? Colors.red
        : Colors.orange;

    final title = info.ready
        ? "Push notifikace jsou připravené"
        : "Push notifikace nejsou plně aktivní";

    final subtitle = info.ready
        ? "Zařízení má oprávnění, FCM token a backend ho zná."
        : _buildProblemText(info);

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  info.ready
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: statusColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 12),
            _StatusLine(
              label: "Povolení systému",
              value: info.authorizationLabel,
              ok: info.allowed,
            ),
            _StatusLine(
              label: "FCM token",
              value: info.hasToken ? "Dostupný" : "Nedostupný",
              ok: info.hasToken,
            ),
            _StatusLine(
              label: "Backend synchronizace",
              value: info.backendSynced ? "OK" : "Neověřeno",
              ok: info.backendSynced,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: refreshingPushStatus ? null : onRefresh,
                    child: Text(
                      refreshingPushStatus ? "Ověřuji..." : "Znovu ověřit",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: sendingTestPush || !info.hasToken
                        ? null
                        : onSendTestPush,
                    child: Text(
                      sendingTestPush ? "Odesílám..." : "Poslat test",
                    ),
                  ),
                ),
              ],
            ),
            if (!info.allowed) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onRequestPermission,
                  child: const Text("Povolit oznámení"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildProblemText(PushPermissionInfo info) {
    if (!info.allowed) {
      return "Aplikace nemá povolené notifikace v systému.";
    }

    if (!info.hasToken) {
      return "Firebase zatím nevrátil FCM token pro toto zařízení.";
    }

    if (!info.backendSynced) {
      return "Token se zatím nepodařilo ověřit proti backendu.";
    }

    return "Stav není kompletní.";
  }
}

class _StatusLine extends StatelessWidget {
  final String label;
  final String value;
  final bool ok;

  const _StatusLine({
    required this.label,
    required this.value,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 17,
            color: ok ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text("$label: $value"),
          ),
        ],
      ),
    );
  }
}