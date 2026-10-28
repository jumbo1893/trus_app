import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/controller/fine_match_notifier.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_api_service.dart';
import 'package:trus_app/features/fine/match/state/fine_match_state.dart';
import 'package:trus_app/features/fine/match/widget/quick_fine_list.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_api_model.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_list.dart';

class FineTypeGrid extends ConsumerStatefulWidget {
  const FineTypeGrid({super.key});

  @override
  ConsumerState<FineTypeGrid> createState() => _FineTypeGridState();
}

class _LastFineAddition {
  const _LastFineAddition(this.matchId, this.fineId, this.playerIds);

  final int matchId;
  final int fineId;
  final List<int> playerIds;
}

class _FineTypeGridState extends ConsumerState<FineTypeGrid>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  late final AnimationController _deleteWiggle;
  int _currentTab = 0;
  List<FineApiModel> _fines = [];
  final Map<int, Map<int, int>> _counts = {};
  int? _countMatchId;
  int? _expandedFineId;
  _LastFineAddition? _lastAddition;
  bool _saving = false;
  bool _showOther = false;
  bool _showInactive = false;
  bool _deleteMode = false;
  List<int>? _expandedPlayerOrder;
  final Set<int> _previouslyCollapsedFines = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: fineCategoryOrder.length, vsync: this);
    _deleteWiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );
    _tabs.addListener(_handleTabChange);
    Future.microtask(_loadFines);
  }

  void _handleTabChange() {
    if (!mounted || _tabs.index == _currentTab) return;
    setState(() {
      _currentTab = _tabs.index;
      _expandedFineId = null;
      _showOther = false;
      _showInactive = false;
      _expandedPlayerOrder = null;
      _deleteMode = false;
      _deleteWiggle.stop();
      _deleteWiggle.reset();
    });
  }

  @override
  void dispose() {
    _tabs.removeListener(_handleTabChange);
    _tabs.dispose();
    _deleteWiggle.dispose();
    super.dispose();
  }

  Future<void> _loadFines() async {
    try {
      final fines = await ref.read(fineApiServiceProvider).getFines();
      if (!mounted) return;
      setState(() {
        _fines = fines.where((fine) => !fine.inactive).toList();
      });
    } catch (_) {
      _showError('Pokuty se nepodařilo načíst.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  int _count(FineMatchState state, int playerId, int fineId) {
    final initial =
        state.playerFineSummaryByPlayerId[playerId]?.fines
            .where((item) => item.fine.id == fineId)
            .fold<int>(0, (sum, item) => sum + item.count) ??
        0;
    return _counts[playerId]?[fineId] ?? initial;
  }

  Future<void> _applyFine(
    FineApiModel fine,
    List<PlayerApiModel> players, {
    bool remove = false,
  }) => _writeFine(
    fine,
    players.map((player) => player.id).whereType<int>().toList(),
    remove: remove,
  );

  Future<void> _writeFine(
    FineApiModel fine,
    List<int> playerIds, {
    bool remove = false,
    bool undo = false,
  }) async {
    final state = ref.read(fineMatchNotifierProvider);
    final matchId = state.selectedMatch?.id;
    final fineId = fine.id;
    if (_saving || matchId == null || fineId == null) return;
    final ids = playerIds.toSet().toList();
    if (remove) {
      ids.removeWhere((id) => _count(state, id, fineId) <= 0);
    }
    if (ids.isEmpty) return;
    if (undo &&
        (_lastAddition?.matchId != matchId ||
            _lastAddition?.fineId != fineId)) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(fineMatchApiServiceProvider)
          .addFines(
            ReceivedFineList(
              matchId: matchId,
              playerId: null,
              playerIdList: ids,
              fineList: [
                ReceivedFineApiModel(
                  matchId: matchId,
                  playerId: -1,
                  fine: fine,
                  fineNumber: remove ? -1 : 1,
                ),
              ],
            ),
            true,
          );
      if (!mounted ||
          ref.read(fineMatchNotifierProvider).selectedMatch?.id != matchId) {
        return;
      }
      setState(() {
        for (final id in ids) {
          final playerCounts = _counts.putIfAbsent(id, () => {});
          playerCounts[fineId] = _count(state, id, fineId) + (remove ? -1 : 1);
        }
        _lastAddition = remove
            ? null
            : _LastFineAddition(matchId, fineId, List.unmodifiable(ids));
      });
    } catch (_) {
      if (mounted &&
          ref.read(fineMatchNotifierProvider).selectedMatch?.id == matchId) {
        try {
          await ref
              .read(fineMatchNotifierProvider.notifier)
              .selectMatch(state.selectedMatch!);
          if (mounted) setState(_counts.clear);
        } catch (_) {
          // Síťová chyba nemusí znamenat, že server zápis neprovedl.
        }
      }
      _showError(
        'Výsledek zápisu není jistý. Zkontroluj počet pokut před opakováním.',
      );
      if (mounted) setState(() => _lastAddition = null);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _undoAddition(FineApiModel fine) async {
    final addition = _lastAddition;
    if (addition == null) return;
    await _writeFine(fine, addition.playerIds, remove: true, undo: true);
  }

  void _setDeleteMode(bool enabled) {
    setState(() => _deleteMode = enabled);
    if (enabled) {
      _deleteWiggle.repeat(reverse: true);
    } else {
      _deleteWiggle.stop();
      _deleteWiggle.reset();
    }
  }

  Widget _playerGrid(
    FineApiModel fine,
    List<PlayerApiModel> players,
    FineMatchState state,
  ) {
    final ordered = [...players];
    final order = _expandedPlayerOrder;
    if (order != null) {
      ordered.sort(
        (a, b) => order.indexOf(a.id!).compareTo(order.indexOf(b.id!)),
      );
    }
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, box) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Wrap(
          spacing: 6,
          runSpacing: 7,
          children: [
            for (var index = 0; index < ordered.length; index++)
              Builder(
                builder: (context) {
                  final player = ordered[index];
                  final count = _count(state, player.id!, fine.id!);
                  final selected = count > 0;
                  final button = ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: box.maxWidth),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFDCF3E7)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF34836B)
                              : colors.outlineVariant,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: _saving || (_deleteMode && !selected)
                              ? null
                              : () => _applyFine(fine, [
                                  player,
                                ], remove: _deleteMode),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  player.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: selected
                                        ? const Color(0xFF173D2F)
                                        : colors.onSurface,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (count > 1) ...[
                                  const SizedBox(width: 4),
                                  CircleAvatar(
                                    radius: 9,
                                    backgroundColor: const Color(0xFF26795A),
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                if (_deleteMode && selected) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Color(0xFF9B2929),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                  if (!_deleteMode || !selected) return button;
                  return AnimatedBuilder(
                    animation: _deleteWiggle,
                    builder: (context, child) => Transform.rotate(
                      angle:
                          (_deleteWiggle.value - 0.5) *
                          0.04 *
                          (index.isEven ? 1 : -1),
                      child: child,
                    ),
                    child: button,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _compactFineButton(
    String label,
    String tooltip,
    VoidCallback? onPressed,
  ) => Tooltip(
    message: tooltip,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
    ),
  );

  IconData _fineIcon(FineApiModel fine) => switch (fine.code) {
    'LATE_BEFORE_START' ||
    'LATE_AFTER_START' ||
    'LATE_AFTER_TEN_MINUTES' => Icons.schedule,
    'LATE_NOTICE' => Icons.notifications_outlined,
    'NO_SHOW' => Icons.person_off_outlined,
    'HANGOVER' => Icons.local_bar_outlined,
    'NO_FACEBOOK_RESPONSE' => Icons.question_answer_outlined,
    'GOAL' => Icons.sports_soccer,
    'HATTRICK' => Icons.looks_3_outlined,
    'OWN_GOAL' => Icons.swap_horiz,
    'MISSED_PENALTY' => Icons.sports_score_outlined,
    'OVERKICK' => Icons.north_east,
    'RABONA' || 'RABONA_GOAL' => Icons.auto_awesome_outlined,
    'YELLOW_CARD' => Icons.style_outlined,
    'RED_CARD' => Icons.report_outlined,
    'BATHROOM_DURING_MATCH' => Icons.wc_outlined,
    'ZERO_IN_MATCH' => Icons.exposure_zero,
    'LOSS_PLAYING' || 'LOSS_BY_FIVE_PLAYING' => Icons.trending_down,
    'ABSENT_WHEN_SEVEN_OR_FEWER' ||
    'ABSENT_LOSS' ||
    'ABSENT_WIN' ||
    'ABSENT_DRAW' => Icons.event_busy_outlined,
    'INCOMPLETE_EQUIPMENT' => Icons.checkroom_outlined,
    'NEW_BOOTS' => Icons.hiking_outlined,
    'FORGOTTEN_THINGS' => Icons.inventory_2_outlined,
    'THIRD_HALF' => Icons.sports_bar_outlined,
    'WEDDING' => Icons.favorite_outline,
    'ENGAGEMENT' => Icons.diamond_outlined,
    'CHILD_BORN_BOY' || 'CHILD_BORN_GIRL' => Icons.child_care_outlined,
    'PRESS_MENTION' => Icons.article_outlined,
    _ => Icons.receipt_long_outlined,
  };

  Widget _recipientPreview(List<PlayerApiModel> recipients) {
    if (recipients.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Zatím nikdo',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      );
    }
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final visible = <PlayerApiModel>[];
        var used = 0.0;
        final textStyle = Theme.of(context).textTheme.labelSmall!;
        for (final player in recipients) {
          final painter = TextPainter(
            text: TextSpan(text: player.name, style: textStyle),
            maxLines: 1,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final chipWidth = painter.width + 18;
          final remaining = recipients.length - visible.length - 1;
          final reserve = remaining > 0 ? 52.0 : 0.0;
          if (used + chipWidth + reserve > constraints.maxWidth) break;
          visible.add(player);
          used += chipWidth + 5;
        }
        final hidden = recipients.length - visible.length;
        return Row(
          children: [
            for (final player in visible) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(player.name, maxLines: 1, style: textStyle),
              ),
              const SizedBox(width: 5),
            ],
            if (hidden > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text('+$hidden', style: textStyle),
              ),
          ],
        );
      },
    );
  }

  Widget _fineCard(
    FineApiModel fine,
    FineMatchState state,
    List<PlayerApiModel> playing,
    List<PlayerApiModel> others,
    List<PlayerApiModel> inactive,
  ) {
    final expanded = _expandedFineId == fine.id;
    final allPlayers = [...playing, ...others, ...inactive];
    final recipients = allPlayers
        .where((player) => _count(state, player.id!, fine.id!) > 0)
        .toList();
    final canDelete = recipients.isNotEmpty;
    if (expanded && _deleteMode && !canDelete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_deleteMode || _expandedFineId != fine.id) return;
        final current = ref.read(fineMatchNotifierProvider);
        if (current.selectedMatch?.id != state.selectedMatch?.id) return;
        if (allPlayers.any(
          (player) => _count(current, player.id!, fine.id!) > 0,
        )) {
          return;
        }
        _setDeleteMode(false);
      });
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final totalAmount = allPlayers.fold<int>(
      0,
      (sum, player) => sum + _count(state, player.id!, fine.id!) * fine.amount,
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() {
              if (expanded) {
                _previouslyCollapsedFines.add(fine.id!);
                _expandedPlayerOrder = null;
                _deleteMode = false;
                _deleteWiggle.stop();
                _deleteWiggle.reset();
              } else {
                if (_expandedFineId != null) {
                  _previouslyCollapsedFines.add(_expandedFineId!);
                  _deleteMode = false;
                  _deleteWiggle.stop();
                  _deleteWiggle.reset();
                }
                final ordered = [...allPlayers];
                if (_previouslyCollapsedFines.contains(fine.id)) {
                  final originalOrder = {
                    for (var index = 0; index < allPlayers.length; index++)
                      allPlayers[index].id!: index,
                  };
                  ordered.sort((a, b) {
                    final byRecipient =
                        (_count(state, b.id!, fine.id!) > 0 ? 1 : 0).compareTo(
                          _count(state, a.id!, fine.id!) > 0 ? 1 : 0,
                        );
                    return byRecipient != 0
                        ? byRecipient
                        : originalOrder[a.id]!.compareTo(originalOrder[b.id]!);
                  });
                }
                _expandedPlayerOrder = ordered
                    .map((player) => player.id!)
                    .toList();
              }
              _expandedFineId = expanded ? null : fine.id;
              _showOther = false;
              _showInactive = false;
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF493820)
                          : const Color(0xFFFFF0D7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _fineIcon(fine),
                      size: 18,
                      color: dark
                          ? const Color(0xFFE8AE57)
                          : const Color(0xFFA85C00),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      fine.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (!expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 7),
              child: _recipientPreview(recipients),
            ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
                          child: Text(
                            '${fine.amount} Kč · celkem $totalAmount Kč',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                      const Text('Mazání'),
                      Switch.adaptive(
                        value: _deleteMode && canDelete,
                        onChanged: _saving || !canDelete
                            ? null
                            : _setDeleteMode,
                      ),
                    ],
                  ),
                  _playerGrid(fine, playing, state),
                  if (others.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _showOther = !_showOther;
                        if (!_showOther) _showInactive = false;
                      }),
                      icon: Icon(_showOther ? Icons.expand_less : Icons.add),
                      label: Text(
                        _showOther
                            ? 'Skrýt nehrající (${others.length})'
                            : 'Nehrající (${others.length})',
                      ),
                    ),
                  if (_showOther) _playerGrid(fine, others, state),
                  if (inactive.isNotEmpty && (_showOther || others.isEmpty))
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showInactive = !_showInactive),
                      icon: Icon(_showInactive ? Icons.expand_less : Icons.add),
                      label: Text(
                        _showInactive
                            ? 'Skrýt neaktivní (${inactive.length})'
                            : 'Neaktivní (${inactive.length})',
                      ),
                    ),
                  if (_showInactive && (_showOther || others.isEmpty))
                    _playerGrid(fine, inactive, state),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _compactFineButton(
                          '＋ Všem',
                          'Přidat pokutu všem zobrazeným hráčům',
                          _saving || _deleteMode
                              ? null
                              : () => _applyFine(fine, [
                                  ...playing,
                                  if (_showOther) ...others,
                                  if (_showInactive) ...inactive,
                                ]),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 4,
                        child: _compactFineButton(
                          '＋ Hrajícím',
                          'Přidat pokutu hrajícím',
                          _saving || _deleteMode
                              ? null
                              : () => _applyFine(fine, playing),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 5,
                        child: _compactFineButton(
                          '＋ Nehrajícím',
                          'Přidat pokutu zobrazeným nehrajícím',
                          _saving || _deleteMode
                              ? null
                              : () => _applyFine(fine, [
                                  if (_showOther) ...others,
                                  if (_showInactive) ...inactive,
                                ]),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 3,
                        child: _compactFineButton(
                          'Zpět',
                          'Vrátit poslední přidání této pokuty',
                          _saving ||
                                  _lastAddition?.matchId !=
                                      state.selectedMatch?.id ||
                                  _lastAddition?.fineId != fine.id
                              ? null
                              : () => _undoAddition(fine),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryList(
    String category,
    FineMatchState state,
    List<PlayerApiModel> playing,
    List<PlayerApiModel> others,
    List<PlayerApiModel> inactive,
  ) {
    final group = _fines.where((fine) => fine.category == category).toList()
      ..sort((a, b) {
        final name = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return name != 0 ? name : (a.id ?? 0).compareTo(b.id ?? 0);
      });
    if (group.isEmpty) {
      return const Center(child: Text('V této kategorii zatím nejsou pokuty.'));
    }
    return ListView.builder(
      key: PageStorageKey(category),
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
      itemCount: group.length,
      itemBuilder: (context, index) =>
          _fineCard(group[index], state, playing, others, inactive),
    );
  }

  Widget _categoryTabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const overlap = 6.0;
        final total = fineCategoryOrder.length;
        final width = constraints.maxWidth.clamp(0.0, 620.0);
        final neighborIndex = _currentTab < total - 1
            ? _currentTab + 1
            : _currentTab - 1;
        final availableWidth = width + (total - 1) * overlap;
        final selectedWidth = availableWidth * 0.40;
        final neighborWidth = availableWidth * 0.30;
        final compactWidth =
            (availableWidth - selectedWidth - neighborWidth) / (total - 2);
        final tabWidths = [
          for (var index = 0; index < total; index++)
            index == _currentTab
                ? selectedWidth
                : index == neighborIndex
                ? neighborWidth
                : compactWidth,
        ];
        final positions = <double>[];
        var left = 0.0;
        for (var index = 0; index < total; index++) {
          positions.add(left);
          left += tabWidths[index] - overlap;
        }
        final paintOrder = [
          for (var index = 0; index < total; index++)
            if (index != _currentTab) index,
          _currentTab,
        ];
        final colors = Theme.of(context).colorScheme;
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: width,
            height: 46,
            child: Stack(
              children: [
                for (final index in paintOrder)
                  AnimatedPositioned(
                    key: ValueKey(fineCategoryOrder[index]),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: positions[index],
                    top: 0,
                    width: tabWidths[index],
                    height: 44,
                    child: Material(
                      color: index == _currentTab
                          ? colors.primaryContainer
                          : colors.surfaceContainerHigh,
                      elevation: index == _currentTab ? 3 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: index == _currentTab
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () => _tabs.animateTo(
                          index,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                        ),
                        child: Semantics(
                          label:
                              '${fineCategoryTitles[fineCategoryOrder[index]]}, '
                              '${index + 1} z $total',
                          selected: index == _currentTab,
                          button: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: index == _currentTab
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fineCategoryTitles[fineCategoryOrder[index]]!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${index + 1}/$total',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      index == neighborIndex
                                          ? fineCategoryTitles[fineCategoryOrder[index]]!
                                          : '${index + 1}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fineMatchNotifierProvider);
    if (_countMatchId != state.selectedMatch?.id) {
      _countMatchId = state.selectedMatch?.id;
      _counts.clear();
      _lastAddition = null;
      _expandedPlayerOrder = null;
      _previouslyCollapsedFines.clear();
      _deleteMode = false;
      _deleteWiggle.stop();
      _deleteWiggle.reset();
    }
    final playing = state.playersInMatch
        .where((player) => !player.fan)
        .toList();
    final others = state.otherPlayers
        .where((player) => !player.fan && player.active)
        .toList();
    final inactive = state.otherPlayers
        .where((player) => !player.fan && !player.active)
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
          child: _categoryTabs(),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Row(
            children: [
              Expanded(child: Text('Klepni na hráče pro přidání pokuty')),
            ],
          ),
        ),
        if (_saving) const LinearProgressIndicator(),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              for (final category in fineCategoryOrder)
                _categoryList(category, state, playing, others, inactive),
            ],
          ),
        ),
      ],
    );
  }
}
