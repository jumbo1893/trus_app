import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
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
import '../../../player/controller/player_controller.dart';
import '../../controller/fine_controller.dart';
import '../controller/fine_match_controller.dart';

class FinePlayerScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final PlayerModel? playerModel;
  final MatchModel? matchModel;
  const FinePlayerScreen({
    Key? key,
    required this.playerModel,
    required this.matchModel,
    required this.onButtonConfirmPressed,
  }) : super(key: key);

  @override
  ConsumerState<FinePlayerScreen> createState() => _FinePlayerScreenState();
}

class _FinePlayerScreenState extends ConsumerState<FinePlayerScreen> {
  MatchModel? selectedValue;
  List<FineMatchHelperModel> fines = [];
  List<int> finesNumber = [];

  void changeFines() {
    print(finesNumber);
    for (int i = 0; i < finesNumber.length; i++) {
      if (finesNumber[i] != -1) {
        addFine(fines[i].id, fines[i].fine.id, finesNumber[i]);
      }
    }
    widget.onButtonConfirmPressed.call();
  }

  Future<void> addFine(String id, String fineId, int number) async {
    if (await ref.read(fineMatchControllerProvider).addFineInMatch(context, id,
        widget.matchModel!.id, widget.playerModel!.id, fineId, number)) {
    }
  }

  void setNewFinesNumber(int length) {
    finesNumber.clear();
    for (int i = 0; i < length; i++) {
      finesNumber.add(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: StreamBuilder<List<FineMatchHelperModel>>(
          stream: ref
              .watch(fineMatchControllerProvider)
              .finesInMatchesByMatchAndPlayer(
                  widget.playerModel!.id, widget.matchModel!.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            fines = snapshot.data!;
            setNewFinesNumber(snapshot.data!.length);
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var fineMatch = snapshot.data![index];
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
