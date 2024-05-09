import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import '../../models/api/player_api_model.dart';
import 'dropdown/player_api_dropdown.dart';


class PickChartPlayer extends StatefulWidget {
  final Size size;
  final double padding;
  final Function(PlayerApiModel player) onPlayerSelected;

  const PickChartPlayer({
    Key? key,
    required this.size,
    required this.padding,
    required this.onPlayerSelected,
  }) : super(key: key);



  @override
  State<PickChartPlayer> createState() => _PickChartPlayerState();
}

class _PickChartPlayerState extends State<PickChartPlayer> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      width: widget.size.width - widget.padding * 2,
      child: Center(
        child: Column(
          children: [
            Row(
              children: const [
                Icon(
                  Icons.warning, color: orangeColor, size: 40,
                ),
                Flexible(
                  child: Text("Pro zobrazení svého grafu vyber hráče/fanouška pod kterým piješ. Do té doby zde budeš mít graf největších borců",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            PlayerApiDropdown(
              onPlayerSelected: (player) => widget.onPlayerSelected(player) ,

            )
          ],
        )
          ),
    );
  }
}
