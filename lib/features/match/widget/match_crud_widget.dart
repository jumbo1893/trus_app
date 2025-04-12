import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/widget/i_match_hash_key.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/checked_list_controller_mixin.dart';
import 'package:trus_app/features/mixin/date_controller_mixin.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';

import '../../../common/static_text.dart';
import '../../../common/widgets/rows/crud/row_api_model_dropdown_stream.dart';
import '../../../common/widgets/rows/crud/row_calendar_stream.dart';
import '../../../common/widgets/rows/crud/row_checked_list_stream.dart';
import '../../../common/widgets/rows/crud/row_switch_stream.dart';
import '../../../common/widgets/rows/crud/row_text_field_stream.dart';

class MatchCrudWidget<T> extends ConsumerWidget {
  final Size size;
  final IMatchHashKey iMatchHashKey;
  final StringControllerMixin stringMixin;
  final DateControllerMixin dateMixin;
  final BooleanControllerMixin booleanMixin;
  final DropdownControllerMixin dropdownMixin;
  final CheckedListControllerMixin checkedListControllerMixin;
  final bool editEnabled;

  const MatchCrudWidget({
    Key? key,
    required this.size,
    required this.iMatchHashKey,
    required this.stringMixin,
    required this.dateMixin,
    required this.booleanMixin,
    required this.dropdownMixin,
    required this.checkedListControllerMixin,
    this.editEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double padding = 8.0;
    return Column(
      children: [
        RowTextFieldStream(
          key: const ValueKey('match_name_field'),
          size: size,
          labelText: "jméno",
          textFieldText: "Jméno soupeře:",
          padding: padding,
          stringControllerMixin: stringMixin,
          hashKey: iMatchHashKey.nameKey(),
        ),
        const SizedBox(height: 10),
        RowCalendarStream(
          key: const ValueKey('match_date_field'),
          size: size,
          padding: padding,
          textFieldText: "Datum zápasu:",
          dateControllerMixin: dateMixin,
          hashKey: iMatchHashKey.dateKey(),
        ),
        const SizedBox(height: 10),
        RowSwitchStream(
            key: const ValueKey('match_home_field'),
            size: size,
            padding: padding,
            textFieldText: "domácí zápas?",
            booleanControllerMixin: booleanMixin,
            hashKey: iMatchHashKey.homeKey(),
            ),
        const SizedBox(height: 10),
        RowApiModelDropDownStream(
          key: const ValueKey('match_season_field'),
          size: size,
          padding: padding,
          text: 'Vyber sezonu',
          hint: 'Vyber sezonu',
          dropdownControllerMixin: dropdownMixin,
          hashKey: iMatchHashKey.seasonKey(),
        ),
        const SizedBox(height: 10),
        RowCheckedListStream(
          key: const ValueKey('match_player_field'),
          size: size,
          padding: padding,
          textFieldText: "Vyber hráče",
          defaultErrorText: atLeastOnePlayerMustBePresentValidation,
          checkedListControllerMixin:
          checkedListControllerMixin,
          hashKey: iMatchHashKey.playerKey(),
        ),
        const SizedBox(height: 10),
        RowCheckedListStream(
          key: const ValueKey('match_fan_field'),
          size: size,
          padding: padding,
          textFieldText: "Vyber fanoušky",
          defaultErrorText: atLeastOnePlayerMustBePresentValidation,
          checkedListControllerMixin:
          checkedListControllerMixin,
          hashKey: iMatchHashKey.fanKey(),
        ),

      ],
    );
  }
}
