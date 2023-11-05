import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import '../../../features/general/match_reader.dart';
import '../../repository/exception/loading_exception.dart';
import '../../utils/utils.dart';

class MatchDropdown extends ConsumerStatefulWidget {
  final Function(MatchApiModel matchModel) onMatchSelected;
  final MatchReader matchReader;
  final VoidCallback? initMatchListStream;
  final Stream<List<MatchApiModel>>? matchesStream;
  const MatchDropdown({
    Key? key,
    required this.onMatchSelected,
    required this.matchesStream,
    required this.initMatchListStream,
    required this.matchReader,
  }) : super(key: key);

  @override
  ConsumerState<MatchDropdown> createState() => _MatchDropdownState();
}

class _MatchDropdownState extends ConsumerState<MatchDropdown> {

  List<DropdownMenuItem<MatchApiModel>> _addDividersAfterItems(List<MatchApiModel> items) {
    List<DropdownMenuItem<MatchApiModel>> menuItems = [];
    for (var item in items) {
      Widget divider;
      if (item != items.last) {
        divider = const Divider();
      }
      else {
        divider = const Divider(color: Colors.white,);
      }
      menuItems.addAll(
        [
          DropdownMenuItem<MatchApiModel>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,),
              child: Column(
                children: [
                  Text(
                    item.listViewTitle(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  divider,
                ],
              ),
            ),
          ),
        ],
      );
    }
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
          return StreamBuilder<List<MatchApiModel>>(
              stream: widget.matchesStream,
              builder: (context, streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  widget.initMatchListStream!();
                  return const Loader();
                }
                if (streamSnapshot.hasError) {
                  if(streamSnapshot.error is LoadingException) {
                    return const Loader();
                  }
                  Future.delayed(Duration.zero, () => showErrorDialog(streamSnapshot.error!.toString(), () => {}, context));
                  return const Loader();
                }
                List<MatchApiModel> matches = streamSnapshot.data!;
                return DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    selectedItemBuilder: (_) {
                      return matches
                          .map((e) =>
                          Container(
                            key: ValueKey("match_item_${e.name}"),
                            alignment: Alignment.center,
                            child: Text(
                              e.listViewTitle(),
                              style: const TextStyle(
                                color: Colors.white, fontSize: 20,),
                            ),
                          ))
                          .toList();
                    },
                    isExpanded: true,
                    items: _addDividersAfterItems(matches),
                    value: widget.matchReader.getMatch(),
                    onChanged: (value) {
                      setState(() {
                        widget.onMatchSelected(value as MatchApiModel);
                      });
                    },
                  ),
                );
              }
          );
        }
}
