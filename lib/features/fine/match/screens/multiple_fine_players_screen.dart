import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/listview/listview_add_model.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/dropdown/match_dropdown.dart';
import 'package:trus_app/features/match/controller/match_controller.dart';
import 'package:trus_app/features/player/utils.dart';
import 'package:trus_app/models/helper/fine_match_helper_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../../common/widgets/custom_button.dart';
import '../../../../models/fine_model.dart';
import '../../../../models/player_model.dart';
import '../../../notification/controller/notification_controller.dart';
import '../../../player/controller/player_controller.dart';
import '../../controller/fine_controller.dart';
import '../controller/fine_match_controller.dart';

class MultipleFinePlayersScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final List<PlayerModel> players;
  final MatchModel match;
  const MultipleFinePlayersScreen({
    Key? key,
    required this.players,
    required this.match,
    required this.onButtonConfirmPressed,
  }) : super(key: key);

  @override
  ConsumerState<MultipleFinePlayersScreen> createState() => _FinePlayersScreenState();
}

class _FinePlayersScreenState extends ConsumerState<MultipleFinePlayersScreen> {
  List<FineMatchHelperModel> fines = [];
  List<int> finesNumber = [];

  void changeFines() async {
    showLoaderSnackBar(context: context);
    String text = "";
    String players = "";
    for(int j = 0; j < widget.players.length; j++) {
      players += "${widget.players[j].name}, ";
      for (int i = 0; i < finesNumber.length; i++) {
        if (finesNumber[i] != 0) {
          addFine(fines[i].fine.id, widget.players[j].id, finesNumber[i]);
          if(j==0) {
            text += "${fines[i].fine.name} ==> ${finesNumber[i]}\n";
          }
        }
      }
    }
    await sendNotification(players, text);
    hideSnackBar(context);
    showSnackBar(context: context, content: "pokuty u ${widget.players.length} hráčů změněny");
    widget.onButtonConfirmPressed.call();
  }

  Future<void> addFine(String fineId, String playerId, int number) async {
    if (await ref.read(fineMatchControllerProvider).addMultipleFinesInMatch(context,
        widget.match.id, playerId, fineId, number)) {
    }
  }

  Future<void> sendNotification(String players, String text) async {
    if(text.isNotEmpty) {
      String title = "Hromadná změna pokut v zápase ${widget.match
          .toStringWithOpponentName()} u hráčů ${players.substring(0, players.length-2)}";
      await ref.read(notificationControllerProvider).addNotification(
          context, title, text);
    }
  }


  void setNewFinesNumber(int length) {
    finesNumber.clear();
    for (int i = 0; i < length; i++) {
      finesNumber.add(0);
    }
  }

  List<FineMatchHelperModel> setFinesHelpers(List<FineModel> fines) {
    List<FineMatchHelperModel> returnList = [];
    for(FineModel fineModel in fines) {
      returnList.add(FineMatchHelperModel(id: "dummy", fine: fineModel, number: 0));
    }
  return returnList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: StreamBuilder<List<FineModel>>(
          stream: ref
              .watch(fineMatchControllerProvider)
              .fines(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            fines = setFinesHelpers(snapshot.data!);
            setNewFinesNumber(snapshot.data!.length);
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var fineMatch = fines[index];
                      return Column(
                        children: [
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 8.0, left: 8, right: 8),
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.grey,
                                ))),
                                child: ListviewAddModel(
                                  onNumberChanged: (number) {
                                    finesNumber[index] = number;
                                  },
                                  padding: 16,
                                  helperModel: fineMatch,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CustomButton(text: "Přidej pokuty", onPressed: changeFines),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
