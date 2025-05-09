import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/strava/controller/strava_controller.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widgets/builder/models_error_future_builder.dart';
import '../../../common/widgets/dropdown/custom_dropdown.dart';
import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../main/screen_controller.dart';

class StravaFootballMatchScreen extends CustomConsumerWidget {
  static const String id = "strava-football-match-screen";


  StravaFootballMatchScreen({
    Key? key,
  }) : super(key: key, title: "Strava stats v zápase", name: id);

  final matchLoadingProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = stravaControllerProvider;
    final isLoading = ref.watch(matchLoadingProvider);
    if (ref.read(screenControllerProvider).isScreenFocused(StravaFootballMatchScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 8.0;
      return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(padding),
            child: SingleChildScrollView(
              key: const ValueKey('match_screen'),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                          width: size.width / 2 - padding,
                          child: CustomDropdown(
                            key: const ValueKey('match_dropdown'),
                            onItemSelected: (match) => ref
                                .watch(provider)
                                .setPickedMatch(match as MatchApiModel),
                            dropdownList: ref
                                .watch(provider)
                                .getMatches(),
                            pickedItem: ref
                                .watch(provider)
                                .pickedMatch(),
                            initData: () => ref
                                .watch(provider)
                                .setCurrentMatch(),
                            hint: 'Vyber sezonu',
                          )),
                    ],
                  ),
                  ModelsErrorFutureBuilder(
                    key: const ValueKey('match_list'),
                    future:
                        ref.watch(provider).getModels(),
                    rebuildStream: ref
                        .watch(provider)
                        .streamAthleteActivities(),
                    onPressed: (match) => {

                    },
                    context: context,
                    scrollable: false,
                  ),
                ],
              ),
            ),
          ),
        floatingActionButton: isLoading
            ? const FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.grey,
          child: Loader(),
        )
            :
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  key: const ValueKey('sync_floating_button'),
                  onPressed: () async {
                    final loading = ref.read(matchLoadingProvider.notifier);
                    loading.state = true;
                    try {
                      await ref.read(provider).syncMatches();
                    } finally {
                      loading.state = false;
                    }
                  },
                  child: const Icon(Icons.refresh),
                ),
                FloatingActionButton(
                  key: const ValueKey('connect_strava_button'),
                  onPressed: () async {
                    try {
                      final url = await ref.read(provider).getUrlStravaConnection();
                      final uri = Uri.parse(url);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      debugPrint("Chyba při otevírání odkazu: $e");
                    }
                  },
                  child: const Icon(Icons.login),
                ),
              ],
            )
         );
    } else {
      return Container();
    }
  }
}
