import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/utils.dart';

class CustomFirebaseException {

  bool showSnackBarOnException(String code, BuildContext context) {
    switch (code.toLowerCase()) {
      case "permission-denied":
        showSnackBarWithPostFrame(content: "Nemáš dostatečný práva pro úpravu, kontaktuj správce", context: context);
        return true;
    }
    return false;
  }
}