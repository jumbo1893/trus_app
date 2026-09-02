import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/repository/exception/field_validation_exception.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/team_administration/controller/team_administration_provider.dart';
import 'package:trus_app/features/team_administration/repository/team_administration_repository.dart';
import 'package:trus_app/models/api/auth/team_administration_api_model.dart';
import 'package:trus_app/models/api/auth/team_member_api_model.dart';

class TeamAdministrationScreen extends CustomConsumerStatefulWidget {
  static const String id = 'team-administration-screen';

  const TeamAdministrationScreen({super.key})
    : super(title: 'Administrace týmu', name: id);

  @override
  ConsumerState<TeamAdministrationScreen> createState() =>
      _TeamAdministrationScreenState();
}

class _TeamAdministrationScreenState
    extends ConsumerState<TeamAdministrationScreen> {
  @override
  Widget build(BuildContext context) {
    final administration = ref.watch(teamAdministrationProvider);
    return Scaffold(
      body: administration.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _LoadError(
          message: _errorMessage(error),
          retry: () => ref.invalidate(teamAdministrationProvider),
        ),
        data: _buildAdministration,
      ),
    );
  }

  Widget _buildAdministration(TeamAdministrationApiModel administration) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teamAdministrationProvider);
        await ref.read(teamAdministrationProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text(
            administration.teamName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            administration.ownerName == null
                ? 'Nastavení přístupů a administrátorů'
                : 'Zakladatel: ${administration.ownerName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Kódy pro připojení',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Každému pošli jen kód odpovídající právům, která má v týmu získat.',
          ),
          const SizedBox(height: 10),
          _JoinCodeCard(
            title: 'Pouze čtení',
            description: 'Uživatel může tým sledovat, ale nemůže měnit data.',
            code: administration.readerCode,
            icon: Icons.visibility_outlined,
            onCopy: () => _copyCode(administration.readerCode),
            onEdit: () => _editCode('reader', administration.readerCode),
          ),
          _JoinCodeCard(
            title: 'Čtení a editace',
            description: 'Uživatel může přidávat a upravovat týmová data.',
            code: administration.editorCode,
            icon: Icons.edit_outlined,
            onCopy: () => _copyCode(administration.editorCode),
            onEdit: () => _editCode('editor', administration.editorCode),
          ),
          const SizedBox(height: 18),
          Text('Členové týmu', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'Administrátoři mohou každému členovi nastavit čtení, editaci nebo administraci.',
          ),
          const SizedBox(height: 10),
          ...administration.members.map(
            (member) => _memberCard(member, administration.currentUserId),
          ),
        ],
      ),
    );
  }

  Widget _memberCard(TeamMemberApiModel member, int currentUserId) {
    final isCurrentUser = member.userId == currentUserId;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(member.owner ? Icons.star : Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (member.mail.isNotEmpty)
                        Text(
                          member.mail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 3),
                      Text(
                        member.owner
                            ? 'Zakladatel · Administrátor'
                            : member.roleLabel,
                      ),
                    ],
                  ),
                ),
                if (member.owner || isCurrentUser)
                  const Tooltip(
                    message: 'Tato administrátorská práva nelze změnit',
                    child: Icon(Icons.lock_outline),
                  ),
              ],
            ),
            if (!member.owner && !isCurrentUser) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Práva:'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: member.role,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'READER',
                          child: Text('Pouze čtení'),
                        ),
                        DropdownMenuItem(
                          value: 'EDITOR',
                          child: Text('Čtení a editace'),
                        ),
                        DropdownMenuItem(
                          value: 'ADMIN',
                          child: Text('Administrátor'),
                        ),
                      ],
                      onChanged: (role) {
                        if (role != null && role != member.role) {
                          _confirmRoleChange(member, role);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Kód byl zkopírován.')));
  }

  Future<void> _editCode(String role, String currentCode) async {
    final controller = TextEditingController(text: currentCode);
    String? errorText;
    bool saving = false;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Změnit kód'),
          content: TextField(
            controller: controller,
            autofocus: true,
            autocorrect: false,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Kód týmu',
              helperText: '4–32 znaků: písmena, čísla, - a _',
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context, false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDialogState(() {
                        saving = true;
                        errorText = null;
                      });
                      try {
                        await ref
                            .read(teamAdministrationRepositoryProvider)
                            .updateJoinCode(role, controller.text);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } catch (error) {
                        setDialogState(() {
                          saving = false;
                          errorText = _errorMessage(error);
                        });
                      }
                    },
              child: saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Uložit'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (saved == true) {
      ref.invalidate(teamAdministrationProvider);
    }
  }

  Future<void> _confirmRoleChange(
    TeamMemberApiModel member,
    String role,
  ) async {
    if (member.isAdministrator && role != 'ADMIN') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Změnit práva administrátora?'),
          content: Text(
            '${member.userName} už nebude moci spravovat tým. Nová práva: ${_roleLabel(role)}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Změnit práva'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        ref.invalidate(teamAdministrationProvider);
        return;
      }
    }
    await _runMutation(
      () => ref
          .read(teamAdministrationRepositoryProvider)
          .updateMemberRole(member.userTeamRoleId, role),
      'Práva uživatele ${member.userName} byla změněna na ${_roleLabel(role)}.',
    );
  }

  Future<void> _runMutation(
    Future<TeamAdministrationApiModel> Function() mutation,
    String successMessage,
  ) async {
    try {
      await mutation();
      ref.invalidate(teamAdministrationProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      ref.invalidate(teamAdministrationProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    }
  }
}

class _JoinCodeCard extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final IconData icon;
  final VoidCallback onCopy;
  final VoidCallback onEdit;

  const _JoinCodeCard({
    required this.title,
    required this.description,
    required this.code,
    required this.icon,
    required this.onCopy,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Zkopírovat kód',
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: 'Upravit kód',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            Text(description),
            const SizedBox(height: 10),
            SelectableText(
              code,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback retry;

  const _LoadError({required this.message, required this.retry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: retry, child: const Text('Zkusit znovu')),
          ],
        ),
      ),
    );
  }
}

String _errorMessage(Object error) {
  if (error is FieldValidationException) {
    final fields = error.fields;
    final message = fields == null || fields.isEmpty
        ? null
        : fields.first.message;
    return message ?? 'Zadanou hodnotu nelze uložit.';
  }
  if (error is ServerException) {
    return error.cause;
  }
  return 'Operaci se nepodařilo dokončit.';
}

String _roleLabel(String role) {
  switch (role) {
    case 'ADMIN':
      return 'administrátor';
    case 'EDITOR':
      return 'čtení a editace';
    case 'READER':
      return 'pouze čtení';
    default:
      return role;
  }
}
