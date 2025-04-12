import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';
import 'package:trus_app/features/auth/screens/user_information_screen.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../general/error/api_executor.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);
  static const routeName = '/registration-screen';

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreen();
}

class _RegistrationScreen extends ConsumerState<RegistrationScreen> {
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
      bool? result = await executeApi<bool?>(() async {
        return await ref
            .read(authControllerProvider)
            .signUpWithEmail(email, password);
      }, () {}, context, true);
      if (result != null && result) {
        Navigator.pushNamedAndRemoveUntil(
            context, UserInformationScreen.routeName, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrace"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text("Pro registraturu zadej mail a heslo."),
            const SizedBox(height: 15),
            CustomTextField(
                textController: emailController,
                labelText: "mail",
                errorText: emailErrorText,
                key: const ValueKey('email_text_field')),
            CustomTextField(
                textController: passwordController,
                labelText: "heslo",
                password: true,
                errorText: passwordErrorText,
                key: const ValueKey('password_text_field')),
            CustomButton(
                text: "Pokračuj",
                onPressed: () => sendEmailAndPassword(),
                key: const ValueKey('confirm_button')),
          ],
        ),
      ),
    );
  }
}
