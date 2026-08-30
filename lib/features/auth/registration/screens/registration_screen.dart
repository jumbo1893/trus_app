import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/registration/controller/auth_registration_controller.dart';
import 'package:trus_app/features/auth/app_team/screens/app_team_registration_screen.dart';

import '../../../../common/widgets/builder/column_future_builder.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/rows/crud/row_text_field_stream.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);
  static const routeName = '/registration-screen';

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreen();
}

class _RegistrationScreen extends ConsumerState<RegistrationScreen> {
  void decideIfNavigateToAppTeamRegistrationScreen(bool result) {
    if (result) {
      navigateToAppTeamRegistrationScreen(context);
    }
  }

  void navigateToAppTeamRegistrationScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppTeamRegistrationScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authRegistrationControllerProvider);
    final size = MediaQuery.sizeOf(context);
    const double padding = 8.0;
    return Scaffold(
      appBar: AppBar(title: const Text("Registrace"), elevation: 0),
      body: ColumnFutureBuilder(
        crossAxisAlignment: CrossAxisAlignment.center,
        loadModelFuture: controller.loadRegistrationSetup(),
        loadingScreen: null,
        columns: [
          const SizedBox(height: 30),
          const Text("Zadej e-mail, heslo a přezdívku."),
          const SizedBox(height: 15),
          RowTextFieldStream(
            key: const ValueKey('email_text_field'),
            size: size,
            labelText: "email",
            textFieldText: "email:",
            padding: padding,
            stringControllerMixin: controller,
            hashKey: controller.emailKey(),
            showLabel: false,
          ),
          RowTextFieldStream(
            key: const ValueKey('password_text_field'),
            size: size,
            labelText: "heslo",
            textFieldText: "heslo:",
            padding: padding,
            password: true,
            stringControllerMixin: controller,
            hashKey: controller.passwordKey(),
            showLabel: false,
          ),
          RowTextFieldStream(
            key: const ValueKey('name_text_field'),
            size: size,
            labelText: "přezdívka",
            textFieldText: "přezdívka:",
            padding: padding,
            stringControllerMixin: controller,
            hashKey: controller.nameKey(),
            showLabel: false,
          ),
          CustomButton(
            text: "Pokračuj",
            onPressed: () async => decideIfNavigateToAppTeamRegistrationScreen(
              await controller.sendEmailAndPassword(),
            ),
            key: const ValueKey('confirm_button'),
          ),
        ],
      ),
    );
  }
}
