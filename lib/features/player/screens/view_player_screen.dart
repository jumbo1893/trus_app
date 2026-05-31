import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/rows/achievement_view.dart';
import 'package:trus_app/common/widgets/rows/app_read_only_field.dart';
import 'package:trus_app/common/widgets/rows/form/form_field_wrapper.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/player/player_notifier_args.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/models/helper/title_and_text.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/widgets/rows/form/form_row.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../mixin/restorable_scroll_mixin.dart';
import '../controller/player_edit_notifier.dart';

class ViewPlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-player-screen";

  const ViewPlayerScreen({
    Key? key,
  }) : super(key: key, title: "Zobrazení hráče", name: id);

  @override
  ConsumerState<ViewPlayerScreen> createState() => _ViewPlayerScreenState();
}

class _ViewPlayerScreenState extends ConsumerState<ViewPlayerScreen>
    with RestorableScrollMixin<ViewPlayerScreen> {
  @override
  String get scrollStorageKey => ViewPlayerScreen.id;

  List<Widget> _buildStatFields(List<TitleAndText> titleAndTexts) {
    return titleAndTexts
        .where((e) => e.text.trim().isNotEmpty)
        .map(
          (e) => FormFieldWrapper(
        label: e.title,
        child: AppReadOnlyField(
          value: e.text,
          allowWrap: true,
        ),
      ),
    )
        .toList();
  }

  List<Widget> _buildPairedStatFields(List<List<TitleAndText>> pairedStats) {
    return pairedStats.where((row) => row.length >= 2).map((row) {
      final first = row[0];
      final second = row[1];

      return FormRow(
        children: [
          FormFieldWrapper(
            label: first.title,
            child: AppReadOnlyField(
              value: first.text,
              allowWrap: true,
            ),
          ),
          FormFieldWrapper(
            label: second.title,
            child: AppReadOnlyField(
              value: second.text,
              allowWrap: true,
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final variables = ref.watch(screenVariablesNotifierProvider);
    final playerId = variables.playerId ?? variables.playerModel.id;

    if (playerId == null || playerId == 0) {
      return const Loader();
    }

    final PlayerNotifierArgs arg = PlayerNotifierArgs.view(playerId);
    final state = ref.watch(playerEditNotifierProvider(arg));

    return BaseFormScreen(
      scrollController: scrollController,
      headerTitle: "${state.fan ? "fanoušek" : "hráč"}: ${state.name}",
      headerText: "Datum narození: ${dateTimeToString(state.birthdate)}",
      fields: [
        if ((state.selectedFootballPlayer?.dropdownItem() ?? "").trim().isNotEmpty)
          FormFieldWrapper(
            label: "Jméno hráče",
            child: AppReadOnlyField(
              value: state.selectedFootballPlayer?.dropdownItem() ?? "",
              allowWrap: true,
            ),
          ),
        ..._buildPairedStatFields(state.pairedPlayerStats),
        ..._buildStatFields(state.playerStats),
      ],
      extraSections: [
        if (state.achievementPlayerDetail != null) ...[
          AppWidgetValues.field,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AchievementView(
              achievementPlayerDetail: state.achievementPlayerDetail,
            ),
          ),
        ],
      ],
      actions: const [],
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref
            .read(screenNotifierProvider.notifier)
            .changeFragment(EditPlayerScreen.id),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
