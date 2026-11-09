import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:trus_app/features/user/screens/avatar_camera_screen.dart';
import 'package:image/image.dart' as image_lib;
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/user/widgets/user_avatar.dart';
import 'package:trus_app/features/chat/chat_controller.dart';
import 'package:trus_app/features/season_recap/season_recap_cards.dart';
import 'package:trus_app/features/onboarding/onboarding_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/user/controller/view_user_notifier.dart';
import 'package:trus_app/features/membership/widgets/membership_info.dart';
import 'package:trus_app/features/main/controller/main_notifier.dart';
import 'package:trus_app/features/beer/controller/beer_view_preference.dart';

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
  bool _uploadingAvatar = false;
  bool _renaming = false;

  Future<void> _rename() async {
    if (_renaming) return;
    final currentName = ref.read(viewUserNotifierProvider).name;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => RenameUserDialog(initialName: currentName),
    );
    if (!mounted || name == null || name == currentName || _renaming) return;
    setState(() => _renaming = true);
    try {
      final updated = await ref
          .read(authRepositoryProvider)
          .editCurrentUser(null, name, null);
      if (!mounted) return;
      ref.read(viewUserNotifierProvider.notifier).setName(updated.name ?? name);
      ref.invalidate(chatControllerProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jméno bylo změněno.')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jméno se nepodařilo změnit.')),
        );
      }
    } finally {
      if (mounted) setState(() => _renaming = false);
    }
  }

  Future<void> _changeAvatar(int userId) async {
    final file = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(builder: (_) => const AvatarCameraScreen()),
    );
    if (file == null || !mounted) return;
    final decoded = image_lib.decodeImage(await file.readAsBytes());
    if (decoded == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tento obrázek nelze otevřít.')),
        );
      }
      return;
    }
    final resized = image_lib.copyResize(decoded, width: 512);
    final bytes = Uint8List.fromList(image_lib.encodeJpg(resized, quality: 80));
    setState(() => _uploadingAvatar = true);
    try {
      await ref.read(authRepositoryProvider).uploadAvatar(bytes);
      ref.invalidate(userAvatarProvider(userId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profilová fotka byla uložena.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotku se nepodařilo uložit.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(viewUserNotifierProvider);
    final notifier = ref.read(viewUserNotifierProvider.notifier);

    return BaseFormScreen(
      headerTitle: state.name,
      headerText: state.email,
      headerTitleWidget: MembershipUserName(name: state.name),
      fields: [
        FormFieldWrapper(
          label: 'Profilová fotka',
          child: Row(
            children: [
              if (state.userId != null)
                UserAvatar(userId: state.userId!, radius: 32),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: state.userId == null || _uploadingAvatar
                    ? null
                    : () => _changeAvatar(state.userId!),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(_uploadingAvatar ? 'Nahrávám…' : 'Změnit fotku'),
              ),
            ],
          ),
        ),
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
      actions: const [],
      extraSections: [
        const _BeerViewPreferenceCard(),
        const SeasonRecapHistoryCard(),
        const OnboardingCard(),
        AccountDeletionOptions(
          onRename: _rename,
          onDelete: () =>
              ref.read(mainNotifierProvider.notifier).onDeleteAccountTapped(),
        ),
      ],
    );
  }
}

class RenameUserDialog extends StatefulWidget {
  final String initialName;

  const RenameUserDialog({super.key, required this.initialName});

  @override
  State<RenameUserDialog> createState() => _RenameUserDialogState();
}

class _RenameUserDialogState extends State<RenameUserDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Zadej jméno.');
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Změnit jméno'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      maxLength: 80,
      decoration: InputDecoration(labelText: 'Jméno', errorText: _error),
      onSubmitted: (_) => _confirm(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Zrušit'),
      ),
      FilledButton(onPressed: _confirm, child: const Text('Potvrdit změnu')),
    ],
  );
}

class _BeerViewPreferenceCard extends ConsumerWidget {
  const _BeerViewPreferenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawMode = ref.watch(beerViewPreferenceProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        margin: EdgeInsets.zero,
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
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
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
  final VoidCallback? onRename;

  const AccountDeletionOptions({
    super.key,
    required this.onDelete,
    this.onRename,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: const PageStorageKey('account-more-options'),
        leading: const Icon(Icons.more_horiz),
        title: const Text('Další možnosti účtu'),
        children: [
          if (onRename != null)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Změnit jméno'),
              onTap: onRename,
            ),
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
