import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/statistics/stat_args.dart';

import '../../../features/general/error/api_executor.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/main/screen_controller.dart';
import '../../../features/statistics/controller/stats_notifier.dart';
import '../../../features/statistics/state/stats_state.dart';
import '../icon_text_field.dart';

class StatisticsButtons extends ConsumerStatefulWidget {
  final Function(String text) onSearchButtonClicked;
  final VoidCallback onOrderButtonClicked;
  final double padding;
  final Size size;
  final StatsArgs statsArgs;

  const StatisticsButtons({
    Key? key,
    required this.onSearchButtonClicked,
    required this.onOrderButtonClicked,
    required this.padding,
    required this.size,
    required this.statsArgs,
  }) : super(key: key);



  @override
  ConsumerState<StatisticsButtons> createState() => _StatisticsButtonsState();
}

class _StatisticsButtonsState extends ConsumerState<StatisticsButtons> {
  bool orderDescending = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> onSearchPressed() async {
    await executeApi<void>(
          () async => widget.onSearchButtonClicked(_searchController.text),
          () => ref
          .read(screenControllerProvider)
          .changeFragment(HomeScreen.id),
      context,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StatsState>(statsNotifierProvider(widget.statsArgs), (_, next) {
      if (next.filter == "" && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
      else if(next.filter != null) {
        _searchController.text = next.filter!;
      }
    });

    return Row(
      children: [
        SizedBox(
          width: widget.size.width / 5,
          child: Center(
            child: IconButton(
              icon: orderDescending
                  ? const Icon(Icons.arrow_upward)
                  : const Icon(Icons.arrow_downward),
              onPressed: () {
                setState(() {
                  orderDescending = !orderDescending;
                });
                widget.onOrderButtonClicked();
              },
              color: orangeColor,
            ),
          ),
        ),
        SizedBox(
          width: widget.size.width / 2.5 - widget.padding,
          child: IconTextField(
            textController: _searchController,
            labelText: "hledat",
            onIconPressed: () => {onSearchPressed(), /*_searchController.clear()*/},
            icon: const Icon(Icons.search, color: blackColor),
          ),
        ),
      ],
    );
  }
}

