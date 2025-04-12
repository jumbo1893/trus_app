import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';
import 'package:trus_app/features/auth/screens/login_screen.dart';
import 'package:trus_app/features/main/main_screen.dart';
import 'package:trus_app/router.dart';
import 'package:trus_app/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trus_app/firebase_options.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'config.dart';
import 'features/auth/screens/user_information_screen.dart';
import 'my_http_overrides.dart';

void main() async {
  if(automation) {
    enableFlutterDriverExtension();
  }
  if(serverUrl == testUrl) {
    HttpOverrides.global = MyHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Trusí aplikace",
        theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: backgroundColor,
            appBarTheme: const AppBarTheme(
              color: blackColor,
            )
        ),
        onGenerateRoute:  (settings) => generateRoute(settings),
        home: ref.watch(userDataAuthProvider).when(
            data: (redirect) {
              switch(redirect) {
                case LoginRedirect.needToLogin:
                  return const LoginScreen();
                case LoginRedirect.completeUserInformation:
                  return const UserInformationScreen();
                case LoginRedirect.setAppTeam:
                  return const LoginScreen();
                case LoginRedirect.chooseAppTeam:
                  return const LoginScreen();
                case LoginRedirect.ok:
                  return const MainScreen();
                default:
                  return const LoginScreen();
              }
            }, error: (error, trace) {
          //showSnackBar(context: context, content: error.toString());
              return const LoginScreen();
        }, loading: () => const Loader())
    );
  }
}
