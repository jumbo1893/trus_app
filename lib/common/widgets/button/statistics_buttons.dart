import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/general/confirm_operations.dart';
import 'package:trus_app/features/general/crud_operations.dart';
import 'package:trus_app/models/api/interfaces/confirm_to_string.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/enum/model.dart';

import '../../../features/general/error/api_executor.dart';
import '../../../models/enum/crud.dart';
import '../../utils/utils.dart';
import '../confirmation_dialog.dart';
import '../icon_text_field.dart';

class StatisticsButtons extends StatefulWidget {
  final Function(String text) onSearchButtonClicked;
  final VoidCallback onOrderButtonClicked;
  final double padding;
  final Size size;

  const StatisticsButtons({
    Key? key,
    required this.onSearchButtonClicked,
    required this.onOrderButtonClicked,
    required this.padding,
    required this.size,
  }) : super(key: key);



  @override
  State<StatisticsButtons> createState() => _StatisticsButtonsState();
}

class _StatisticsButtonsState extends State<StatisticsButtons> {

  bool orderDescending = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> onSearchPressed() async {
     await executeApi<void>(() async {
      return await widget.onSearchButtonClicked(_searchController.text);
    },() => () {}, context, false);
  }
  //TODO návrat do menu

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: widget.size.width / 5,
            child: Center(
              child: IconButton(
                icon: (orderDescending
                    ? const Icon(Icons.arrow_upward)
                    : const Icon(Icons.arrow_downward)),
                onPressed: () {
                  setState(() {
                    orderDescending = !orderDescending;
                    widget.onOrderButtonClicked();
                  });
                },
                color: orangeColor,
              ),
            )),
        SizedBox(
            width: widget.size.width / 2.5 - widget.padding,
            child: IconTextField(
              textController: _searchController,
              labelText: "hledat",
              onIconPressed: () => onSearchPressed(),
              icon: const Icon(Icons.search, color: blackColor),
            )),
      ],
    );
  }
}
