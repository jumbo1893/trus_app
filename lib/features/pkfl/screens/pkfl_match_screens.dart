import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/features/pkfl/controller/pkfl_controller.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_matches_task.dart';
import 'package:trus_app/features/pkfl/utils.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../common/widgets/dropdown/season_dropdown.dart';

class PkflMatchScreen extends ConsumerStatefulWidget {

  const PkflMatchScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PkflMatchScreen> createState() => _PkflMatchScreenState();
}

class _PkflMatchScreenState extends ConsumerState<PkflMatchScreen> {



  Future<List<PkflMatch>> getPkflMatches() async {
    String url = "";
    List<PkflMatch> matches = [];
    await ref.read(pkflControllerProvider).url().then((value) => url = value);
    RetrieveMatchesTask matchesTask = RetrieveMatchesTask(url);
    try {
      await matchesTask.returnPkflMatches().then((value) => matches = value);
    }
    catch (e, stacktrace) {
      print(stacktrace);
      showSnackBar(context: context, content: e.toString());
    }
    return matches;
  }
  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(padding),
          child: FutureBuilder<List<PkflMatch>>(
              future: getPkflMatches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                sortMatchesByDate(snapshot.data!, false);
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var match = snapshot.data![index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                              color: Colors.grey,
                            ))),
                            child: ListTile(
                              title: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: padding*2),
                                child: Text(
                                  match.toStringNameWithOpponent(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              subtitle: Text(
                                match.toStringForSubtitle(),
                                style: const TextStyle(
                                    color: listviewSubtitleColor),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              }),
        ),
       );
  }
}
