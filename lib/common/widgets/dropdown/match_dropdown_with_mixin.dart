import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

import '../../../features/mixin/dropdown_controller_mixin.dart';
import '../../../models/api/interfaces/dropdown_item.dart';

class MatchDropdownWithMixin extends ConsumerStatefulWidget {
  final DropdownControllerMixin dropdownControllerMixin;
  final String hashKey;

  const MatchDropdownWithMixin({
    Key? key,
    required this.dropdownControllerMixin,
    required this.hashKey,
  }) : super(key: key);

  @override
  ConsumerState<MatchDropdownWithMixin> createState() =>
      _MatchDropdownWithMixinState();
}

class _MatchDropdownWithMixinState
    extends ConsumerState<MatchDropdownWithMixin> {
  List<DropdownMenuItem<MatchApiModel>> _buildMenuItems(
      List<MatchApiModel> items) {
    final List<DropdownMenuItem<MatchApiModel>> menuItems = [];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final bool isLast = i == items.length - 1;

      menuItems.add(
        DropdownMenuItem<MatchApiModel>(
          value: item,
          child: Container(
            // trochu vnitřního paddingu
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: AutoSizeText(
              item.listViewTitle(),
              maxLines: 2,
              minFontSize: 12,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DropdownItem>>(
      future: widget.dropdownControllerMixin.dropdownItemList(widget.hashKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          return Container();
        }
        List<MatchApiModel> matches = snapshot.data! as List<MatchApiModel>;

        return StreamBuilder<List<DropdownItem>>(
          stream: widget.dropdownControllerMixin
              .dropdownItemListStream(widget.hashKey),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              matches = snapshot.data! as List<MatchApiModel>;
            }

            return StreamBuilder<DropdownItem?>(
              stream:
              widget.dropdownControllerMixin.dropdownItem(widget.hashKey),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  widget.dropdownControllerMixin
                      .initDropdownItem(widget.hashKey);
                  return const Loader();
                }

                final MatchApiModel match = snapshot.data! as MatchApiModel;

                return DropdownButtonHideUnderline(
                  child: DropdownButton2<MatchApiModel>(
                    isExpanded: true,
                    value: match,
                    items: _buildMenuItems(matches),
                    selectedItemBuilder: (_) {
                      // jak vypadá vybraný text v AppBaru
                      return matches
                          .map(
                            (e) => Container(
                          key: ValueKey("match_item_${e.name}"),
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            e.listViewTitle(),
                            maxLines: 2,
                            minFontSize: 12,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                          .toList();
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      widget.dropdownControllerMixin
                          .setDropdownItem(value, widget.hashKey);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
