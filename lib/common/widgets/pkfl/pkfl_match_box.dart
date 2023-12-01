import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/pkfl/warning_text.dart';

import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../enabled_icon_button.dart';

class PkflMatchBox extends StatefulWidget implements PreferredSizeWidget {
  const PkflMatchBox({
    super.key,
    required this.pkflMatchFuture,
    required this.padding,
    required this.isNextMatch,
    required this.onButtonAddPlayersClick,
    required this.onButtonAddGoalsClick,
    required this.onButtonAddBeerClick,
    required this.onButtonAddFineClick,
    required this.onCommonMatchesClick,
  });

  final Future<PkflMatchApiModel?> pkflMatchFuture;
  final double padding;
  final bool isNextMatch;
  final Function(PkflMatchApiModel pkflMatchApiModel) onButtonAddPlayersClick;
  final Function(PkflMatchApiModel pkflMatchApiModel) onButtonAddGoalsClick;
  final Function(PkflMatchApiModel pkflMatchApiModel) onButtonAddBeerClick;
  final Function(PkflMatchApiModel pkflMatchApiModel) onButtonAddFineClick;
  final Function(PkflMatchApiModel pkflMatchApiModel) onCommonMatchesClick;

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  State<PkflMatchBox> createState() => _PkflMatchBoxState();
}

class _PkflMatchBoxState extends State<PkflMatchBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  String getPkflMatchText(PkflMatchApiModel? match) {
    if (match == null) {
      return "Zatím neznámý";
    }
    if (widget.isNextMatch) {
      return match.toStringForNextMatchHomeScreen();
    }
    return match.toStringForLastMatchHomeScreen();
  }

  List<WarningText> returnWarnings(PkflMatchApiModel? pkflmatch) {
    List<WarningText> texts = [];
    if(pkflmatch == null) {
      return [];
    }
    if(pkflmatch.matchIdList.isEmpty) {
      texts.add(const WarningText(text: "Je potřeba doplnit hráče!", error: true));
    }

    return texts;
  }

  bool isMatchButtonEnabled(PkflMatchApiModel? pkflmatch) {
    if(pkflmatch == null) {
      return false;
    }
    else if(pkflmatch.matchIdList.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width - widget.padding * 2;
    const double insidePadding = 3.0;
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    return FutureBuilder<PkflMatchApiModel?>(
        future: widget.pkflMatchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          var pkflMatch = snapshot.data;
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
              padding: const EdgeInsets.all(insidePadding),
              width: width,
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                    right: BorderSide(color: Colors.black54)),
              ),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                        widget.isNextMatch
                            ? "Příští zápas Trusu"
                            : "Poslední zápas Trusu",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Text(getPkflMatchText(pkflMatch),
                      textAlign: TextAlign.center,
                      key: const ValueKey('pkfl_text')),
                  ],
                ),
              )),
            ),
            pkflMatch != null ? Container(
              margin: const EdgeInsets.only(left: 5.0, right: 5.0),
              width: width,
              decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
              child: Row(
                children: [
                  SizedBox(
                    width: width / 5 - insidePadding*4/5,
                    child: DecoratedBox(
                      decoration:
                          const BoxDecoration(border: Border(
                              right: BorderSide(color: Colors.black54)),),
                      child: EnabledIconButton(
                          onPressed: () => widget.onButtonAddPlayersClick(pkflMatch), icon: const Icon(Icons.person_add), enabled: true, text: "Přidat hráče"),
                    ),
                  ),
                  SizedBox(
                    width: width / 5 - insidePadding*4/5,
                    child: DecoratedBox(
                      decoration:
                      const BoxDecoration(border: Border(
                          right: BorderSide(color: Colors.black54)),),
                      child: EnabledIconButton(
                        onPressed: () => widget.onButtonAddGoalsClick(pkflMatch), icon: const Icon(Icons.sports_soccer), enabled: isMatchButtonEnabled(pkflMatch), text: "Přidat góly"),
                    ),
                  ),
                  SizedBox(
                    width: width / 5 - insidePadding*4/5,
                    child: DecoratedBox(
                      decoration:
                      const BoxDecoration(border: Border(
                          right: BorderSide(color: Colors.black54)),),
                      child: EnabledIconButton(
                        onPressed: () => widget.onButtonAddBeerClick(pkflMatch), icon: const Icon(Icons.sports_bar), enabled: isMatchButtonEnabled(pkflMatch), text: "Přidat piva"),
                    ),
                  ),
                  SizedBox(
                    width: width / 5 - insidePadding*4/5,
                    child: EnabledIconButton(
                      onPressed: () => widget.onButtonAddFineClick(pkflMatch), icon: const Icon(Icons.savings), enabled: isMatchButtonEnabled(pkflMatch), text: "Přidat pokuty"),
                  ),
                  SizedBox(
                    width: width / 5 - insidePadding*4/5,
                    child: EnabledIconButton(
                      onPressed: () => widget.onCommonMatchesClick(pkflMatch), icon: const Icon(Icons.compare), enabled: true,text: "Vzájemné zápasy"),
                  ),
                ],
              ),
            ) : Container(),
            Container(
              margin: const EdgeInsets.only(left: 5.0, right: 5.0),
              width: width,
              decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(color: Colors.black54),
                    right: BorderSide(color: Colors.black54)),
              ),
              child: Column(
                children: returnWarnings(pkflMatch)
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 5.0, right: 5.0),
              width: width,
              decoration: returnWarnings(pkflMatch).isNotEmpty ? const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black54),
              ),
            ) : null,
        )
          ],
        );
      }
    );
  }
}
