import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/registration/controller/auth_registration_controller.dart';
import 'package:trus_app/features/auth/screens/user_information_screen.dart';
import 'package:trus_app/features/main/main_screen.dart';

import '../../../../common/utils/utils.dart';
import '../../../../common/widgets/builder/column_future_builder.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/loader.dart';
import '../../../../common/widgets/rows/crud/row_text_field_stream.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);
  static const routeName = '/registration-screen';

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreen();
}

class _RegistrationScreen extends ConsumerState<RegistrationScreen> {

  void decideIfNavigateToAppTeamRegistrationScreen(bool result) {
    if(result) {
      navigateToAppTeamRegistrationScreen(context);
    }
  }

  void navigateToAppTeamRegistrationScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, UserInformationScreen.routeName, (route) => false);
  }

  void navigateToRegistrationScreen(BuildContext context) {
    Navigator.pushNamed(context, RegistrationScreen.routeName);
  }

  void navigateToMainScreen(BuildContext context) {
    Navigator.pushNamed(context, MainScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authRegistrationControllerProvider);
    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    const double padding = 8.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrace"),
        elevation: 0,
      ),
      body: FutureBuilder<void>(
          future: controller.setupRegistration(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            } else if (snapshot.hasError) {
              Future.delayed(
                  Duration.zero,
                      () => showErrorDialog(snapshot, () {
                        navigateToRegistrationScreen(context);
                  }, context));
              return const Loader();
            }
            return ColumnFutureBuilder(
              crossAxisAlignment: CrossAxisAlignment.center,
              loadModelFuture:
              controller.loadRegistrationSetup(),
              loadingScreen: null,
              columns: [
                const SizedBox(height: 30),
                const Text("Pro registraturu zadej mail, heslo a přezdívku."),
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
                    onPressed: () async => decideIfNavigateToAppTeamRegistrationScreen(await controller.sendEmailAndPassword()),
                    key: const ValueKey('confirm_button')),
              ],
            );
          }),
    );
  }
}
