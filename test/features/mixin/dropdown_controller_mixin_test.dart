import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';

class _TestDropdownController with DropdownControllerMixin {}

void main() {
  test('dropdown accepts an empty list with no selected item', () async {
    final controller = _TestDropdownController();
    const key = 'empty_dropdown';

    controller.initDropdown(null, const [], key);
    final emittedValue = controller.dropdownItem(key).first;
    controller.initDropdownItem(key);

    expect(await emittedValue, isNull);
    expect(controller.dropdownValues[key], isNull);
    expect(controller.dropdownLists[key], isEmpty);
  });
}
