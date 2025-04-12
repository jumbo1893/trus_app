import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:trus_app/features/mixin/checked_list_controller_mixin.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../../colors.dart';
import '../../../static_text.dart';
import '../../custom_text.dart';
import '../../loader.dart';

class RowCheckedListStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String textFieldText;
  final String defaultErrorText;
  final CheckedListControllerMixin checkedListControllerMixin;
  final String hashKey;

  const RowCheckedListStream({
    Key? key,
    required this.size,
    required this.padding,
    required this.textFieldText,
    required this.defaultErrorText,
    required this.checkedListControllerMixin,
    required this.hashKey,
  }) : super(key: key);

  @override
  State<RowCheckedListStream> createState() => _RowCheckedListStream();
}

class _RowCheckedListStream extends State<RowCheckedListStream> {
  List<ModelToString> convertNullableModelList(List<ModelToString?> models) {
    List<ModelToString> modelList = [];
    for (ModelToString? model in models) {
      if (model != null) {
        modelList.add(model);
      }
    }
    return modelList;
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
            child: FutureBuilder<List<ModelToString>>(
                future: widget.checkedListControllerMixin.modelList(widget.hashKey),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  } else if (snapshot.hasError) {
                    return Container();
                  }
                  List<ModelToString> models = snapshot.data!;
                  return StreamBuilder<List<ModelToString>>(
                      stream: widget.checkedListControllerMixin.checkedModels(widget.hashKey),
                      builder: (context, checkedSnapshot) {
                        if (checkedSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          widget.checkedListControllerMixin.initCheckedList(widget.hashKey);
                          return const Loader();
                        }
                        List<ModelToString?> checkedModels =
                            checkedSnapshot.data!;
                        return StreamBuilder<String>(
                            stream: widget.checkedListControllerMixin.checkedListErrorText(widget.hashKey),
                            builder: (context, errorSnapshot) {
                              if (errorSnapshot.hasData) {
                                _formKey.currentState!.validate();
                              }
                              return MultiSelectChipField(
                                items: models
                                    .map((e) => MultiSelectItem<ModelToString?>(
                                        e, e.listViewTitle()))
                                    .toList(),
                                selectedChipColor: orangeColor,
                                key: _formKey,
                                initialValue: checkedModels,
                                onTap: (List<ModelToString?> values) {
                                  widget.checkedListControllerMixin.setCheckedList(
                                      convertNullableModelList(values), widget.hashKey);
                                },
                                showHeader: false,
                                validator: (values) {
                                  if (values == null || values.isEmpty) {
                                    return errorSnapshot.data ??
                                        atLeastOnePlayerMustBePresentValidation;
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
