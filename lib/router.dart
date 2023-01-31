import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/error.dart';
import 'package:trus_app/features/auth/screens/login_screen.dart';
import 'package:trus_app/features/auth/screens/registration_screen.dart';
import 'package:trus_app/features/auth/screens/user_information_screen.dart';

import 'features/player/screens/edit_player_screen.dart';
import 'models/player_model.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch(settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case RegistrationScreen.routeName:
      return MaterialPageRoute(builder: (context) => const RegistrationScreen());
    case UserInformationScreen.routeName:
      return MaterialPageRoute(builder: (context) => const UserInformationScreen());
    default:
      return MaterialPageRoute(builder: (context) => const Scaffold(
        body: ErrorScreen(error: "obrazovka nenalezena"),
      ));

  }
}