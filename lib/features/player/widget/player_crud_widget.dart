import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/date_controller_mixin.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/features/player/widget/i_player_hash_key.dart';

import '../../../common/widgets/rows/crud/row_api_model_dropdown_stream.dart';
import '../../../common/widgets/rows/crud/row_calendar_stream.dart';
import '../../../common/widgets/rows/crud/row_switch_stream.dart';
import '../../../common/widgets/rows/crud/row_text_field_stream.dart';

class PlayerCrudWidget<T> extends ConsumerWidget {
  final Size size;
  final IPlayerHashKey iPlayerHashKey;
  final StringControllerMixin stringMixin;
  final DateControllerMixin dateMixin;
  final BooleanControllerMixin booleanMixin;
  final DropdownControllerMixin dropdownMixin;
  final bool editEnabled;

  const PlayerCrudWidget({
    Key? key,
    required this.size,
    required this.iPlayerHashKey,
    required this.stringMixin,
    required this.dateMixin,
    required this.booleanMixin,
    required this.dropdownMixin,
    this.editEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double padding = 8.0;
    return Column(
      children: [
        RowTextFieldStream(
          key: const ValueKey('player_name_field'),
          size: size,
          labelText: "jméno",
          textFieldText: "Přezdívka:",
          padding: padding,
          stringControllerMixin: stringMixin,
          hashKey: iPlayerHashKey.nameKey(),
          editEnabled: editEnabled,
        ),
        const SizedBox(height: 10),
        RowApiModelDropDownStream(
          key: const ValueKey('player_footballer_spinner'),
          size: size,
          padding: padding,
          text: 'Jméno hráče',
          hint: 'Vyber hráče',
          dropdownControllerMixin: dropdownMixin,
          hashKey: iPlayerHashKey.footballerKey(),
          editEnabled: editEnabled,
        ),
        const SizedBox(height: 10),
        RowCalendarStream(
          key: const ValueKey('player_date_field'),
          size: size,
          padding: padding,
          textFieldText: "Datum narození:",
          dateControllerMixin: dateMixin,
          hashKey: iPlayerHashKey.dateKey(),
        ),
        const SizedBox(height: 10),
        RowSwitchStream(
          key: const ValueKey('player_fan_field'),
          size: size,
          padding: padding,
          textFieldText: "fanoušek?",
          booleanControllerMixin: booleanMixin,
          hashKey: iPlayerHashKey.fanKey(),
        ),
        const SizedBox(height: 10),
        RowSwitchStream(
          key: const ValueKey('player_active_field'),
          size: size,
          padding: padding,
          textFieldText: "aktivní?",
          booleanControllerMixin: booleanMixin,
          hashKey: iPlayerHashKey.activeKey(),
        ),

      ],
    );
  }
}
