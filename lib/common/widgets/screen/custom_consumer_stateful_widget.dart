import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/general/app_bar_title.dart';
import '../../../features/general/screen_name.dart';

abstract class CustomConsumerStatefulWidget extends ConsumerStatefulWidget implements AppBarTitle, ScreenName {
  final String title;
  final String name;
  const CustomConsumerStatefulWidget({super.key, required this.title, required this.name});

  @override
  String appBarTitle() {
    return title;
  }

  @override
  String screenName() {
    return name;
  }

}