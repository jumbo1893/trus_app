import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/models/api/notification/push/push_payload.dart';
import 'package:trus_app/services/push/push_navigation_handler.dart';

void main() {
  testWidgets('greeting push navigates from menu to dashboard', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(screenNotifierProvider.notifier).changeByFragmentId('more-hub');
    PushNavigationHandler.navigate(
      PushNavigationRef(read: container.read, invalidate: container.invalidate),
      PushPayload.fromData({'screenId': 'home-screen', 'type': 'GLOBAL'}),
    );
    tester.binding.scheduleFrame();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(container.read(screenNotifierProvider).currentScreenId, HomeScreen.id);
    expect(container.read(screenNotifierProvider).backButtonVisible, isFalse);
  });
}
