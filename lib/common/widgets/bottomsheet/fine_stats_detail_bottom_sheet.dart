import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/models/api/receivedfine/stats/received_fine_stats_detail_models.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class FineStatsDetailBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final ReceivedFineStatsDetailResponse response;

  const FineStatsDetailBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.response,
  });

  static Future<void> show(
      BuildContext context, {
        required String title,
        required String subtitle,
        required ReceivedFineStatsDetailResponse response,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FineStatsDetailBottomSheet(
        title: title,
        subtitle: subtitle,
        response: response,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const initialSize = 0.82;
    final bottomSpacing = MediaQuery.viewPaddingOf(context).bottom + 8;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight = screenHeight - bottomSpacing;
    final adjustedInitialSize = ((screenHeight * initialSize) / availableHeight)
        .clamp(initialSize, 0.94)
        .toDouble();

    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, bottomSpacing),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: adjustedInitialSize,
        minChildSize: 0.48,
        maxChildSize: 0.94,
        builder: (context, _) {
          return _FineSheetContent(
            title: title,
            subtitle: subtitle,
            response: response,
          );
        },
      ),
    );
  }
}

class _FineSheetContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final ReceivedFineStatsDetailResponse response;

  const _FineSheetContent({
    required this.title,
    required this.subtitle,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isMatchDetail = response is ReceivedFineMatchDetailResponse;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
          bottom: Radius.circular(24),
        ),
        boxShadow: AppWidgetValues.cardShadow,
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            _SheetHandle(color: colors.textMuted.withAlpha(60)),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FineStatsHeader(
                title: title,
                subtitle: subtitle,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: colors.accent,
                  unselectedLabelColor: colors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  indicator: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tabs: [
                    Tab(text: isMatchDetail ? 'Hráči' : 'Zápasy'),
                    const Tab(text: 'Pokuty'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: _buildTabs(response),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTabs(ReceivedFineStatsDetailResponse value) {
    return switch (value) {
      ReceivedFineMatchDetailResponse() => [
        _PlayersTab(players: value.players),
        _FinesByPlayersTab(fines: value.fines),
      ],
      ReceivedFinePlayerDetailResponse() => [
        _MatchesTab(matches: value.matches),
        _FinesByMatchesTab(fines: value.fines),
      ],
    };
  }
}

class _FineStatsHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FineStatsHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.accent.withAlpha(28),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POKUTY',
                  style: TextStyle(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  final List<PlayerWithFinesModel> players;

  const _PlayersTab({required this.players});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const _EmptyFineContent();
    return _FineList(
      itemCount: players.length,
      itemBuilder: (index) {
        final item = players[index];
        return _GroupCard(
          icon: Icons.person_outline_rounded,
          title: item.player.name,
          totalCount: item.totalCount,
          totalAmount: item.totalAmount,
          children: item.fines
              .map((fine) => _DetailLine(
            title: fine.fine.name,
            subtitle: '${fine.count}× · ${fine.fine.amount} Kč / ks',
            trailing: '${fine.totalAmount} Kč',
          ))
              .toList(),
        );
      },
    );
  }
}

class _MatchesTab extends StatelessWidget {
  final List<MatchWithFinesModel> matches;

  const _MatchesTab({required this.matches});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const _EmptyFineContent();
    return _FineList(
      itemCount: matches.length,
      itemBuilder: (index) {
        final item = matches[index];
        return _GroupCard(
          icon: Icons.event_outlined,
          title: item.match.name,
          caption: dateTimeToString(item.match.date),
          totalCount: item.totalCount,
          totalAmount: item.totalAmount,
          children: item.fines
              .map((fine) => _DetailLine(
            title: fine.fine.name,
            subtitle: '${fine.count}× · ${fine.fine.amount} Kč / ks',
            trailing: '${fine.totalAmount} Kč',
          ))
              .toList(),
        );
      },
    );
  }
}

class _FinesByPlayersTab extends StatelessWidget {
  final List<FineWithPlayersModel> fines;

  const _FinesByPlayersTab({required this.fines});

  @override
  Widget build(BuildContext context) {
    if (fines.isEmpty) return const _EmptyFineContent();
    return _FineList(
      itemCount: fines.length,
      itemBuilder: (index) {
        final item = fines[index];
        return _GroupCard(
          icon: Icons.receipt_long_outlined,
          title: item.fine.name,
          caption: '${item.fine.amount} Kč / ks',
          totalCount: item.totalCount,
          totalAmount: item.totalAmount,
          children: item.players
              .map((player) => _DetailLine(
            title: player.player.name,
            subtitle: '${player.count}×',
            trailing: '${player.totalAmount} Kč',
          ))
              .toList(),
        );
      },
    );
  }
}

class _FinesByMatchesTab extends StatelessWidget {
  final List<FineWithMatchesModel> fines;

  const _FinesByMatchesTab({required this.fines});

  @override
  Widget build(BuildContext context) {
    if (fines.isEmpty) return const _EmptyFineContent();
    return _FineList(
      itemCount: fines.length,
      itemBuilder: (index) {
        final item = fines[index];
        return _GroupCard(
          icon: Icons.receipt_long_outlined,
          title: item.fine.name,
          caption: '${item.fine.amount} Kč / ks',
          totalCount: item.totalCount,
          totalAmount: item.totalAmount,
          children: item.matches
              .map((match) => _DetailLine(
            title: match.match.name,
            subtitle: '${dateTimeToString(match.match.date)} · ${match.count}×',
            trailing: '${match.totalAmount} Kč',
          ))
              .toList(),
        );
      },
    );
  }
}

class _FineList extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  const _FineList({
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => itemBuilder(index),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? caption;
  final int totalCount;
  final int totalAmount;
  final List<Widget> children;

  const _GroupCard({
    required this.icon,
    required this.title,
    this.caption,
    required this.totalCount,
    required this.totalAmount,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: colors.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        caption!,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _SummaryChip(text: '$totalCount×'),
              const SizedBox(width: 6),
              _SummaryChip(text: '$totalAmount Kč', emphasized: true),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: colors.textMuted.withAlpha(30)),
            const SizedBox(height: 5),
            ...children,
          ],
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _DetailLine({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String text;
  final bool emphasized;

  const _SummaryChip({
    required this.text,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized ? colors.accentSoft : colors.cardBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: emphasized ? colors.accent : colors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyFineContent extends StatelessWidget {
  const _EmptyFineContent();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, color: colors.textMuted, size: 34),
            const SizedBox(height: 10),
            Text(
              'Nejsou k dispozici žádné pokuty.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final Color color;

  const _SheetHandle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
