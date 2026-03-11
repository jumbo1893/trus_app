import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/footbar_compare.dart';

import '../../../common/widgets/dropdown/match_dropdown_notifier.dart';
import '../../../common/widgets/notifier/dropdown/custom_dropdown.dart';
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
  ConsumerState<FootbarCompareScreen> createState() => _FootbarCompareScreenState();
}

class _FootbarCompareScreenState extends ConsumerState<FootbarCompareScreen> {
  @override
  Widget build(BuildContext context) {
    var notifier = ref.watch(footbarCompareNotifierProvider.notifier);
    var state = ref.watch(footbarCompareNotifierProvider);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: state.matches.when(
            loading: () => const SizedBox(height: 24),
            error: (_, __) => const SizedBox.shrink(),
            data: (matches) => ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: MatchDropdownNotifier(
                matches: matches,
                selected: state.selectedMatch,
                onSelected: notifier.selectMatch,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: CustomDropdown(
                    hint: "Vyber sezonu",
                    notifier: ref.read(
                      seasonDropdownNotifierProvider(const SeasonArgs(false, true, true)).notifier,
                    ),
                    state: ref.watch(
                      seasonDropdownNotifierProvider(const SeasonArgs(false, true, true)),
                    ),
                  ),
                ),
              ],
            ),
            const Expanded(
              child: FootbarCompare(
                  ),
            )
          ],
        ));
  }
}
