import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../../../../colors.dart';
import '../../../../models/api/player_api_model.dart';
import '../../../static_text.dart';
import '../../custom_text.dart';
import '../../custom_text_field.dart';
import '../../dropdown/player_dropdown_multiselect.dart';
import '../../loader.dart';

class RowPlayerListStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String textFieldText;
  final Future<List<PlayerApiModel>> playerList;
  final VoidCallback initData;
  final Stream<List<PlayerApiModel>> checkedPlayerList;
  final Stream<String>? errorTextStream;
  final Function(List<PlayerApiModel>) onPlayersChanged;
  const RowPlayerListStream({
    Key? key,
    required this.size,
    required this.padding,
    required this.textFieldText,
    required this.playerList,
    required this.initData,
    required this.checkedPlayerList,
    required this.onPlayersChanged,
    this.errorTextStream,
  }) : super(key: key);

  @override
  State<RowPlayerListStream> createState() => _RowPlayerListStream();
}

class _RowPlayerListStream extends State<RowPlayerListStream> {
  List<PlayerApiModel> convertNullablePlayerList(
      List<PlayerApiModel?> players) {
    List<PlayerApiModel> playerList = [];
    for (PlayerApiModel? player in players) {
      if (player != null) {
        playerList.add(player);
      }
    }
    return playerList;
  }

  final _formKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: (widget.size.width / 3) - widget.padding,
            child: CustomText(text: widget.textFieldText)),
        SizedBox(
            width: (widget.size.width / 1.5) - widget.padding,
            child: FutureBuilder<List<PlayerApiModel>>(
                future: widget.playerList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  } else if (snapshot.hasError) {
                    return Container();
                  }
                  List<PlayerApiModel> players = snapshot.data!;
                  return StreamBuilder<List<PlayerApiModel>>(
                      stream: widget.checkedPlayerList,
                      builder: (context, checkedSnapshot) {
                        if (checkedSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          widget.initData();
                          return const Loader();
                        }
                        List<PlayerApiModel?> checkedPlayers =
                            checkedSnapshot.data!;
                        return StreamBuilder<String>(
                            stream: widget.errorTextStream,
                            builder: (context, errorSnapshot) {
                              if (errorSnapshot.hasData) {
                                _formKey.currentState!.validate();
                              }
                              return MultiSelectChipField(
                                items: players
                                    .map((e) =>
                                        MultiSelectItem<PlayerApiModel?>(
                                            e, e.name))
                                    .toList(),
                                selectedChipColor: orangeColor,
                                key: _formKey,
                                initialValue: checkedPlayers,
                                onTap: (List<PlayerApiModel?> values) {
                                  widget.onPlayersChanged(
                                      convertNullablePlayerList(values));
                                },
                                showHeader: false,
                                validator: (values) {
                                  if (values == null || values.isEmpty) {
                                    return errorSnapshot.data ?? atLeastOnePlayerMustBePresentValidation;
                                  }
                                  return null;
                                },
                                scroll: true,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1, color: orangeColor))),
                              );
                            });
                      });
                })),
      ],
    );
  }
}
