import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/features/beer/controller/beer_view_preference.dart';

void main() {
  test(
    'account is the default and draw mode persists on this device',
    () async {
      SharedPreferences.setMockInitialValues({});
      final first = ProviderContainer();
      addTearDown(first.dispose);
      expect(first.read(beerViewPreferenceProvider), isFalse);

      await first.read(beerViewPreferenceProvider.notifier).setDrawMode(true);
      expect(first.read(beerViewPreferenceProvider), isTrue);

      final reopened = ProviderContainer();
      addTearDown(reopened.dispose);
      await reopened.read(beerViewPreferenceProvider.notifier).load();
      expect(reopened.read(beerViewPreferenceProvider), isTrue);
    },
  );
}
