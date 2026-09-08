import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/general/global_variables_controller.dart';

final entryDraftStoreProvider = Provider((ref) => EntryDraftStore());

class EntryDraftStore {
  Future<void> _pending = Future.value();
  Future<String> _key(String context) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    if (email == null || email.isEmpty)
      throw StateError('Chybí přihlášený účet');
    return 'entry-draft-v1:${base64Url.encode(utf8.encode(email))}:$context';
  }

  Future<Map<String, dynamic>?> read(String context) async {
    await _pending;
    final key = await _key(context);
    final text = (await SharedPreferences.getInstance()).getString(key);
    return text == null ? null : jsonDecode(text) as Map<String, dynamic>;
  }

  Future<void> write(String context, Map<String, dynamic>? value) {
    final operation = _pending.catchError((_) {}).then((_) async {
      final key = await _key(context);
      final prefs = await SharedPreferences.getInstance();
      final success = value == null
          ? await prefs.remove(key)
          : await prefs.setString(key, jsonEncode(value));
      if (!success) throw StateError('Koncept se nepodařilo uložit');
    });
    _pending = operation.catchError((_) {});
    return operation;
  }
}

Future<void> clearEntryDraft(Ref ref, String draftId) async {
  try {
    await ref
        .read(entryDraftStoreProvider)
        .write(
          '${ref.read(globalVariablesControllerProvider).appTeam?.id}:$draftId',
          null,
        );
  } catch (_) {}
}

abstract class EntrySession {
  bool get dirty;
  Future<bool> confirmLeave();
}

final entrySessionsProvider = Provider((ref) => <String, EntrySession>{});

/// Persists numeric edits by stable row IDs, independently of list ordering.
class EntryDraftScope extends ConsumerStatefulWidget {
  final String screenId, draftId;
  final Map<String, int> values, baseline;
  final Map<String, String> labels;
  final bool loaded;
  final bool Function() hasChanges;
  final ValueChanged<Map<String, int>> restore;
  final Future<void> Function() save;
  final Widget child;
  const EntryDraftScope({
    super.key,
    required this.screenId,
    required this.draftId,
    required this.values,
    required this.baseline,
    required this.labels,
    required this.loaded,
    required this.restore,
    required this.save,
    required this.hasChanges,
    required this.child,
  });
  @override
  ConsumerState<EntryDraftScope> createState() => _EntryDraftScopeState();
}

class _EntryDraftScopeState extends ConsumerState<EntryDraftScope>
    implements EntrySession {
  late final Map<String, EntrySession> _sessions;
  late final EntryDraftStore _store;
  late final String _context;
  bool _ready = false, _loading = false, _diskFailed = false;
  bool _saving = false;
  @override
  bool get dirty => widget.loaded && widget.hasChanges();
  @override
  void initState() {
    super.initState();
    _sessions = ref.read(entrySessionsProvider);
    _store = ref.read(entryDraftStoreProvider);
    _context =
        '${ref.read(globalVariablesControllerProvider).appTeam?.id}:${widget.draftId}';
    _sessions[widget.screenId] = this;
    _schedule();
  }

  @override
  void didUpdateWidget(covariant EntryDraftScope old) {
    super.didUpdateWidget(old);
    if (!_ready) {
      _schedule();
    } else if (!mapEquals(old.values, widget.values) ||
        !mapEquals(old.baseline, widget.baseline)) {
      _persist();
    }
  }

  void _schedule() {
    if (_loading || !widget.loaded) return;
    _loading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Map<String, int> _numbers(dynamic raw) =>
      (raw as Map).map((k, v) => MapEntry(k as String, (v as num).toInt()));
  Future<void> _load() async {
    try {
      final saved = await _store.read(_context);
      if (!mounted) return;
      if (saved != null) {
        final values = _numbers(saved['values']);
        final baseline = _numbers(saved['baseline']);
        if (!mapEquals(values, widget.baseline)) {
          final conflict = !mapEquals(baseline, widget.baseline);
          final restore = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text('Obnovit rozepsaný zápis?'),
                content: Text(
                  conflict
                      ? 'Na serveru se údaje od rozepsání změnily. Obnovení přičte pouze tvoje neuložené změny k aktuálním počtům. Změny před uložením zkontroluj.'
                      : 'V telefonu je neuložený koncept tohoto zápisu. Chceš v něm pokračovat?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Zahodit koncept'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Obnovit'),
                  ),
                ],
              ),
            ),
          );
          if (!mounted) return;
          if (restore == true) {
            final restored = {...widget.values};
            for (final key in values.keys) {
              if (restored.containsKey(key) && baseline.containsKey(key)) {
                restored[key] = key == 'rewrite'
                    ? values[key]!.clamp(0, 1)
                    : (widget.baseline[key]! + values[key]! - baseline[key]!)
                          .clamp(0, 1000000);
              }
            }
            widget.restore(restored);
          } else {
            await _store.write(_context, null);
          }
        } else {
          await _store.write(_context, null);
        }
      }
    } catch (_) {
      _diskFailed = true;
    }
    if (!mounted) return;
    setState(() => _ready = true);
  }

  Future<void> _persist() async {
    if (!_ready) return;
    final payload = dirty
        ? <String, dynamic>{
            'values': {...widget.values},
            'baseline': {...widget.baseline},
            'updatedAt': DateTime.now().toIso8601String(),
          }
        : null;
    try {
      await _store.write(_context, payload);
    } catch (_) {
      if (mounted && !_diskFailed) setState(() => _diskFailed = true);
    }
  }

  @override
  Future<bool> confirmLeave() async {
    if (!dirty) return true;
    if (_saving) return false;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neuložené změny'),
        content: const Text('Chceš zápis před odchodem uložit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'stay'),
            child: const Text('Zůstat'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Zahodit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Uložit'),
          ),
        ],
      ),
    );
    if (!mounted || choice == null || choice == 'stay') return false;
    if (choice == 'discard') {
      widget.restore({...widget.baseline});
      try {
        await _store.write(_context, null);
      } catch (_) {}
      return true;
    }
    _saving = true;
    try {
      await widget.save();
      if (dirty) return false;
      try {
        await _store.write(_context, null);
      } catch (_) {}
      return true;
    } catch (_) {
      return false;
    } finally {
      _saving = false;
    }
  }

  @override
  void dispose() {
    if (identical(_sessions[widget.screenId], this))
      _sessions.remove(widget.screenId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changes = widget.values.entries
        .where((e) => widget.loaded && e.value != widget.baseline[e.key])
        .toList();
    return Column(
      children: [
        SizedBox(
          height: 48,
          width: double.infinity,
          child: TextButton.icon(
            onPressed: changes.isEmpty
                ? null
                : () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => SafeArea(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.5,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(
                              'Souhrn neuložených změn',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (_diskFailed)
                              const Text(
                                'Koncept v telefonu není dostupný. Před odchodem zápis ulož.',
                              ),
                            for (final e in changes)
                              ListTile(
                                title: Text(widget.labels[e.key] ?? e.key),
                                subtitle: Text(
                                  e.key == 'rewrite'
                                      ? (e.value == 1 ? 'Zapnuto' : 'Vypnuto')
                                      : '${e.value - (widget.baseline[e.key] ?? 0) >= 0 ? '+' : ''}${e.value - (widget.baseline[e.key] ?? 0)} · celkem ${e.value}',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
            icon: Icon(
              changes.isEmpty
                  ? Icons.check
                  : (_diskFailed
                        ? Icons.warning_amber
                        : Icons.receipt_long_outlined),
              size: 18,
            ),
            label: Text(
              changes.isEmpty
                  ? 'Žádné neuložené změny'
                  : 'Neuložené změny (${changes.length}) · Souhrn',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          child: AbsorbPointer(
            absorbing: widget.loaded && !_ready,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
