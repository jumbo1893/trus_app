import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';

import '../../../common/widgets/custom_text.dart';
import '../../home/screens/home_screen.dart';
import '../../main/screen_controller.dart';
import '../../match/controller/match_controller.dart';

class PkflMatchDetailScreen extends ConsumerStatefulWidget {
  final bool isFocused;

  const PkflMatchDetailScreen({
    required this.isFocused,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PkflMatchDetailScreen> createState() =>
      _PkflMatchDetailScreenState();
}

class _PkflMatchDetailScreenState extends ConsumerState<PkflMatchDetailScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      return Scaffold(
        body: FutureBuilder<PkflMatchApiModel>(
            future: ref.watch(matchControllerProvider).returnPkflMatch(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(
                        snapshot.error!.toString(),
                        () => ref
                            .read(screenControllerProvider)
                            .changeFragment(HomeScreen.id),
                        context));
                return const Loader();
              }
              PkflMatchApiModel pkflMatch = snapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Center(
                          child: CustomText(
                        text: "\n${pkflMatch.toStringNameWithOpponent()}\n",
                        fontSize: 20,
                      )),
                      CustomText(text: pkflMatch.returnFirstDetailsOfMatch()),
                      CustomText(text: pkflMatch.returnSecondDetailsOfMatch()),
                    ],
                  ),
                ),
              );
            }),
      );
    } else {
      return Container();
    }
  }
}
