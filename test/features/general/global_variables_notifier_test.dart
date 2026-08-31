import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

void main() {
  test('player can be cleared after it was selected', () {
    final notifier = GlobalVariablesNotifier();
    notifier.setPlayer(PlayerApiModel.dummy());

    notifier.setPlayer(null);

    expect(notifier.state.player, isNull);
  });
}
