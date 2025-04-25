import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/app_team/controller/auth_app_team_registration_controller.dart';
import 'package:trus_app/features/auth/registration/controller/auth_registration_controller.dart';
import 'package:trus_app/features/main/main_screen.dart';

import '../../../../common/utils/utils.dart';
import '../../../../common/widgets/builder/column_future_builder.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/loader.dart';
import '../../../../common/widgets/rows/crud/row_api_model_dropdown_stream.dart';
import '../../../../common/widgets/rows/crud/row_switch_stream.dart';
import '../../../../common/widgets/rows/crud/row_text_field_stream.dart';
import '../../../loading/loading_screen.dart';

class AppTeamRegistrationScreen extends ConsumerStatefulWidget {
  const AppTeamRegistrationScreen({Key? key}) : super(key: key);
  static const routeName = '/app-team-registration-screen';

  @override
  ConsumerState<AppTeamRegistrationScreen> createState() => _AppTeamRegistrationScreen();
}

class _AppTeamRegistrationScreen extends ConsumerState<AppTeamRegistrationScreen> {

  void decideIfNavigateToMainScreen(bool result) {
    if(result) {
      navigateToMainScreen(context);
    }
  }

  void navigateToAppTeamRegistrationScreen(BuildContext context) {
    Navigator.pushNamed(context, AppTeamRegistrationScreen.routeName);
  }

  void navigateToMainScreen(BuildContext context) {
    Navigator.pushNamed(context, MainScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authAppTeamRegistrationControllerProvider);
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
                        navigateToAppTeamRegistrationScreen(context);
                  }, context));
              return const Loader();
            }
            return ColumnFutureBuilder(
              crossAxisAlignment: CrossAxisAlignment.center,
              loadModelFuture:
              controller.loadRegistrationSetup(),
              loadingScreen: controller.loading(),
              loadingScreenWidget: LoadingScreen(
                buttonClicked: () => navigateToMainScreen(context),
                buttonText: "Pokračovat na domovskou obrazovku",
                loadingFlag:
                ref.read(authRegistrationControllerProvider).loadingSuccess(),
                loadingDoneText: "Úspěšně registrováno!",
              ),
              columns: [
                const SizedBox(height: 30),
                const Text("Nyní si zvol tým, pod kterým budeš registrován"),
                const Text("Doporučujeme Liščí Trus, pak nech vše jak je"),
                const SizedBox(height: 15),
                RowSwitchStream(
                  key: const ValueKey('primary_team_field'),
                  size: size,
                  padding: padding,
                  textFieldText: "Jsem hráč/fanoušek/chci pít za Liščí Trus",
                  booleanControllerMixin: controller,
                  hashKey: controller.primaryTeamKey(),
                ),
                StreamBuilder<bool>(
                    stream: controller.boolean(controller.primaryTeamKey()),
                    builder: (context, snapshot) {
                      bool primaryTeam = true;
                      if (snapshot.hasData) {
                        primaryTeam = snapshot.data!;
                      }
                      if(!primaryTeam) {
                        return Column(
                          children: [
                            const SizedBox(height: 15),
                            const Text("Zvol si tým, pod kterým budeš pít."),
                            const SizedBox(height: 15),
                            RowApiModelDropDownStream(
                              key: const ValueKey('league_spinner'),
                              size: size,
                              padding: padding,
                              text: 'Liga',
                              hint: 'Vyber ligu',
                              dropdownControllerMixin: controller,
                              hashKey: controller.leagueKey(),
                            ),
                            RowApiModelDropDownStream(
                              key: const ValueKey('team_spinner'),
                              size: size,
                              padding: padding,
                              text: 'Tým',
                              hint: 'Vyber tým',
                              dropdownControllerMixin: controller,
                              hashKey: controller.teamKey(),
                            ),
                            StreamBuilder<bool>(
                                stream: controller.boolean(controller.newAppTeamKeyPicked()),
                                builder: (context, newAppTeamSnapshot) {
                                  bool newAppTeamPicked = controller.boolValues[controller.newAppTeamKeyPicked()]!;
                                  if (newAppTeamSnapshot.hasData) {
                                    newAppTeamPicked = newAppTeamSnapshot.data!;
                                  }
                                  if(newAppTeamPicked) {
                                    return RowTextFieldStream(
                                      key: const ValueKey('new_app_team_field'),
                                      size: size,
                                      labelText: "Název picího týmu",
                                      textFieldText: "Vlastní tým:",
                                      padding: padding,
                                      stringControllerMixin: controller,
                                      hashKey: controller.newAppTeamKey(),
                                    );
                                  }
                                  return RowApiModelDropDownStream(
                                    key: const ValueKey('app_team_spinner'),
                                    size: size,
                                    padding: padding,
                                    text: 'Připoj se k týmu',
                                    hint: 'Žádný tým není/založ si nový',
                                    dropdownControllerMixin: controller,
                                    hashKey: controller.appTeamKey(),
                                  );
                                }),
                            RowSwitchStream(
                              key: const ValueKey('new_app_team_picked_field'),
                              size: size,
                              padding: padding,
                              textFieldText: "Chci založit vlastní tým",
                              booleanControllerMixin: controller,
                              hashKey: controller.newAppTeamKeyPicked(),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                CustomButton(
                    text: "Dokonči registraci a přihlaš se",
                    onPressed: () async => decideIfNavigateToMainScreen(await controller.setNewAppTeam()),
                    key: const ValueKey('confirm_button')),
              ],
            );
          }),
    );
  }
}
