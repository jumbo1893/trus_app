import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_text_button.dart';
import 'package:trus_app/common/widgets/custom_text_field.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';
import 'package:trus_app/features/auth/screens/registration_screen.dart';
import 'package:trus_app/common/utils/field_validator.dart';
import 'package:trus_app/features/auth/screens/user_information_screen.dart';
import 'package:trus_app/features/main/main_screen.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/repository/exception/handler/exception_handler.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../models/api/user_api_model.dart';
import '../../general/error/api_executor.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String emailErrorText = "";
  String passwordErrorText = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> sendEmailAndPassword() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    setState(() {
      emailErrorText = validateEmptyField(email);
      passwordErrorText = validateEmptyField(password);
    });
    if (emailErrorText.isEmpty && passwordErrorText.isEmpty) {
      UserApiModel? user = await executeApi<UserApiModel?>(() async {
        return await ref.read(authControllerProvider).signInWithEmail(email, password);
      },() {}, context, true);
      if(user != null) {
        if(user.name == null || user.name!.isEmpty) {
          Navigator.pushNamedAndRemoveUntil(context, UserInformationScreen.routeName, (route) => false);
        }
        else {
          showSnackBarWithPostFrame(context: context, content: user.toStringForAdd());
          Navigator.pushNamed(context, MainScreen.routeName);
        }
      }
    }
  }

  Future<void> sendForgottenPassword() async {
    String email = emailController.text.trim();
    setState(() {
      emailErrorText = validateEmptyField(email);
    });
    if (emailErrorText.isEmpty) {
      if (await ref
          .read(authControllerProvider)
          .sendForgottenPassword(context, email)) {}
    }
  }

  void navigateToRegistrationScreen(BuildContext context) {
    Navigator.pushNamed(context, RegistrationScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo.jpg',
                    height: 240,
                    width: 215,
                  ),
                  const Text("Pro přihlášení zadej uživatelské jméno a heslo."),
                  const SizedBox(height: 15),
                  CustomTextField(
                      textController: emailController,
                      labelText: "email",
                      errorText: emailErrorText),
                  CustomTextField(
                      textController: passwordController,
                      labelText: "heslo",
                      password: true,
                      errorText: passwordErrorText),
                  CustomButton(
                      text: "Přihlaš se", onPressed: () => sendEmailAndPassword()),
                  CustomTextButton(
                      text: "Zaregistruj se",
                      onPressed: () => navigateToRegistrationScreen(context)),
                  CustomTextButton(
                      text: "Zapomněl jsem heslo",
                      onPressed: () => sendForgottenPassword()),
                ],
              ),
          ),
        );
  }
}
