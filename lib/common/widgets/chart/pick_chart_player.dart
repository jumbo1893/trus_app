import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/home/widget/i_chart_picked_player_callback.dart';
import 'package:trus_app/features/mixin/chart_controller_mixin.dart';

import '../../../models/api/home/chart.dart';
import '../dropdown/player_api_dropdown.dart';
import '../loader.dart';


class PickChartPlayer extends StatefulWidget {
  final Size size;
  final double padding;
  final IChartPickedPlayerCallback iChartPickedPlayerCallback;
  final ChartControllerMixin chartControllerMixin;
  final String hashKey;

  const PickChartPlayer({
    Key? key,
    required this.size,
    required this.padding,
    required this.iChartPickedPlayerCallback,
    required this.chartControllerMixin,
    required this.hashKey,
  }) : super(key: key);

  @override
  State<PickChartPlayer> createState() => _PickChartPlayerState();
}

class _PickChartPlayerState extends State<PickChartPlayer> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Chart?>(
        stream: widget.chartControllerMixin.chartValue(widget.hashKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          Chart? chart = snapshot.data;
          if(chart == null || chart.coordinates.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(3.0),
              width: widget.size.width - widget.padding * 2,
              child: Center(
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning, color: orangeColor, size: 40,
                          ),
                          Flexible(
                            child: Text(
                              "Pro zobrazení svého grafu vyber hráče/fanouška pod kterým piješ. Do té doby zde budeš mít graf největších borců",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      PlayerApiDropdown(
                        getPlayers: widget.iChartPickedPlayerCallback
                            .getPlayers(),
                        onPlayerSelected: (player) =>
                            widget.iChartPickedPlayerCallback.onPlayerPicked(
                                player),

                      )
                    ],
                  )
              ),
            );
          }
          return Container();
      }
    );
  }
}
