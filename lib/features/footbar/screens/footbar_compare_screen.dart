import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/dropdown/custom_dropdown_with_mixin.dart';
import 'package:trus_app/common/widgets/dropdown/match_dropdown_with_mixin.dart';
import 'package:trus_app/common/widgets/footbar_compare.dart';
import 'package:trus_app/features/footbar/controller/footbar_compare_controller.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../main/screen_controller.dart';

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
    var controller = ref.watch(footbarCompareControllerProvider);
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(FootbarCompareScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 0.0;
      return Scaffold(
          body: FutureBuilder<void>(
            future: controller.initFootbarCompare(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                        () => showErrorDialog(snapshot, () {
                      ref
                          .read(screenControllerProvider)
                          .changeFragment(HomeScreen.id);
                    }, context));
                return const Loader();
              }
              return FutureBuilder<void>(
                  future: controller.loadFootbalCompare(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print("mám error");
                      Future.delayed(
                          Duration.zero,
                              () =>
                              showErrorDialog(
                                  snapshot,
                                      () =>
                                      ref
                                          .read(screenControllerProvider)
                                          .changeFragment(HomeScreen.id),
                                  context));
                      return const Loader();
                    }
                    return Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                        title: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: size.width),
                            child: MatchDropdownWithMixin(
                              hashKey: controller.matchKey,
                              dropdownControllerMixin: controller,
                            )),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(padding),
                        child: Column(children: [
                          SizedBox(
                              width: size.width / 2 - padding,
                              child: CustomDropdownWithMixin(
                                hashKey: controller.seasonKey,
                                dropdownControllerMixin: controller,
                                hint: "Vyber sezonu",
                              )),
                          Expanded(
                            child: FootbarCompare(
                                footbarCompareControllerMixin: controller,
                                hashKey: controller.footbarAccountListKey),
                          )
                        ]),
                      ),
                    );
                  });
            }
          )
          );
    } else {
      return Container();
    }
  }
}
