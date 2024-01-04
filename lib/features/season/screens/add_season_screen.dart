import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import '../../../common/widgets/builder/column_future_builder.dart';
import '../../../common/widgets/button/crud_button.dart';
import '../../../common/widgets/rows/stream/row_calendar_stream.dart';
import '../../../common/widgets/rows/stream/row_text_field_stream.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/enum/crud.dart';
import '../../main/screen_controller.dart';
import '../controller/season_controller.dart';

class AddSeasonScreen extends CustomConsumerStatefulWidget {
  static const String id = "add-season-screen";

  const AddSeasonScreen({
    Key? key,
  }) : super(key: key, title: "Přidat sezonu", name: id);

  @override
  ConsumerState<AddSeasonScreen> createState() => _AddSeasonScreenState();
}

class _AddSeasonScreenState extends ConsumerState<AddSeasonScreen> {
  @override
  Widget build(BuildContext context) {
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(AddSeasonScreen.id)) {
      const double padding = 8.0;
      final size =
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(seasonControllerProvider).newSeason(),
        columns: [
          RowTextFieldStream(
            key: const ValueKey('season_name_field'),
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
            key: const ValueKey('season_start_date_field'),
            size: size,
            padding: padding,
            textFieldText: "Začátek sezony:",
            onDateChanged: (date) {
              ref.watch(seasonControllerProvider).setFromDate(date);
            },
            dateStream: ref.watch(seasonControllerProvider).fromDate(),
            errorTextStream:
                ref.watch(seasonControllerProvider).fromDateErrorText(),
          ),
          const SizedBox(height: 10),
          RowCalendarStream(
            key: const ValueKey('season_end_date_field'),
            size: size,
            padding: padding,
            textFieldText: "Konec sezony:",
            onDateChanged: (date) {
              ref.watch(seasonControllerProvider).setToDate(date);
            },
            dateStream: ref.watch(seasonControllerProvider).toDate(),
            errorTextStream:
                ref.watch(seasonControllerProvider).toDateErrorText(),
          ),
          const SizedBox(height: 10),
          CrudButton(
            key: const ValueKey('confirm_button'),
            text: "Potvrď",
            context: context,
            crud: Crud.create,
            crudOperations: ref.read(seasonControllerProvider),
            onOperationComplete: (id) {
              ref
                  .read(screenControllerProvider)
                  .changeFragment(SeasonScreen.id);
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
