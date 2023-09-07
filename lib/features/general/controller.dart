import 'dart:async';

class Controller {
  final snackBarController = StreamController<String>.broadcast();
  final onCompleteController = StreamController<bool>.broadcast();
  final showErrorDialog = StreamController<String>.broadcast();

  Stream<String> snackBar() {
    return snackBarController.stream;
  }

  Stream<String> errorDialog() {
    return showErrorDialog.stream;
  }

  Stream<bool> changeScreen() {
    return onCompleteController.stream;
  }
}