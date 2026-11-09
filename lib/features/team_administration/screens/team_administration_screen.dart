import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trus_app/common/repository/exception/field_validation_exception.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/team_administration/controller/team_administration_provider.dart';
import 'package:trus_app/features/home/controller/home_notifier.dart';
import 'package:trus_app/features/team_administration/repository/team_administration_repository.dart';
import 'package:trus_app/models/api/auth/team_administration_api_model.dart';
import 'package:trus_app/models/api/auth/team_member_api_model.dart';
import 'package:trus_app/features/user/widgets/user_avatar.dart';

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
  int? _highlightedRoleId;

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
    final targetId = ref.watch(pendingTeamMemberTargetProvider);
    if (targetId != null &&
        administration.members.any(
          (member) => member.userTeamRoleId == targetId,
        )) {
      _highlightedRoleId = targetId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(pendingTeamMemberTargetProvider.notifier).state = null;
      });
    }
    final pending = administration.members
        .where((member) => !member.roleApproved)
        .toList();
    final members = administration.members
        .where((member) => member.roleApproved)
        .toList();
    if (_highlightedRoleId != null &&
        !pending.any((member) => member.userTeamRoleId == _highlightedRoleId)) {
      _highlightedRoleId = null;
    }
    pending.sort((a, b) {
      if (a.userTeamRoleId == _highlightedRoleId) return -1;
      if (b.userTeamRoleId == _highlightedRoleId) return 1;
      return a.userName.toLowerCase().compareTo(b.userName.toLowerCase());
    });
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teamAdministrationProvider);
        await ref.read(teamAdministrationProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
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
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Noví hráči',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text('Čekají na přiřazení nebo potvrzení práv.'),
                    const SizedBox(height: 8),
                    for (final member in pending)
                      _memberCard(
                        member,
                        administration.currentUserId,
                        administration.ownerId == administration.currentUserId,
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Kódy pro připojení',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text('Noví členové čekají na potvrzení práv administrátorem.'),
          const SizedBox(height: 10),
          _JoinCodeCard(
            title: 'Pouze čtení',
            description: 'Připojení tímto kódem vyžaduje potvrzení práv.',
            code: administration.readerCode,
            icon: Icons.visibility_outlined,
            onCopy: () => _copyCode(administration.readerCode),
            onEdit: () => _editCode('reader', administration.readerCode),
          ),
          _JoinCodeCard(
            title: 'Čtení a editace',
            description: 'Připojení tímto kódem vyžaduje potvrzení práv.',
            code: administration.editorCode,
            icon: Icons.edit_outlined,
            onCopy: () => _copyCode(administration.editorCode),
            onEdit: () => _editCode('editor', administration.editorCode),
          ),
          const SizedBox(height: 18),
          Text('Členové týmu', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'Administrátoři potvrzují práva nových členů a mohou je později měnit.',
          ),
          const SizedBox(height: 10),
          ...members.map(
            (member) => _memberCard(
              member,
              administration.currentUserId,
              administration.ownerId == administration.currentUserId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberCard(
    TeamMemberApiModel member,
    int currentUserId,
    bool viewerIsOwner,
  ) {
    final isCurrentUser = member.userId == currentUserId;
    return Card(
      color: _highlightedRoleId == member.userTeamRoleId
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            UserAvatar(
              userId: member.userId,
              radius: 18,
              fallback: Icon(member.owner ? Icons.star : Icons.person_outline),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.userName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (!member.roleApproved)
                    Text(
                      'Čeká na potvrzení práv',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (member.hidden)
                    Text(
                      'Skrytý uživatel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (member.mail.isNotEmpty)
                    Text(
                      member.mail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    member.owner
                        ? 'Zakladatel · Administrátor'
                        : member.roleLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    member.lastLoginAt == null
                        ? 'Poslední přihlášení: bez záznamu'
                        : 'Poslední přihlášení: ${DateFormat('d. M. y HH:mm').format(member.lastLoginAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (member.owner || isCurrentUser)
              const Tooltip(
                message: 'Tato administrátorská práva nelze změnit',
                child: Icon(Icons.lock_outline, size: 18),
              ),
            if (!member.owner && !isCurrentUser && !member.roleApproved)
              Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            if (!member.owner && !isCurrentUser)
              PopupMenuButton<String>(
                tooltip: 'Možnosti uživatele',
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  if (!member.owner && !isCurrentUser) ...const [
                    PopupMenuItem(value: 'VIEWER', child: Text('Bez práv')),
                    PopupMenuItem(value: 'READER', child: Text('Pouze čtení')),
                    PopupMenuItem(
                      value: 'EDITOR',
                      child: Text('Čtení a editace'),
                    ),
                    PopupMenuItem(value: 'ADMIN', child: Text('Administrátor')),
                  ],
                  if (viewerIsOwner && !member.owner) ...[
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'visibility',
                      child: Text(
                        member.hidden ? 'Odkrýt uživatele' : 'Skrýt uživatele',
                      ),
                    ),
                  ],
                ],
                onSelected: (action) {
                  if (action == 'visibility') {
                    _toggleMemberVisibility(member);
                  } else if (action != member.role || !member.roleApproved) {
                    _confirmRoleChange(member, action);
                  }
                },
              ),
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
                  : const Text('Uložit tým'),
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

  Future<void> _toggleMemberVisibility(TeamMemberApiModel member) async {
    final hidden = !member.hidden;
    await _runMutation(
      () => ref
          .read(teamAdministrationRepositoryProvider)
          .updateMemberVisibility(member.userTeamRoleId, hidden),
      hidden
          ? 'Uživatel ${member.userName} byl skrytý.'
          : 'Uživatel ${member.userName} je znovu viditelný.',
    );
  }

  Future<void> _runMutation(
    Future<TeamAdministrationApiModel> Function() mutation,
    String successMessage,
  ) async {
    try {
      await mutation();
      ref.invalidate(teamAdministrationProvider);
      ref.invalidate(homeNotifierProvider);
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
    case 'VIEWER':
      return 'bez práv';
    default:
      return role;
  }
}
