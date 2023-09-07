import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/pkfl/utils.dart';
import 'package:trus_app/models/pkfl/pkfl_team.dart';

import '../controller/pkfl_table_controller.dart';

class PkflTableScreen extends ConsumerStatefulWidget {
  const PkflTableScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PkflTableScreen> createState() => _PkflTableScreenState();
}

class _PkflTableScreenState extends ConsumerState<PkflTableScreen> {

  @override
  Widget build(BuildContext context) {
    ref.watch(pkflTableControllerProvider).snackBar().listen((event) {
      showSnackBarWithPostFrame(context: context, content: event);
    });
    const double padding = 8.0;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: FutureBuilder<List<PkflTeam>>(
            future: ref.read(pkflTableControllerProvider).getPkflTeams(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              sortMatchesByPoints(snapshot.data!);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var team = snapshot.data![index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {

                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                  ))),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: padding * 2),
                              child: Text(
                                team.toStringForTitle(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                            subtitle: Text(
                              team.toStringForSubtitle(),
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
