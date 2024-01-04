import 'package:flutter/material.dart';

import '../../../features/general/app_bar_title.dart';
import '../../../features/general/screen_name.dart';

abstract class CustomStatefulWidget extends StatefulWidget implements AppBarTitle, ScreenName {
  final String title;
  final String name;
  const CustomStatefulWidget({super.key, required this.title, required this.name});

  @override
  String appBarTitle() {
    return title;
  }

  @override
  String screenName() {
    return name;
  }
}