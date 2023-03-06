import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_text_button.dart';
import 'package:trus_app/common/widgets/custom_text_field.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';
import 'package:trus_app/features/auth/screens/registration_screen.dart';
import 'package:trus_app/common/utils/field_validator.dart';
import 'package:trus_app/features/main/main_screen.dart';

import '../../../common/widgets/custom_button.dart';

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
    if(emailErrorText.isEmpty && passwordErrorText.isEmpty) {
      if(await ref.read(authControllerProvider).signInWithEmail(context, email, password)) {
        Navigator.pushNamedAndRemoveUntil(context, MainScreen.routeName, (route) => false);
      }
    }
  }

  Future<void> sendForgottenPassword() async {
    String email = emailController.text.trim();
    setState(() {
      emailErrorText = validateEmptyField(email);
    });
    if(emailErrorText.isEmpty) {
      if(await ref.read(authControllerProvider).sendForgottenPassword(context, email)) {
      }
    }
  }

  void navigateToRegistrationScreen(BuildContext context) {
    Navigator.pushNamed(context, RegistrationScreen.routeName);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
            CustomTextField(textController: emailController, labelText: "email", errorText: emailErrorText),
            CustomTextField(textController: passwordController, labelText: "heslo", password: true, errorText: passwordErrorText),
            CustomButton(text: "Přihlaš se", onPressed: () => sendEmailAndPassword()),
            CustomTextButton(text: "Zaregistruj se", onPressed: () => navigateToRegistrationScreen(context)),
            CustomTextButton(text: "Zapomněl jsem heslo", onPressed: () => sendForgottenPassword()),
          ],
        ),
      ),
    );
  }
}
