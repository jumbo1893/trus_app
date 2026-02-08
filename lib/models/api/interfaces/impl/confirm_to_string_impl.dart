import 'package:trus_app/models/api/interfaces/confirm_to_string.dart';

class ConfirmToStringImpl implements ConfirmToString {
  final String text;


  ConfirmToStringImpl(this.text);

  @override
  String toStringForSnackBar() {
    return text;
  }

}