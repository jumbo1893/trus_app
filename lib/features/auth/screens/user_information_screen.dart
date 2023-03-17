import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_text_field.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';

import '../../main/main_screen.dart';
import '../../notification/controller/notification_controller.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);
  static const routeName = '/user-information-screen';

  @override
  ConsumerState<UserInformationScreen> createState() => _UserInformationScreenState();
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
    if(errorText.isEmpty) {
      if(await ref.read(authControllerProvider).saveUserDataToFirebase(context, name)) {
        //await ref.read(notificationControllerProvider).addAdminNotification(context, "Nová registrace", "Zaregistrován nový píč $name");
        Navigator.pushNamedAndRemoveUntil(context, MainScreen.routeName, (route) => false);
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
            const Text("Teď už jenom zadej nějaký jméno pod kterým budeš pít"),
            const SizedBox(height: 15),
            CustomTextField(textController: textController, labelText: "nick", errorText: errorText,),
            CustomButton(text: "Dokonči registraci", onPressed: () => storeUserData()),
          ],
        ),
      ),
    );
  }
}
