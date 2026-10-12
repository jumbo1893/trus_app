import 'package:flutter/material.dart';
import 'package:trus_app/features/season_recap/season_recap_cards.dart';
import 'package:trus_app/features/onboarding/onboarding_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/user/controller/view_user_notifier.dart';
import 'package:trus_app/features/membership/widgets/membership_info.dart';
import 'package:trus_app/features/main/controller/main_notifier.dart';
import 'package:trus_app/features/beer/controller/beer_view_preference.dart';

import '../../../common/widgets/bar/action_button_item.dart';
import '../../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../../common/widgets/rows/app_read_only_field.dart';
import '../../../common/widgets/rows/form/form_field_wrapper.dart';
import '../../../common/widgets/screen/base_form_screen.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';

class ViewUserScreen extends CustomConsumerStatefulWidget {
  static const String id = "view-user-screen";

  const ViewUserScreen({Key? key})
    : super(key: key, title: "Nastavení uživatele", name: id);

  @override
  ConsumerState<ViewUserScreen> createState() => _ViewUserScreenState();
}

class _ViewUserScreenState extends ConsumerState<ViewUserScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(viewUserNotifierProvider);
    final notifier = ref.read(viewUserNotifierProvider.notifier);

    return BaseFormScreen(
      headerTitle: state.name,
      headerText: state.email,
      headerTitleWidget: MembershipUserName(name: state.name),
      fields: [
        const FormFieldWrapper(
          label: "Úroveň účtu",
          child: MembershipStatusCard(),
        ),
        FormFieldWrapper(
          label: "Spárování s hráčem",
          child: CustomDropdownSheet(
            state: state,
            notifier: notifier,
            hint: "Vyber hráče",
          ),
        ),
        FormFieldWrapper(
          label: "Práva",
          child: AppReadOnlyField(
            value: state.userTeamRole?.roleToString() ?? "Bez práv",
            allowWrap: true,
          ),
        ),
        if (state.otherRoles.trim().isNotEmpty)
          FormFieldWrapper(
            label: "Jiné týmy",
            child: AppReadOnlyField(value: state.otherRoles, allowWrap: true),
          ),
      ],
      actions: [
        ActionButtonItem(
          label: "Uložit profil",
          onPressed: () => notifier.commit(),
          type: ActionButtonType.primary,
        ),
      ],
      extraSections: [
        const _BeerViewPreferenceCard(),
        const SeasonRecapHistoryCard(),
        const OnboardingCard(),
        AccountDeletionOptions(
          onDelete: () =>
              ref.read(mainNotifierProvider.notifier).onDeleteAccountTapped(),
        ),
      ],
    );
  }
}

class _BeerViewPreferenceCard extends ConsumerWidget {
  const _BeerViewPreferenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawMode = ref.watch(beerViewPreferenceProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zápis v hospodě',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text('Zvolený pohled se ukládá hned do tohoto zařízení.'),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.receipt_long_outlined),
                    label: Text('Účet'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.edit_note_rounded),
                    label: Text('Čárkování'),
                  ),
                ],
                selected: {drawMode},
                onSelectionChanged: (selected) => ref
                    .read(beerViewPreferenceProvider.notifier)
                    .setDrawMode(selected.first),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountDeletionOptions extends StatelessWidget {
  final VoidCallback onDelete;

  const AccountDeletionOptions({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: const PageStorageKey('account-more-options'),
        leading: const Icon(Icons.more_horiz),
        title: const Text('Další možnosti účtu'),
        children: [
          ListTile(
            key: const ValueKey('delete_account_button'),
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Smazat účet',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Trvale odstraní účet a jeho data.'),
            onTap: onDelete,
          ),
        ],
      ),
    ),
  );
}
