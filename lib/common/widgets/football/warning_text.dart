import 'package:flutter/material.dart';
import 'package:trus_app/models/api/helper/redirect/redirect_api_model.dart';

import '../../../models/api/helper/warning_type.dart';

class WarningText extends StatelessWidget {
  final String text;
  final WarningType? warningType;
  final RedirectApiModel? redirectApiModel;
  final void Function(RedirectApiModel redirect) onClicked;
  const WarningText({
    Key? key,
    required this.text,
    required this.warningType,
    required this.redirectApiModel,
    required this.onClicked
  }) : super(key: key);

  Row _buildRow() {
    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: buildWarningIcon()
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(left: 6, right: 3),
          child: Text(text),
        )),
        Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: buildRedirectIcon()
        ),
      ],
    );
  }

  Icon? buildRedirectIcon() {
    if(redirectApiModel != null) {
      return const Icon(Icons.arrow_forward_ios, color: Colors.blue);
    }
    return null;
  }

  Icon? buildWarningIcon() {
    switch (warningType) {
      case WarningType.error:
        return const Icon(Icons.error, color: Colors.red);
      case WarningType.warning:
        return const Icon(Icons.warning, color: Colors.orange);
      case WarningType.info:
        return const Icon(Icons.question_mark, color: Colors.blue);
      case WarningType.nullType:
        return null;
        case WarningType.success:
        return const Icon(Icons.check, color: Colors.green);
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: redirectApiModel != null ? InkWell(
        onTap: () => redirectApiModel != null ? onClicked(redirectApiModel!) : null,
        child: _buildRow(),
      ) : _buildRow()
    );
  }
}
