import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/builder/column_future_builder.dart';
import 'package:trus_app/common/widgets/custom_text_button.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/auth/app_team/screens/app_team_registration_screen.dart';
import 'package:trus_app/features/auth/registration/screens/registration_screen.dart';
import 'package:trus_app/features/auth/screens/user_information_screen.dart';
import 'package:trus_app/features/main/main_screen.dart';

import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/rows/crud/row_text_field_stream.dart';
import '../../../../models/api/auth/user_api_model.dart';
import '../../../loading/loading_screen.dart';
import '../controller/auth_login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  late LoginRedirect redirectWidget;

  void chooseRouteNameByWidget(LoginRedirect redirect, UserApiModel user) {
    switch(redirect) {
      case LoginRedirect.needToLogin:
        navigateToLoginScreen();
        break;
      case LoginRedirect.completeUserInformation:
        navigateToUserInformation();
        break;
      case LoginRedirect.setAppTeam:
        navigateToAppTeamRegistration();
        break;
      case LoginRedirect.chooseAppTeam:
        navigateToLoginScreen();
        break;
      case LoginRedirect.ok:
        navigateToHomePage(user);
        break;
      default:
        navigateToLoginScreen();
    }
  }

  void navigateToHomePage(UserApiModel user) {
    if (user.name == null || user.name!.isEmpty) {
      Navigator.pushNamedAndRemoveUntil(
          context, UserInformationScreen.routeName, (route) => false);
    } else {
      showSnackBarWithPostFrame(
          context: context, content: user.toStringForAdd());
      Navigator.pushNamed(context, MainScreen.routeName);
    }
  }

  void navigateToRegistrationScreen(BuildContext context) {
    Navigator.pushNamed(context, RegistrationScreen.routeName);
  }

  void navigateToUserInformation() {
    Navigator.pushNamed(context, UserInformationScreen.routeName);
  }

  void navigateToAppTeamRegistration() {
    Navigator.pushNamed(context, AppTeamRegistrationScreen.routeName);
  }

  void navigateToLoginScreen() {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    const double padding = 8.0;
    return Scaffold(
        body: FutureBuilder<void>(
            future: ref.watch(authLoginControllerProvider).setupUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(snapshot, () {
                          navigateToLoginScreen();
                        }, context));
                return const Loader();
              }
              return ColumnFutureBuilder(
                crossAxisAlignment: CrossAxisAlignment.center,
                loadModelFuture:
                    ref.watch(authLoginControllerProvider).loadLoginUser(),
                loadingScreen: ref.read(authLoginControllerProvider).loading(),
                loadingScreenWidget: LoadingScreen(
                  buttonClicked: () => chooseRouteNameByWidget(redirectWidget, ref.read(authLoginControllerProvider).loadedUser),
                  buttonText: "Pokračovat na domovskou obrazovku",
                  loadingFlag:
                      ref.read(authLoginControllerProvider).loadingSuccess(),
                  loadingDoneText: "Úspěšně přihlášeno!",
                ),
                columns: [
                  Image.asset(
                    key: const ValueKey('logo_image'),
                    'images/logo.jpg',
                    height: 240,
                    width: 215,
                  ),
                  const Text("Pro přihlášení zadej uživatelské jméno a heslo."),
                  const SizedBox(height: 15),
                  RowTextFieldStream(
                    key: const ValueKey('email_text_field'),
                    size: size,
                    labelText: "email",
                    textFieldText: "email:",
                    padding: padding,
                    stringControllerMixin: ref.watch(authLoginControllerProvider),
                    hashKey: ref.read(authLoginControllerProvider).emailKey(),
                    showLabel: false,
                  ),
                  RowTextFieldStream(
                    key: const ValueKey('password_text_field'),
                    size: size,
                    labelText: "heslo",
                    textFieldText: "heslo:",
                    padding: padding,
                    password: true,
                    stringControllerMixin: ref.watch(authLoginControllerProvider),
                    hashKey: ref.read(authLoginControllerProvider).passwordKey(),
                    showLabel: false,
                  ),
                  CustomButton(
                      text: "Přihlaš se",
                      onPressed: () async => redirectWidget = await ref.read(authLoginControllerProvider).sendEmailAndPassword(),
                      key: const ValueKey('login_button')),
                  CustomTextButton(
                      text: "Zaregistruj se",
                      onPressed: () => navigateToRegistrationScreen(context),
                      key: const ValueKey('registration_button')),
                  CustomTextButton(
                      text: "Zapomněl jsem heslo",
                      onPressed: () async {
                        final text = await ref.read(authLoginControllerProvider).sendForgottenPassword();
                        if (!context.mounted) return;
                        showInfoDialog(context, text);
                      },
                      key: const ValueKey('forgotten_password_button')),
                  const SizedBox(height: 10),
                ],
              );
            }),
        );
  }
}
