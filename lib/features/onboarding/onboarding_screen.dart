import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/repository/exception/field_validation_exception.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/features/home/repository/home_repository.dart';
import 'package:trus_app/features/home/controller/home_notifier.dart';
import 'package:trus_app/features/notification/repository/notification_api_service.dart';
import 'package:trus_app/features/notification/push/controller/enabled_notifications_notifier.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/steps/controller/step_controller.dart';
import 'package:trus_app/features/user/controller/view_user_notifier.dart';
import 'package:trus_app/common/utils/web_view_browser.dart';
import 'package:trus_app/features/footbar/controller/footbar_connect_notifier.dart';
import 'package:trus_app/features/footbar/repository/footbar_repository.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';
import 'package:trus_app/models/api/notification/push/notification_type.dart';
import 'onboarding_permissions.dart';
import 'onboarding_repository.dart';
import 'onboarding_entry.dart';

String onboardingKey(WidgetRef ref) =>
    '${ref.read(authRepositoryProvider).returnUserId()}:${ref.read(globalVariablesControllerProvider).appTeam?.id}';

Future<void> openOnboarding(
  BuildContext context,
  WidgetRef ref, {
  bool registration = false,
}) async {
  final key = onboardingKey(ref);
  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingEntry(),
        fullscreenDialog: true,
      ),
    );
    if (!context.mounted) return;
    ref.invalidate(onboardingProgressProvider(key));
    if (!registration) {
      await ref.read(homeNotifierProvider.notifier).load(background: true);
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Průvodce se nepodařilo načíst. Zkus to prosím znovu.'),
        ),
      );
    }
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  final OnboardingProgress initial;
  const OnboardingScreen({super.key, required this.initial});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late int _index;
  bool _busy = false;
  String? _error;
  OnboardingProfiles? _profiles;
  List<EnabledPushNotification>? _notifications;
  final _name = TextEditingController();
  final _search = TextEditingController();
  DateTime? _birthday;
  bool _fan = false;
  bool _create = false;
  int? _selected;
  int? _footballPlayerId;
  int _loadGeneration = 0;
  OnboardingStep get _step => OnboardingStep.values[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.initial.nextIndex < 0 ? 0 : widget.initial.nextIndex;
    Future.microtask(_loadStep);
  }

  @override
  void dispose() {
    _name.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on FieldValidationException catch (error) {
      if (mounted) {
        setState(
          () => _error =
              error.fields
                  ?.map((f) => f.message)
                  .whereType<String>()
                  .join('\n') ??
              'Zkontroluj vyplněné údaje.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Akci se nepodařilo dokončit. Zkus to znovu, nebo krok přeskoč.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadStep() async {
    if (!mounted) return;
    final generation = ++_loadGeneration;
    final step = _step;
    setState(() => _error = null);
    // Reads never block Skip/Later. Ignore late replies from a skipped step.
    try {
      if (step == OnboardingStep.profile) {
        final profiles = await ref
            .read(onboardingRepositoryProvider)
            .profiles();
        if (!mounted || generation != _loadGeneration) return;
        setState(() {
          _profiles = profiles;
          _selected = profiles.currentPlayer?.id;
          if (_name.text.isEmpty) _name.text = profiles.name;
        });
      } else if (step == OnboardingStep.notifications &&
          _notifications == null) {
        final items = await ref
            .read(notificationApiServiceProvider)
            .getEnabledNotifications();
        if (mounted && generation == _loadGeneration) {
          setState(() => _notifications = items);
        }
      }
    } catch (_) {
      if (mounted && generation == _loadGeneration) {
        setState(
          () => _error =
              'Akci se nepodařilo dokončit. Zkus to znovu, nebo krok přeskoč.',
        );
      }
    }
  }

  Future<void> _next({bool complete = false}) async {
    if (complete) await ref.read(onboardingRepositoryProvider).advance(_step);
    if (!mounted) return;
    if (_index == OnboardingStep.values.length - 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index++;
      _error = null;
    });
    unawaited(_loadStep());
  }

  Future<void> _saveProfile() async {
    if (_profiles == null) return;
    if (_profiles!.currentPlayer != null) {
      await _next(complete: true);
      return;
    }
    if (_create && (_name.text.trim().isEmpty || _birthday == null)) {
      setState(() => _error = 'Vyplň jméno nebo přezdívku a datum narození.');
      return;
    }
    if (!_create && _selected == null) {
      setState(() => _error = 'Musíš si vybrat hráče.');
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Je to opravdu tvůj profil?'),
        content: Text(
          _create
              ? 'Vytvořit a propojit profil „${_name.text.trim()}“?'
              : 'Propojit účet s profilem „${_profiles!.candidates.firstWhere((c) => c.player.id == _selected).player.name}“? Vyber pouze vlastní profil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Zpět'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ano, to jsem já'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final player = await ref
        .read(onboardingRepositoryProvider)
        .pair(
          playerId: _create ? null : _selected,
          name: _name.text.trim(),
          birthday: _birthday,
          fan: _fan,
          footballPlayerId: _create ? _footballPlayerId : null,
        );
    if (!mounted) return;
    ref.read(globalVariablesControllerProvider).setPlayerApiModel(player);
    ref.read(globalVariablesProvider.notifier).setPlayer(player);
    ref.read(playerRepositoryProvider).invalidateList();
    ref.read(homeRepositoryProvider).invalidateSetup();
    ref.invalidate(viewUserNotifierProvider);
    await _next(complete: true);
  }

  Future<void> _saveNotifications() async {
    final items = _notifications;
    if (items == null) return;
    // Save category choices BEFORE allowing delivery at OS level.
    await ref
        .read(notificationApiServiceProvider)
        .editNotificationsPermit(items);
    ref.invalidate(enabledNotificationsNotifierProvider);
    if (items.any((n) => n.type == NotificationType.global && n.enabled)) {
      final allowed = await ref
          .read(onboardingPermissionsProvider)
          .notifications();
      if (!allowed) {
        if (mounted) {
          setState(
            () => _error =
                'Volby jsou uložené, ale systém oznámení nepovolil. Povolit je můžeš později v nastavení telefonu, nebo teď krok přeskoč.',
          );
        }
        return;
      }
    }
    if (mounted) await _next(complete: true);
  }

  Future<void> _enableSteps() async {
    if (!await ref.read(onboardingPermissionsProvider).steps()) {
      if (mounted) {
        setState(
          () => _error =
              'Přístup ke krokům nebyl udělen. Zkontroluj Health Connect / Zdraví v telefonu, nebo krok přeskoč.',
        );
      }
      return;
    }
    if (!mounted) return;
    ref.invalidate(stepControllerProvider);
    await _next(complete: true);
  }

  Future<void> _footbar() async {
    // No MainScreen/UI-effect host exists yet during registration. Run OAuth
    // directly and await the exchange before querying the connection status.
    final repository = ref.read(footbarRepositoryProvider);
    final url = await repository.api.connectToFootbar();
    if (!mounted) return;
    String? returnedCode;
    await openFootbarWebView(url, context, (code) {
      returnedCode = code;
    });
    if (!mounted || returnedCode == null) return;
    if (!await repository.api.exchangeCode(returnedCode!)) {
      throw StateError('Footbar exchange failed');
    }
    if (!mounted) return;
    repository.invalidateProfile();
    ref.invalidate(footbarConnectNotifierProvider);
    final profile = await repository.fetchProfile();
    if (!mounted) return;
    if (profile.active) {
      await _next(complete: true);
    } else {
      setState(
        () => _error =
            'Footbar zatím není propojený. Můžeš to zkusit znovu nebo krok přeskočit.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Kdo jsi v týmu?',
      'Co v appce najdeš',
      'Oznámení podle tebe',
      'Každý krok se počítá',
      'Máš Footbar?',
    ];
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        extendBody: false,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text('Vítej v Trusí appce'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Později'),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(value: (_index + 1) / titles.length),
              Expanded(
                child: ClipRect(
                  child: ListView(
                    key: const ValueKey('onboarding-list'),
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Krok ${_index + 1} z ${titles.length}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        titles[_index],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ..._content(),
                    ],
                  ),
                ),
              ),
              // Errors belong next to the action, never below a long player list.
              if (_error != null)
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        key: const ValueKey('onboarding-validation'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_error != null &&
                  (_profiles == null ||
                      (_step == OnboardingStep.notifications &&
                          _notifications == null)))
                TextButton(
                  onPressed: _busy ? null : _loadStep,
                  child: const Text('Znovu načíst'),
                ),
              if (_busy) const LinearProgressIndicator(),
              Material(
                key: const ValueKey('onboarding-footer'),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: 8,
                    overflowSpacing: 8,
                    children: [
                      if (_index > 0)
                        IconButton(
                          tooltip: 'Předchozí krok',
                          onPressed: _busy
                              ? null
                              : () => _run(() async {
                                  setState(() => _index--);
                                  unawaited(_loadStep());
                                }),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      TextButton(
                        onPressed: _busy ? null : () => _run(() => _next()),
                        child: const Text('Přeskočit'),
                      ),
                      FilledButton(
                        onPressed:
                            _busy ||
                                (_step == OnboardingStep.profile &&
                                    _profiles == null) ||
                                (_step == OnboardingStep.notifications &&
                                    _notifications == null)
                            ? null
                            : () => _run(() async {
                                switch (_step) {
                                  case OnboardingStep.profile:
                                    await _saveProfile();
                                  case OnboardingStep.intro:
                                    await _next(complete: true);
                                  case OnboardingStep.notifications:
                                    await _saveNotifications();
                                  case OnboardingStep.steps:
                                    await _enableSteps();
                                  case OnboardingStep.footbar:
                                    await _footbar();
                                }
                              }),
                        child: Text(switch (_step) {
                          OnboardingStep.profile => 'Pokračovat',
                          OnboardingStep.intro => 'Rozumím',
                          OnboardingStep.notifications => 'Uložit volby',
                          OnboardingStep.steps => 'Povolit kroky',
                          OnboardingStep.footbar => 'Propojit Footbar',
                        }, softWrap: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content() => switch (_step) {
    OnboardingStep.profile => _profileContent(),
    OnboardingStep.intro => const [
      ListTile(
        leading: Icon(Icons.event_available),
        title: Text('Zápasy a účast'),
        subtitle: Text(
          'Na přehledu najdeš příští zápas. Dej týmu vědět, jestli dorazíš.',
        ),
      ),
      ListTile(
        leading: Icon(Icons.bar_chart),
        title: Text('Týmové statistiky'),
        subtitle: Text(
          'Prohlížej výsledky, góly i týmové záznamy a sleduj vlastní statistiky.',
        ),
      ),
      ListTile(
        leading: Icon(Icons.emoji_events_outlined),
        title: Text('Achievementy'),
        subtitle: Text(
          'Odznaky získáváš za splněné výzvy a milníky. Na svém profilu uvidíš získané odznaky i postup k dalším.',
        ),
      ),
      Text(
        'Všechno si můžeš projít vlastním tempem. Nastavení najdeš pod svým účtem.',
      ),
    ],
    OnboardingStep.notifications => [
      const Text(
        'Vyber si, co tě zajímá. Až uložíš volby, požádáme telefon o povolení oznámení. Nastavení můžeš kdykoliv změnit.',
      ),
      if (_notifications == null && _error == null)
        const Center(child: CircularProgressIndicator()),
      for (final item in _notifications ?? <EnabledPushNotification>[])
        if (item.type != NotificationType.unknown)
          SwitchListTile(
            title: Text(item.listViewTitle()),
            value: item.enabled,
            onChanged:
                _busy ||
                    (item.type != NotificationType.global &&
                        !(_notifications!.any(
                          (n) => n.type == NotificationType.global && n.enabled,
                        )))
                ? null
                : (value) => setState(() {
                    _notifications = _notifications!
                        .map(
                          (n) =>
                              n.id == item.id ? n.copyWith(enabled: value) : n,
                        )
                        .toList();
                  }),
          ),
    ],
    OnboardingStep.steps => const [
      Icon(Icons.directions_walk, size: 64),
      SizedBox(height: 16),
      Text(
        'Se souhlasem načteme počty kroků z aplikace Zdraví (iPhone) nebo Health Connect (Android). Na Androidu požádáme také o přístup k fyzické aktivitě.',
      ),
      SizedBox(height: 12),
      Text(
        'Denní součty kroků odešleme do Trusí appky pro statistiky a týmový žebříček. Tvoje výsledky tak uvidí i ostatní v týmu. Nežádáme přístup k jiným zdravotním údajům.',
      ),
      SizedBox(height: 12),
      Text(
        'Zapnutí je dobrovolné. Souhlas můžeš později vypnout na obrazovce Kroky. Na iPhonu systém kvůli soukromí nepotvrdí, zda jsi čtení skutečně povolil; bez něj se kroky nenačtou.',
      ),
    ],
    OnboardingStep.footbar => [
      const Icon(Icons.sports_soccer, size: 64),
      const SizedBox(height: 16),
      const Text(
        'Pokud používáš senzor Footbar, propoj svůj účet. Appka pak automaticky načte historii a po zápasech zkusí doplnit nové tréninky.',
      ),
      const SizedBox(height: 12),
      const Text(
        'Footbar není potřeba pro běžné používání aplikace ani pro počítání kroků.',
      ),
      TextButton(
        onPressed: _busy ? null : () => _run(() => _next(complete: true)),
        child: const Text('Footbar nemám – dokončit'),
      ),
    ],
  };

  List<Widget> _profileContent() {
    final profiles = _profiles;
    if (profiles == null) return [const Text('Načítáme profily tvého týmu…')];
    if (profiles.currentPlayer != null) {
      return [
        ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(profiles.currentPlayer!.name),
          subtitle: const Text('Tvůj účet už je propojený.'),
        ),
        const Text(
          'Změnu propojení můžeš později provést v nastavení uživatele.',
        ),
      ];
    }
    final candidates = profiles.candidates
        .where(
          (c) => c.player.name.toLowerCase().contains(
            _search.text.trim().toLowerCase(),
          ),
        )
        .toList();
    return [
      const Text(
        'Vyber vlastní profil hráče nebo fanouška. Podobná jména nabízíme jako tip, propojení vždy potvrdíš sám.',
      ),
      if (!_create) ...[
        TextField(
          controller: _search,
          enabled: !_busy,
          decoration: _inputDecoration('Hledat jméno nebo přezdívku'),
          onChanged: (_) => setState(() {}),
        ),
        for (final candidate in candidates)
          ListTile(
            enabled: !candidate.occupied && !_busy,
            selected: candidate.player.id == _selected,
            leading: Icon(
              candidate.occupied
                  ? Icons.lock_outline
                  : candidate.player.id == _selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
            ),
            title: Text(candidate.player.name),
            subtitle: Text(
              candidate.occupied
                  ? 'Už propojeno'
                  : '${candidate.player.fan ? 'Fanoušek' : 'Hráč'}${candidate.score >= 65 ? ' • Možná jsi to ty' : ''}',
            ),
            onTap: candidate.occupied || _busy
                ? null
                : () => setState(() {
                    _selected = candidate.player.id;
                    final footballId = candidate.player.footballPlayer?.id;
                    _footballPlayerId =
                        profiles.footballPlayers.any(
                          (football) => football.id == footballId,
                        )
                        ? footballId
                        : null;
                    _error = null;
                  }),
          ),
        if (candidates.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Žádný odpovídající profil. Můžeš vytvořit nový.'),
          ),
      ],
      SwitchListTile(
        title: const Text('Nejsem v seznamu – vytvořit nový profil'),
        value: _create,
        onChanged: _busy
            ? null
            : (v) => setState(() {
                _create = v;
                _footballPlayerId = null;
                _error = null;
              }),
      ),
      if (_create) ...[
        TextField(
          controller: _name,
          enabled: !_busy,
          maxLength: 100,
          key: const ValueKey('onboarding-player-name'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: _inputDecoration('Jméno nebo přezdívka'),
        ),
        SwitchListTile(
          title: const Text('Jsem fanoušek'),
          subtitle: const Text('Vypnutím zvolíš hráče.'),
          value: _fan,
          onChanged: _busy ? null : (v) => setState(() => _fan = v),
        ),
        ListTile(
          title: const Text('Datum narození'),
          subtitle: Text(
            _birthday == null
                ? 'Vybrat datum'
                : '${_birthday!.day}. ${_birthday!.month}. ${_birthday!.year}',
          ),
          trailing: const Icon(Icons.calendar_month),
          onTap: _busy
              ? null
              : () async {
                  final now = DateTime.now();
                  final day = await showDatePicker(
                    context: context,
                    initialDate: _birthday ?? DateTime(now.year - 20),
                    firstDate: DateTime(now.year - 120, now.month, now.day),
                    lastDate: now,
                  );
                  if (day != null && mounted) setState(() => _birthday = day);
                },
        ),
        const Text(
          'Datum narození bude součástí týmového profilu, například pro připomínání narozenin.',
        ),
      ],
      if (_create && profiles.footballPlayers.isNotEmpty) ...[
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          key: ValueKey('football-$_selected-$_create-$_footballPlayerId'),
          initialValue: _footballPlayerId ?? 0,
          isExpanded: true,
          decoration: _inputDecoration(
            'Propojit s fotbalovým hráčem (volitelné)',
          ),
          items: [
            const DropdownMenuItem(value: 0, child: Text('Zatím nepropojovat')),
            for (final football in profiles.footballPlayers)
              DropdownMenuItem(
                value: football.id,
                enabled:
                    football.linkedPlayerId == null ||
                    (!_create && football.linkedPlayerId == _selected),
                child: Text(
                  '${football.name}${football.linkedPlayerId != null && (_create || football.linkedPlayerId != _selected) ? ' · Už propojeno' : ''}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: _busy
              ? null
              : (id) => setState(() => _footballPlayerId = id == 0 ? null : id),
        ),
        const SizedBox(height: 8),
        const Text(
          'Propojí tvůj profil s fotbalovými statistikami. Nabízíme hráče příslušného týmu, včetně bývalých.',
        ),
      ],
    ];
  }

  InputDecoration _inputDecoration(String label) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      labelStyle: TextStyle(color: colors.onSurface),
      floatingLabelStyle: TextStyle(color: colors.primary),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }
}
