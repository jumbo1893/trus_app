import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/achievement_view.dart';
import 'package:trus_app/features/player/player_notifier_args.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/widgets/notifier/loader/loading_overlay.dart';
import '../../../common/widgets/rows/row_text_view_field.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../main/screen_controller.dart';
import '../controller/player_edit_notifier.dart';

class ViewPlayerScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-player-screen";

  const ViewPlayerScreen({
    Key? key,
  }) : super(key: key, title: "Zobrazení hráče", name: id);

  @override
  ConsumerState<ViewPlayerScreen> createState() => _ViewPlayerScreenState();
}

class _ViewPlayerScreenState extends ConsumerState<ViewPlayerScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _scrollRestored = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      ref
          .read(screenControllerProvider)
          .saveScrollOffset(
        ViewPlayerScreen.id,
        _scrollController.offset,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_scrollRestored) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = ref
          .read(screenControllerProvider)
          .getScrollOffset(ViewPlayerScreen.id);

      if (offset != null && _scrollController.hasClients) {
        _scrollController.jumpTo(offset);
        _scrollRestored = true;
      }
    });
  }

  List<Widget> getTitleAndTextWidgets(List<TitleAndText> titleAndTexts) {
    List<Widget> widgets = [];
    for (var titleAndTexts in titleAndTexts) {
      widgets.add(RowTextViewField(
          textFieldText: titleAndTexts.title,
          value: titleAndTexts.text,
        allowWrap: true,
      showIfEmptyText: false,),);
    }
    widgets.add(const SizedBox(height: 10));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    PlayerApiModel player = ref.watch(screenControllerProvider).playerModel;
    PlayerNotifierArgs arg = PlayerNotifierArgs.view(player.id);
    final notifier = ref.read(playerEditNotifierProvider(arg).notifier);
    final state = ref.watch(playerEditNotifierProvider(arg));
    return Scaffold(
      body: LoadingOverlay(
          state: state,
          onClearError: notifier.clearErrorMessage,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  RowTextViewField(
                      textFieldText: state.fan ? "Fanoušek:" : "Hráč:",
                      value: state.name,),
                  const SizedBox(height: 10),
                  RowTextViewField(
                    textFieldText: "Jméno hráče",
                    value: state.selectedFootballPlayer?.dropdownItem() ?? "",
                    showIfEmptyText: false,
                  ),
                  const SizedBox(height: 10),
                  RowTextViewField(
                    textFieldText: "Datum narození:",
                    value: dateTimeToString(state.birthdate,),
                  ),
                  const SizedBox(height: 10),
                  ...getTitleAndTextWidgets(state.playerStats),
                  AchievementView(
                    achievementPlayerDetail: state.achievementPlayerDetail,
                  ),
                ],
              ),
            ),
          )),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ref
              .read(screenControllerProvider)
              .changeFragment(EditPlayerScreen.id),
          elevation: 4.0,
          child: const Icon(Icons.edit),
        )
    );
  }
}
