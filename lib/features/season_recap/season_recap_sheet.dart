import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'season_recap_data.dart';

Future<void> showSeasonRecap(BuildContext context, int id) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      builder: (_) => FractionallySizedBox(
        heightFactor: .94,
        child: SeasonRecapSheet(id: id),
      ),
    );

class SeasonRecapSheet extends ConsumerStatefulWidget {
  final int id;
  const SeasonRecapSheet({super.key, required this.id});
  @override
  ConsumerState<SeasonRecapSheet> createState() => _SeasonRecapSheetState();
}

class _SeasonRecapSheetState extends ConsumerState<SeasonRecapSheet> {
  final _controller = PageController();
  final _pageScrollControllers = <int, ScrollController>{};
  SeasonRecap? _recap;
  bool _failed = false;
  bool _markFailed = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final recap = await ref.read(seasonRecapApiProvider).detail(widget.id);
      if (!mounted) return;
      if (recap.pages.isEmpty) throw StateError('Prázdný souhrn');
      setState(() => _recap = recap);
      // Opening counts only once content is actually visible, not on a failed GET.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _markOpened();
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _markOpened() async {
    try {
      await ref.read(seasonRecapApiProvider).opened(widget.id);
      if (!mounted) return;
      setState(() => _markFailed = false);
    } catch (error, stack) {
      debugPrint('Season recap ${widget.id}: uložení přečtení selhalo: $error');
      debugPrintStack(stackTrace: stack);
      if (mounted) setState(() => _markFailed = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _pageScrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _index != index) return;
      final scroll = _pageScrollControllers[index];
      if (scroll != null && scroll.hasClients) scroll.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recap = _recap;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recap?.seasonName ?? 'Sezonní souhrn',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Zavřít',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            if (recap != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: List.generate(
                    recap.pages.length,
                    (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: LinearProgressIndicator(
                          value: i <= _index ? 1 : 0,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_markFailed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Přečtení se nepodařilo uložit.'),
                      ),
                      TextButton(
                        onPressed: _markOpened,
                        child: const Text('Znovu'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: recap.pages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (_, index) => _RecapPageView(
                    page: recap.pages[index],
                    scrollController: _pageScrollControllers.putIfAbsent(
                      index,
                      () => ScrollController(keepScrollOffset: false),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Předchozí strana',
                      onPressed: _index == 0
                          ? null
                          : () => _controller.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        '${_index + 1} / ${recap.pages.length}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (_index == recap.pages.length - 1) {
                          Navigator.pop(context);
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      child: Text(
                        _index == recap.pages.length - 1 ? 'Hotovo' : 'Další',
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: _failed
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Souhrn se nepodařilo načíst.'),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Zkusit znovu'),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecapPageView extends StatelessWidget {
  final RecapPage page;
  final ScrollController scrollController;
  const _RecapPageView({required this.page, required this.scrollController});

  IconData get _icon => switch (page.kind) {
    'drinks' || 'drink_match' => Icons.sports_bar,
    'fines' => Icons.savings_outlined,
    'goals' => Icons.sports_soccer,
    'achievements' => Icons.emoji_events_outlined,
    'steps' => Icons.directions_walk,
    'footbar' => Icons.speed,
    'attendance' => Icons.groups_outlined,
    _ => Icons.auto_awesome,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formatter = NumberFormat('#,##0.#', 'cs_CZ');
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.surface],
        ),
      ),
      child: SingleChildScrollView(
        key: ValueKey('recap-${page.kind}'),
        controller: scrollController,
        primary: false,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, size: 52, color: colors.onPrimaryContainer),
            const SizedBox(height: 20),
            Text(
              page.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(page.text, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            for (final metric in page.metrics)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(metric.label, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 6),
                        Text(
                          metric.value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            for (final board in page.boards) ...[
              const SizedBox(height: 16),
              Text(board.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              if (board.rows.isEmpty) const Text('Zatím bez dat.'),
              for (final row in board.rows)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: row.mine
                        ? colors.secondaryContainer
                        : colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: row.mine
                        ? Border.all(color: colors.secondary, width: 2)
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${row.rank}.',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${row.name}${row.mine ? ' · ty' : ''}',
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              '${formatter.format(row.value)} ${board.unit}',
                            ),
                          ],
                        ),
                      ),
                      if (row.rank == 1)
                        const Icon(Icons.emoji_events_outlined, size: 20),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
