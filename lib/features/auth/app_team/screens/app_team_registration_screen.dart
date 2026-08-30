import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/app_team/controller/auth_app_team_registration_controller.dart';
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
  ConsumerState<AppTeamRegistrationScreen> createState() =>
      _AppTeamRegistrationScreen();
}

class _AppTeamRegistrationScreen
    extends ConsumerState<AppTeamRegistrationScreen> {
  void navigateToMainScreen() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      MainScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authAppTeamRegistrationControllerProvider);
    final size = MediaQuery.sizeOf(context);
    const padding = 8.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Vyber si tým'), elevation: 0),
      body: FutureBuilder<void>(
        future: controller.setupRegistration(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              showErrorDialog(
                snapshot,
                () => Navigator.pushReplacementNamed(
                  context,
                  AppTeamRegistrationScreen.routeName,
                ),
                context,
              );
            });
            return const Loader();
          }

          return ColumnFutureBuilder(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            loadModelFuture: controller.loadRegistrationSetup(),
            loadingScreen: controller.loading(),
            loadingScreenWidget: LoadingScreen(
              buttonClicked: navigateToMainScreen,
              buttonText: 'Pokračovat do aplikace',
              loadingFlag: controller.loadingSuccess(),
              loadingDoneText: 'Tým je připravený!',
            ),
            columns: [
              const SizedBox(height: 16),
              Text(
                'Jak chceš začít?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Výběr můžeš později změnit nebo se přidat k dalším týmům.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              StreamBuilder<TeamOnboardingChoice>(
                stream: controller.choice(),
                initialData: controller.selectedChoice,
                builder: (context, choiceSnapshot) {
                  final choice = choiceSnapshot.data!;
                  return RadioGroup<TeamOnboardingChoice>(
                    groupValue: choice,
                    onChanged: (selected) {
                      if (selected != null) {
                        controller.setChoice(selected);
                      }
                    },
                    child: Column(
                      children: [
                        const _ChoiceCard(
                          value: TeamOnboardingChoice.lisciTrus,
                          title: 'Přidat se k Liščímu Trusu',
                          subtitle:
                              'Doporučená volba pro hráče a fanoušky Liščího Trusu.',
                        ),
                        const _ChoiceCard(
                          value: TeamOnboardingChoice.joinExisting,
                          title: 'Přidat se k existujícímu týmu',
                          subtitle: 'Vyber tým, který už v aplikaci funguje.',
                        ),
                        if (choice == TeamOnboardingChoice.joinExisting)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: RowApiModelDropDownStream(
                              key: const ValueKey('app_team_spinner'),
                              size: size,
                              padding: padding,
                              text: 'Tým',
                              hint: 'Vyber tým',
                              dropdownControllerMixin: controller,
                              hashKey: controller.appTeamKey(),
                            ),
                          ),
                        const _ChoiceCard(
                          value: TeamOnboardingChoice.createNew,
                          title: 'Založit vlastní tým',
                          subtitle:
                              'Stačí název. Propojení s PKFL je volitelné.',
                        ),
                        if (choice == TeamOnboardingChoice.createNew) ...[
                          const SizedBox(height: 8),
                          RowTextFieldStream(
                            key: const ValueKey('new_app_team_field'),
                            size: size,
                            labelText: 'Název týmu',
                            textFieldText: 'Název',
                            padding: padding,
                            stringControllerMixin: controller,
                            hashKey: controller.newAppTeamKey(),
                          ),
                          if (controller.canLinkFootballTeam)
                            RowSwitchStream(
                              key: const ValueKey('link_football_team_field'),
                              size: size,
                              padding: padding,
                              textFieldText: 'Propojit s PKFL',
                              booleanControllerMixin: controller,
                              hashKey: controller.linkFootballTeamKey(),
                            ),
                          if (controller.canLinkFootballTeam)
                            StreamBuilder<bool>(
                              stream: controller.boolean(
                                controller.linkFootballTeamKey(),
                              ),
                              initialData: controller
                                  .boolValues[controller.linkFootballTeamKey()],
                              builder: (context, linkSnapshot) {
                                if (linkSnapshot.data != true) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  children: [
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
                                      text: 'Tým PKFL',
                                      hint: 'Vyber tým',
                                      dropdownControllerMixin: controller,
                                      hashKey: controller.teamKey(),
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              CustomButton(
                text: 'Dokončit registraci',
                onPressed: () async {
                  if (await controller.completeRegistration() && mounted) {
                    navigateToMainScreen();
                  }
                },
                key: const ValueKey('confirm_button'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final TeamOnboardingChoice value;
  final String title;
  final String subtitle;

  const _ChoiceCard({
    required this.value,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: RadioListTile<TeamOnboardingChoice>(
        value: value,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
