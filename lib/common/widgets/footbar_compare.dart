import 'package:flutter/material.dart';
import 'package:trus_app/features/mixin/footbar_compare_controller_mixin.dart';
import 'package:trus_app/models/api/footbar/footbar_account_sessions.dart';
import 'package:trus_app/models/api/footbar/footbar_session.dart';

class FootbarCompare extends StatefulWidget {
  final FootbarCompareControllerMixin footbarCompareControllerMixin;
  final String hashKey;

  const FootbarCompare({
    Key? key,
    required this.footbarCompareControllerMixin,
    required this.hashKey,
  }) : super(key: key);

  @override
  State<FootbarCompare> createState() => _FootbarCompareState();
}

class _FootbarCompareState extends State<FootbarCompare> {
  int? _selectedLeftId;
  int? _selectedRightId;

  FootbarAccountSessions? _findById(
      List<FootbarAccountSessions> list,
      int? id,
      ) {
    if (id == null) return null;
    for (final item in list) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FootbarAccountSessions>>(
      stream: widget.footbarCompareControllerMixin.viewValue(widget.hashKey),
      initialData:
      widget.footbarCompareControllerMixin.viewValues[widget.hashKey],
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
              child: Text("K tomuto zápasu neexistují záznamy"));
        }

        final accountSessionList = snapshot.data!;

        if (accountSessionList.isEmpty) {
          return const Center(
              child: Text("K tomuto zápasu neexistují záznamy"));
        }

        // --- vybrané položky (inicializace / korekce) ---
        // levý – primaryUser, jinak první
        FootbarAccountSessions? left =
        _findById(accountSessionList, _selectedLeftId);

        if (left == null) {
          left = accountSessionList.firstWhere(
                (a) => a.primaryUser,
            orElse: () => accountSessionList.first,
          );
          _selectedLeftId = left.id;
        }

        // pravý – někdo jiný, jinak klidně stejný
        FootbarAccountSessions? right =
        _findById(accountSessionList, _selectedRightId);

        if (right == null) {
          right = accountSessionList.firstWhere(
                (a) => a.id != left!.id,
            orElse: () => left!,
          );
          _selectedRightId = right.id;
        }

        // sessions pro porovnání – beru první session z listu
        FootbarSession? leftSession =
        left.sessions.isNotEmpty ? left.sessions.first : null;
        FootbarSession? rightSession =
        right.sessions.isNotEmpty ? right.sessions.first : null;

        return Column(
          children: [
            // dropdowny nahoře
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedLeftId,
                      items: accountSessionList
                          .map(
                            (acc) => DropdownMenuItem<int>(
                          value: acc.id,
                          child: Text(acc.listViewTitle()),
                        ),
                      )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedLeftId = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedRightId,
                      items: accountSessionList
                          .map(
                            (acc) => DropdownMenuItem<int>(
                          value: acc.id,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(acc.listViewTitle()),
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedRightId = value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // porovnání statistik
            Expanded(
              child: _buildStatsComparison(context, leftSession, rightSession),
            ),
            const SizedBox(height: 30),
          ],
        );
      },
    );
  }

  // pomocný getter na label – vezme z left, když není, z right
  String _label(
      FootbarSession? left,
      FootbarSession? right,
      String Function(FootbarSession) getter,
      String fallback,
      ) {
    if (left != null) return getter(left);
    if (right != null) return getter(right);
    return fallback;
  }

  Widget _buildStatsComparison(
      BuildContext context,
      FootbarSession? left,
      FootbarSession? right,
      ) {
    final rows = <Widget>[
      // position (text)
      _buildTextStatRow(
        label: _label(left, right, (s) => s.positionString(), "Pozice"),
        leftText: left?.positionValueString() ?? "N/A",
        rightText: right?.positionValueString() ?? "N/A",
      ),

      // playingTime
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.playingTimeString(), "Hrací doba"),
        leftNum: left?.playingTime,
        rightNum: right?.playingTime,
        leftText: left?.playingTimeValueString() ?? "N/A",
        rightText: right?.playingTimeValueString() ?? "N/A",
      ),

      // scoreStars
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.scoreStarsString(),
            "Footbar hodnocení"),
        leftNum: left?.scoreStars,
        rightNum: right?.scoreStars,
        leftText: left?.scoreStarsValueString() ?? "N/A",
        rightText: right?.scoreStarsValueString() ?? "N/A",
      ),

      // distance
      _buildNumericStatRow(
        label:
        _label(left, right, (s) => s.distanceString(), "Vzdálenost"),
        leftNum: left?.distance,
        rightNum: right?.distance,
        leftText: left?.distanceValueString() ?? "N/A",
        rightText: right?.distanceValueString() ?? "N/A",
      ),

      // passCount
      _buildNumericStatRow(
        label: _label(
            left, right, (s) => s.passCountString(), "Počet přihrávek"),
        leftNum: left?.passCount,
        rightNum: right?.passCount,
        leftText: left?.passCountValueString() ?? "N/A",
        rightText: right?.passCountValueString() ?? "N/A",
      ),

      // shotCount
      _buildNumericStatRow(
        label:
        _label(left, right, (s) => s.shotCountString(), "Počet střel"),
        leftNum: left?.shotCount,
        rightNum: right?.shotCount,
        leftText: left?.shotCountValueString() ?? "N/A",
        rightText: right?.shotCountValueString() ?? "N/A",
      ),

      // shotSpeed
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.shotSpeedString(),
            "Rychlost střely"),
        leftNum: left?.shotSpeed,
        rightNum: right?.shotSpeed,
        leftText: left?.shotSpeedValueString() ?? "N/A",
        rightText: right?.shotSpeedValueString() ?? "N/A",
      ),

      // avgShotSpeed
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.avgShotSpeedString(),
            "Průměrná rychlost střely"),
        leftNum: left?.avgShotSpeed,
        rightNum: right?.avgShotSpeed,
        leftText: left?.avgShotSpeedValueString() ?? "N/A",
        rightText: right?.avgShotSpeedValueString() ?? "N/A",
      ),

      // dribbleCount
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.dribbleCountString(),
            "Počet driblinků"),
        leftNum: left?.dribbleCount,
        rightNum: right?.dribbleCount,
        leftText: left?.dribbleCountValueString() ?? "N/A",
        rightText: right?.dribbleCountValueString() ?? "N/A",
      ),

      // timeWithBall
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.timeWithBallString(),
            "Čas s míčem"),
        leftNum: left?.timeWithBall,
        rightNum: right?.timeWithBall,
        leftText: left?.timeWithBallValueString() ?? "N/A",
        rightText: right?.timeWithBallValueString() ?? "N/A",
      ),

      // activity
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.activityString(), "Aktivní čas"),
        leftNum: left?.activity,
        rightNum: right?.activity,
        leftText: left?.activityValueString() ?? "N/A",
        rightText: right?.activityValueString() ?? "N/A",
      ),

      // timeRunning
      _buildNumericStatRow(
        label:
        _label(left, right, (s) => s.timeRunningString(), "Čas v běhu"),
        leftNum: left?.timeRunning,
        rightNum: right?.timeRunning,
        leftText: left?.timeRunningValueString() ?? "N/A",
        rightText: right?.timeRunningValueString() ?? "N/A",
      ),

      // runCount
      _buildNumericStatRow(
        label:
        _label(left, right, (s) => s.runCountString(), "Počet běhů"),
        leftNum: left?.runCount,
        rightNum: right?.runCount,
        leftText: left?.runCountValueString() ?? "N/A",
        rightText: right?.runCountValueString() ?? "N/A",
      ),

      // sprintCount
      _buildNumericStatRow(
        label: _label(
            left, right, (s) => s.sprintCountString(), "Počet sprintů"),
        leftNum: left?.sprintCount,
        rightNum: right?.sprintCount,
        leftText: left?.sprintCountValueString() ?? "N/A",
        rightText: right?.sprintCountValueString() ?? "N/A",
      ),

      // avgSprintSpeed
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.avgSprintSpeedString(),
            "Průměrná rychlost sprintu"),
        leftNum: left?.avgSprintSpeed,
        rightNum: right?.avgSprintSpeed,
        leftText: left?.avgSprintSpeedValueString() ?? "N/A",
        rightText: right?.avgSprintSpeedValueString() ?? "N/A",
      ),

      // sprintSpeed
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.sprintSpeedString(), "Max sprint"),
        leftNum: left?.sprintSpeed,
        rightNum: right?.sprintSpeed,
        leftText: left?.sprintSpeedValueString() ?? "N/A",
        rightText: right?.sprintSpeedValueString() ?? "N/A",
      ),

      // sprintDistance
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.sprintDistanceString(),
            "Usprintovaná vzdálenost"),
        leftNum: left?.sprintDistance,
        rightNum: right?.sprintDistance,
        leftText: left?.sprintDistanceValueString() ?? "N/A",
        rightText: right?.sprintDistanceValueString() ?? "N/A",
      ),

      // stopAndGo
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.stopAndGoString(),
            "Index intenzity"),
        leftNum: left?.stopAndGo,
        rightNum: right?.stopAndGo,
        leftText: left?.stopAndGoValueString() ?? "N/A",
        rightText: right?.stopAndGoValueString() ?? "N/A",
      ),

      // acceleration
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.accelerationString(),
            "Index zrychlení"),
        leftNum: left?.acceleration,
        rightNum: right?.acceleration,
        leftText: left?.accelerationValueString() ?? "N/A",
        rightText: right?.accelerationValueString() ?? "N/A",
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(children: rows),
    );
  }

  // ----- řádky -----

  Widget _buildTextStatRow({
    required String label,
    required String leftText,
    required String rightText,
  }) {
    return _buildCenterRow(
      label: label,
      leftText: leftText,
      rightText: rightText,
      leftStyle: const TextStyle(),
      rightStyle: const TextStyle(),
    );
  }

  Widget _buildNumericStatRow({
    required String label,
    required num? leftNum,
    required num? rightNum,
    required String leftText,
    required String rightText,
  }) {
    bool leftBold = false;
    bool rightBold = false;

    if (leftNum != null && rightNum != null) {
      if (leftNum > rightNum) leftBold = true;
      if (rightNum > leftNum) rightBold = true;
    } else if (leftNum != null) {
      leftBold = true;
    } else if (rightNum != null) {
      rightBold = true;
    }

    return _buildCenterRow(
      label: label,
      leftText: leftText,
      rightText: rightText,
      leftStyle:
      TextStyle(fontWeight: leftBold ? FontWeight.bold : FontWeight.normal),
      rightStyle: TextStyle(
          fontWeight: rightBold ? FontWeight.bold : FontWeight.normal),
    );
  }

  // společné vykreslení: hodnota vlevo / label / hodnota vpravo
  Widget _buildCenterRow({
    required String label,
    required String leftText,
    required String rightText,
    required TextStyle leftStyle,
    required TextStyle rightStyle,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              // LEFT value
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(leftText, style: leftStyle),
                  ),
                ),
              ),

              // CENTER LABEL – pevná šířka pro perfektní centrování
              SizedBox(
                width: 150,
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // RIGHT value
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(rightText, style: rightStyle),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Divider přes celou šířku
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

}
