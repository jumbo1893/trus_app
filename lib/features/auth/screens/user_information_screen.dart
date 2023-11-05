import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';

import '../../general/error/api_executor.dart';
import '../../main/main_screen.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);
  static const routeName = '/user-information-screen';

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final textController = TextEditingController();
  String errorText = "";

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> storeUserData() async {
    String name = textController.text.trim();
    setState(() {
      errorText = validateEmptyField(name);
    });
    if (errorText.isEmpty) {
      await executeApi<void>(() async {
        return await ref.read(authControllerProvider).saveUserData(name);
      }, () {}, context, true)
          .whenComplete(() => Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.routeName, (route) => false));
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
            const Text("Teď už jenom zadej nějaký jméno pod kterým budeš pít"),
            const SizedBox(height: 15),
            CustomTextField(
                textController: textController,
                labelText: "nick",
                errorText: errorText,
                key: const ValueKey('name_text_field')),
            CustomButton(
                text: "Dokonči registraci",
                onPressed: () => storeUserData(),
                key: const ValueKey('confirm_button')),
          ],
        ),
      ),
    );
  }
}
