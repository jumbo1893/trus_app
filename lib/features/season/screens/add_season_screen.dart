import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/rows/row_calendar.dart';
import 'package:trus_app/common/widgets/rows/row_text_field.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/stream/row_calendar_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../models/enum/crud.dart';
import '../../../models/season_model.dart';
import '../../notification/controller/notification_controller.dart';
import '../controller/season_controller.dart';

class AddSeasonScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddSeasonPressed;
  final bool isFocused;
  const AddSeasonScreen({
    Key? key,
    required this.onAddSeasonPressed,
    required this.isFocused,
  }) : super(key: key);

  @override
  ConsumerState<AddSeasonScreen> createState() => _AddSeasonScreenState();
}

class _AddSeasonScreenState extends ConsumerState<AddSeasonScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      const double padding = 8.0;
      final size =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(seasonControllerProvider).newSeason(),
        columns: [
          RowTextFieldStream(
            size: size,
            labelText: "název",
            padding: padding,
            textFieldText: "Název sezony:",
            textStream: ref.watch(seasonControllerProvider).name(),
            errorTextStream:
                ref.watch(seasonControllerProvider).nameErrorText(),
            onTextChanged: (name) =>
                {ref.watch(seasonControllerProvider).setName(name)},
          ),
          const SizedBox(height: 10),
          RowCalendarStream(
            size: size,
            padding: padding,
            textFieldText: "Začátek sezony:",
            onDateChanged: (date) {
              ref.watch(seasonControllerProvider).setFromDate(date);
            },
            dateStream: ref.watch(seasonControllerProvider).fromDate(),
            errorTextStream: ref.watch(seasonControllerProvider).fromDateErrorText(),
          ),
          const SizedBox(height: 10),
          RowCalendarStream(
            size: size,
            padding: padding,
            textFieldText: "Konec sezony:",
            onDateChanged: (date) {
              ref.watch(seasonControllerProvider).setToDate(date);
            },
            dateStream: ref.watch(seasonControllerProvider).toDate(),
            errorTextStream: ref.watch(seasonControllerProvider).toDateErrorText(),
          ),
          const SizedBox(height: 10),
          CrudButton(
            text: "Přidej sezonu",
            context: context,
            crud: Crud.create,
            crudOperations: ref.read(seasonControllerProvider),
            onOperationComplete: (id) {
              widget.onAddSeasonPressed();
            },
          )
        ],
        loadingScreen: null,
      );
    } else {
      return Container();
    }
  }
}
