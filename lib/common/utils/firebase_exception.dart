import 'package:trus_app/common/utils/utils.dart';
import 'package:flutter/material.dart';

class CustomFirebaseException {

  bool showSnackBarOnException(String code, BuildContext context) {
    switch (code.toLowerCase()) {
      case "permission-denied":
        showSnackBar(content: "Nemáš dostatečný práva pro úpravu, kontaktuj správce", context: context);
        return true;
    }
    return false;
  }
}