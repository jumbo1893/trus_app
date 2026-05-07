import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/footbar_compare.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../../common/widgets/dropdown/match_dropdown_sheet.dart';
import '../../../common/widgets/rows/form/form_card.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';
import '../controller/footbar_compare_notifier.dart';

class FootbarCompareScreen extends CustomConsumerStatefulWidget {
  static const String id = "footbar-compare-screen";

  const FootbarCompareScreen({
    Key? key,
  }) : super(key: key, title: "Footbar stats", name: id);

  @override
  ConsumerState<FootbarCompareScreen> createState() =>
      _FootbarCompareScreenState();
}

class _FootbarCompareScreenState extends ConsumerState<FootbarCompareScreen> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(footbarCompareNotifierProvider.notifier);
    final state = ref.watch(footbarCompareNotifierProvider);

    final seasonProvider =
    seasonDropdownNotifierProvider(const SeasonArgs(false, true, true));

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AppWidgetValues.field,
              FormCard(
                children: [
                  state.matches.when(
                    loading: () => const SizedBox(height: 48),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (matches) => MatchDropdownSheet(
                      hint: "Vyber zápas",
                      matches: matches,
                      selected: state.selectedMatch,
                      onSelected: notifier.selectMatch,
                    ),
                  ),
                  CustomDropdownSheet(
                    hint: "Vyber sezonu",
                    notifier: ref.read(seasonProvider.notifier),
                    state: ref.watch(seasonProvider),
                  ),
                ],
              ),
              AppWidgetValues.field,
              const Expanded(
                child: FootbarCompare(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}