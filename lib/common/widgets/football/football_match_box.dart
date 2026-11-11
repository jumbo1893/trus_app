import 'package:flutter/material.dart';
import 'package:trus_app/features/ai/widgets/match_report_card.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/helper/redirect/redirect_api_model.dart';
import 'package:trus_app/models/api/helper/redirect/text_with_redirect.dart';
import 'package:trus_app/models/api/helper/warning_type.dart';
import 'package:trus_app/models/api/home/dashboard_match.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/common/widgets/football/team_logo.dart';

import '../../../features/home/widget/home_section_card.dart';
import '../../../models/api/football/detail/football_match_detail.dart';

class FootballMatchBox extends StatelessWidget {
  const FootballMatchBox({
    super.key,
    required this.isNextMatch,
    required this.dashboardMatch,
    this.participationStatus,
    this.participationPlaying,
    this.attendingPlayerCount,
    required this.appTeamApiModel,
    required this.onAddPlayers,
    required this.onAddGoals,
    required this.onAddFine,
    required this.onDetailMatch,
    required this.onParticipation,
    required this.onRespondToParticipation,
    required this.onCommonMatches,
    required this.onRedirect,
  });

  final bool isNextMatch;
  final DashboardMatch? dashboardMatch;
  final MatchParticipationStatus? participationStatus;
  final bool? participationPlaying;
  final int? attendingPlayerCount;
  final AppTeamApiModel? appTeamApiModel;

  final void Function(FootballMatchApiModel match) onAddPlayers;
  final void Function(FootballMatchApiModel match) onAddGoals;
  final void Function(FootballMatchApiModel match) onAddFine;
  final void Function(FootballMatchApiModel match) onDetailMatch;
  final void Function(FootballMatchApiModel match) onParticipation;
  final Future<void> Function(
    FootballMatchApiModel match,
    MatchParticipationStatus status, {
    bool? playing,
  })
  onRespondToParticipation;
  final void Function(FootballMatchApiModel match) onCommonMatches;
  final void Function(RedirectApiModel redirect) onRedirect;

  FootballMatchApiModel? get _match => dashboardMatch?.match?.footballMatch;

  int _resolveMatchId() {
    if (dashboardMatch?.match?.footballMatch == null) return -1;

    return dashboardMatch!.match!.footballMatch
            .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(
              appTeamApiModel,
            ) ??
        -1;
  }

  bool _isMatchButtonEnabled(
    FootballMatchApiModel? footballMatch,
    int matchId,
  ) {
    return footballMatch != null && matchId != -1;
  }

  String _sectionTitle(FootballMatchApiModel? match) {
    if (match != null && match.isCurrentlyPlaying()) {
      return "Aktuálně hraný zápas";
    }
    return isNextMatch ? "Příští zápas" : "Poslední zápas";
  }

  _MatchHeaderData _buildHeaderData(FootballMatchApiModel? match) {
    if (match == null) {
      return const _MatchHeaderData(
        title: "Zatím neznámý zápas",
        subtitle: "",
        meta: "",
      );
    }

    return _MatchHeaderData(
      title: match.toStringForTitle(),
      subtitle: match.toStringForDateSubtitle(),
      meta: match.toStringForMeta(),
    );
  }

  List<_WarningItem> _buildWarnings(
    FootballMatchDetail? detail,
    List<TextWithRedirect> matchInfoList,
  ) {
    if (detail == null) return [];

    final warnings = <_WarningItem>[];

    for (final textWithRedirect in matchInfoList) {
      if (isNextMatch &&
          (textWithRedirect.text ?? '').trimLeft().startsWith('Účast:')) {
        continue;
      }
      warnings.add(
        _WarningItem(
          text: textWithRedirect.text ?? "",
          warningType: textWithRedirect.warningType ?? WarningType.info,
          redirectApiModel: textWithRedirect.redirect,
        ),
      );
    }

    if (isNextMatch) {
      final currentTeamId = appTeamApiModel?.team.id;
      final match = detail.footballMatch;
      final isHome =
          currentTeamId != null && match.homeTeam?.id == currentTeamId;
      final isAway =
          currentTeamId != null && match.awayTeam?.id == currentTeamId;
      final opponentEstimate = isHome
          ? detail.awayTeamForeignNameEstimate
          : isAway
          ? detail.homeTeamForeignNameEstimate
          : null;
      final opponentName = isHome ? match.awayTeam?.name : match.homeTeam?.name;
      if (opponentEstimate != null) {
        warnings.add(
          _WarningItem(
            text:
                'Hlášení cizinecké policie o${opponentName == null ? '' : ' $opponentName'}: ${opponentEstimate.summary}',
            warningType: WarningType.info,
          ),
        );
      }
      warnings.add(
        _WarningItem(
          text:
              "Průměrný rok narození domácích: ${detail.homeTeamAverageBirthYear} × hostů: ${detail.awayTeamAverageBirthYear}",
          warningType: WarningType.info,
        ),
      );

      if (detail.homeTeamBestScorer != null &&
          detail.awayTeamBestScorer != null) {
        warnings.add(
          _WarningItem(
            text:
                "Nejlepší střelec domácích: ${detail.homeTeamBestScorer} × hostů: ${detail.awayTeamBestScorer}",
            warningType: WarningType.info,
          ),
        );
      }
    }

    return warnings;
  }

  void _showMoreActionsSheet(
    BuildContext context,
    FootballMatchApiModel match,
    bool matchActionsEnabled,
  ) {
    final appColors = context.appColors;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: appColors.cardBackground,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isNextMatch)
                  _BottomSheetActionTile(
                    icon: Icons.how_to_reg_outlined,
                    title: "Detail účasti",
                    enabled: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      onParticipation(match);
                    },
                  ),
                if (!isNextMatch)
                  _BottomSheetActionTile(
                    icon: Icons.person_add_alt_1,
                    title: "Přidat hráče",
                    enabled: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      onAddPlayers(match);
                    },
                  ),
                _BottomSheetActionTile(
                  icon: Icons.sports_soccer,
                  title: "Přidat góly",
                  enabled: matchActionsEnabled,
                  onTap: () {
                    Navigator.of(context).pop();
                    onAddGoals(match);
                  },
                ),
                _BottomSheetActionTile(
                  icon: Icons.description_outlined,
                  title: "Detail",
                  enabled: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    onDetailMatch(match);
                  },
                ),
                _BottomSheetActionTile(
                  icon: Icons.savings,
                  title: "Přidat pokuty",
                  enabled: matchActionsEnabled,
                  onTap: () {
                    Navigator.of(context).pop();
                    onAddFine(match);
                  },
                ),
                _BottomSheetActionTile(
                  icon: Icons.compare_arrows,
                  title: "Vzájemné zápasy",
                  enabled: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    onCommonMatches(match);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWarningsSheet(
    BuildContext context, {
    required List<_WarningItem> warnings,
    required void Function(RedirectApiModel redirect) onRedirect,
  }) {
    final appColors = context.appColors;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: appColors.cardBackground,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Důležité informace",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...warnings.map(
                    (warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CompactWarningCard(
                        warning: warning,
                        onRedirect: onRedirect,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    FootballMatchApiModel match,
    bool matchActionsEnabled,
    List<_WarningItem> warnings,
  ) {
    final colors = context.appColors;
    final date = match.date.toLocal();
    const weekdays = ['PO', 'ÚT', 'ST', 'ČT', 'PÁ', 'SO', 'NE'];
    String two(int value) => value.toString().padLeft(2, '0');
    final statusColor = switch (participationStatus) {
      MatchParticipationStatus.attending =>
        participationPlaying == false
            ? const Color(0xFF218C83)
            : colors.successSolid,
      MatchParticipationStatus.maybe => colors.warningSolid,
      MatchParticipationStatus.notAttending => colors.errorSolid,
      null => colors.accent,
    };
    final statusLabel = switch (participationStatus) {
      MatchParticipationStatus.attending =>
        participationPlaying == false ? 'Fanoušek' : 'Jdu',
      MatchParticipationStatus.maybe => 'Možná',
      MatchParticipationStatus.notAttending => 'Nejdu',
      null => 'Účast',
    };
    final statusIcon = switch (participationStatus) {
      MatchParticipationStatus.attending => Icons.check,
      MatchParticipationStatus.maybe => Icons.question_mark,
      MatchParticipationStatus.notAttending => Icons.close,
      null => Icons.how_to_reg_outlined,
    };
    final score = match.simpleResultToString();
    final ranking = match.opponentsTeamRanking();
    final currentTeamId = appTeamApiModel?.team.id;
    final opponent = currentTeamId == match.homeTeam?.id
        ? match.awayTeam
        : currentTeamId == match.awayTeam?.id
        ? match.homeTeam
        : match.awayTeam;
    final visibleWarnings = warnings.take(isNextMatch ? 3 : 1).toList();
    void detailTap() =>
        isNextMatch ? onParticipation(match) : onDetailMatch(match);

    return HomeSectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 53,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: detailTap,
                  child: Column(
                    children: [
                      TeamLogo(url: opponent?.logoUrl, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        weekdays[date.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        '${two(date.day)}.${two(date.month)}.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        '${two(date.hour)}:${two(date.minute)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: detailTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sectionTitle(match),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.accent,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${match.toStringNameWithOpponent()}${score.isEmpty ? '' : '  $score'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (match.stadium?.trim().isNotEmpty == true)
                        _compactMeta(
                          Icons.location_on_outlined,
                          match.stadium!.trim(),
                          colors.textSecondary,
                        ),
                      if (ranking.isNotEmpty)
                        _compactMeta(
                          Icons.leaderboard_outlined,
                          ranking,
                          colors.textSecondary,
                        ),
                      _compactMeta(
                        Icons.sports_outlined,
                        match.referee?.trim().isNotEmpty == true
                            ? match.referee!.trim()
                            : 'Neznámý rozhodčí',
                        colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: 92,
                child: Column(
                  children: [
                    if (!isNextMatch)
                      FilledButton.icon(
                        onPressed: () => onAddPlayers(match),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text(
                          'Upravit',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          minimumSize: const Size(70, 30),
                        ),
                      ),
                    if (isNextMatch)
                      PopupMenuButton<int>(
                        tooltip: 'Změnit účast',
                        onSelected: (choice) => onRespondToParticipation(
                          match,
                          choice < 2
                              ? MatchParticipationStatus.attending
                              : choice == 2
                              ? MatchParticipationStatus.maybe
                              : MatchParticipationStatus.notAttending,
                          playing: choice == 0
                              ? true
                              : choice == 1
                              ? false
                              : null,
                        ),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 0, child: Text('✓ Jdu a hraju')),
                          PopupMenuItem(
                            value: 1,
                            child: Text('✓ Jdu jako fanoušek'),
                          ),
                          PopupMenuItem(value: 2, child: Text('? Možná')),
                          PopupMenuItem(value: 3, child: Text('✕ Nejdu')),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(statusIcon, size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  statusLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isNextMatch) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: detailTap,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 15,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${attendingPlayerCount ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _showMoreActionsSheet(
                        context,
                        match,
                        matchActionsEnabled,
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        minimumSize: const Size(60, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Více...',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (visibleWarnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...visibleWarnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _CompactWarningCard(
                  warning: warning,
                  onRedirect: onRedirect,
                ),
              ),
            ),
            if (warnings.length > visibleWarnings.length)
              TextButton(
                onPressed: () => _showWarningsSheet(
                  context,
                  warnings: warnings,
                  onRedirect: (redirect) {
                    Navigator.of(context).pop();
                    onRedirect(redirect);
                  },
                ),
                child: Text(
                  'Zobrazit další (${warnings.length - visibleWarnings.length})',
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _compactMeta(IconData icon, String text, Color color) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final match = _match;
    final matchId = _resolveMatchId();
    final matchActionsEnabled = _isMatchButtonEnabled(match, matchId);
    final warnings = _buildWarnings(
      dashboardMatch?.match,
      dashboardMatch?.matchInfoList ?? [],
    );
    if (match != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompactCard(context, match, matchActionsEnabled, warnings),
          if (!isNextMatch &&
              match.id != null &&
              (match.alreadyPlayed ||
                  (match.homeGoalNumber != null &&
                      match.awayGoalNumber != null)) &&
              match.date.isBefore(DateTime.now())) ...[
            const SizedBox(height: 14),
            MatchReportCard(
              key: ValueKey('${appTeamApiModel?.id}-${match.id}'),
              matchId: match.id!,
            ),
          ],
        ],
      );
    }

    final header = _buildHeaderData(match);
    final visibleWarnings = warnings.take(isNextMatch ? 3 : 1).toList();

    final secondActionLabel = matchActionsEnabled ? "Přidat góly" : "Detail";
    final secondActionIcon = matchActionsEnabled
        ? Icons.sports_soccer
        : Icons.description_outlined;
    final participationColor = switch (participationStatus) {
      MatchParticipationStatus.attending =>
        participationPlaying == false
            ? const Color(0xFF218C83)
            : appColors.successSolid,
      MatchParticipationStatus.maybe => appColors.warningSolid,
      MatchParticipationStatus.notAttending => appColors.errorSolid,
      null => null,
    };
    final participationIcon = switch (participationStatus) {
      MatchParticipationStatus.attending => Icons.check,
      MatchParticipationStatus.maybe => Icons.question_mark,
      MatchParticipationStatus.notAttending => Icons.close,
      null => Icons.how_to_reg_outlined,
    };

    return HomeSectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNextMatch && match != null)
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onParticipation(match),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 32,
                      color: appColors.accent,
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onParticipation(match),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ZÁPAS · ${match.league.name} · ${match.round}. kolo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appColors.textPrimary,
                            ),
                          ),
                          Text(
                            match.toStringNameWithOpponent(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: appColors.textSecondary),
                          ),
                          Text(
                            header.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: appColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => onParticipation(match),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 18,
                          color: appColors.textSecondary,
                        ),
                        Text(
                          '${attendingPlayerCount ?? 0}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            _CompactMatchHeader(
              sectionTitle: _sectionTitle(match),
              data: header,
              onMatchTap: match != null ? () => onDetailMatch(match) : null,
            ),
          if (match != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: isNextMatch
                      ? PopupMenuButton<int>(
                          tooltip: 'Změnit účast',
                          onSelected: (choice) => onRespondToParticipation(
                            match,
                            choice < 2
                                ? MatchParticipationStatus.attending
                                : choice == 2
                                ? MatchParticipationStatus.maybe
                                : MatchParticipationStatus.notAttending,
                            playing: choice == 0
                                ? true
                                : choice == 1
                                ? false
                                : null,
                          ),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 0,
                              child: Text('✓ Jdu a hraju'),
                            ),
                            PopupMenuItem(
                              value: 1,
                              child: Text('✓ Jdu jako fanoušek'),
                            ),
                            PopupMenuItem(value: 2, child: Text('? Možná')),
                            PopupMenuItem(
                              value: 3,
                              child: Text('✕ Nezúčastním se'),
                            ),
                          ],
                          child: _PrimaryActionButton(
                            label: switch (participationStatus) {
                              MatchParticipationStatus.attending =>
                                participationPlaying == false
                                    ? 'Fanoušek'
                                    : 'Jdu',
                              MatchParticipationStatus.maybe => 'Možná',
                              MatchParticipationStatus.notAttending => 'Nejdu',
                              null => 'Účast',
                            },
                            icon: participationIcon,
                            color: participationColor,
                            onTap: null,
                          ),
                        )
                      : _PrimaryActionButton(
                          label: "Přidat hráče",
                          icon: isNextMatch
                              ? participationIcon
                              : Icons.person_add_alt_1,
                          onTap: () => onAddPlayers(match),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PrimaryActionButton(
                    label: secondActionLabel,
                    icon: secondActionIcon,
                    onTap: () {
                      if (matchActionsEnabled) {
                        onAddGoals(match);
                      } else {
                        onDetailMatch(match);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PrimaryActionButton(
                    label: "Více",
                    icon: Icons.more_horiz,
                    onTap: () => _showMoreActionsSheet(
                      context,
                      match,
                      matchActionsEnabled,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (visibleWarnings.isNotEmpty) ...[
            const SizedBox(height: 14),
            const _SectionLabel(text: "Důležité informace"),
            const SizedBox(height: 8),
            ...visibleWarnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CompactWarningCard(
                  warning: warning,
                  onRedirect: onRedirect,
                ),
              ),
            ),
            if (warnings.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      _showWarningsSheet(
                        context,
                        warnings: warnings,
                        onRedirect: (redirect) {
                          Navigator.of(context).pop();
                          onRedirect(redirect);
                        },
                      );
                    },
                    child: Text(
                      "Zobrazit další (${warnings.length - 1})",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: appColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
          ],
          if (!isNextMatch &&
              match != null &&
              match.id != null &&
              (match.alreadyPlayed ||
                  (match.homeGoalNumber != null &&
                      match.awayGoalNumber != null)) &&
              match.date.isBefore(DateTime.now())) ...[
            const SizedBox(height: 14),
            const Divider(),
            MatchReportCard(
              key: ValueKey('${appTeamApiModel?.id}-${match.id}'),
              matchId: match.id!,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: appColors.textMuted,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _MatchHeaderData {
  const _MatchHeaderData({
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final String title;
  final String subtitle;
  final String meta;
}

class _CompactMatchHeader extends StatelessWidget {
  const _CompactMatchHeader({
    required this.sectionTitle,
    required this.data,
    this.onMatchTap,
  });

  final String sectionTitle;
  final _MatchHeaderData data;
  final VoidCallback? onMatchTap;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: appColors.textMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: appColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (data.subtitle.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: appColors.textSecondary,
              height: 1.25,
            ),
          ),
        ],
        if (data.meta.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            data.meta,
            style: TextStyle(
              fontSize: 12,
              color: appColors.textMuted,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    if (onMatchTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onMatchTap,
      child: content,
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Material(
      color: color ?? appColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color == null ? appColors.accentSoft : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color == null ? appColors.accent : Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color == null ? appColors.textPrimary : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetActionTile extends StatelessWidget {
  const _BottomSheetActionTile({
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final iconColor = enabled ? appColors.accent : appColors.disabled;
    final textColor = enabled ? appColors.textPrimary : appColors.disabled;
    final trailingColor = enabled ? appColors.accent : appColors.disabled;

    return ListTile(
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      trailing: Icon(Icons.chevron_right, color: trailingColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _CompactWarningCard extends StatelessWidget {
  const _CompactWarningCard({required this.warning, required this.onRedirect});

  final _WarningItem warning;
  final void Function(RedirectApiModel redirect) onRedirect;

  @override
  Widget build(BuildContext context) {
    final style = _WarningStyle.fromType(context, warning.warningType);

    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(style.icon, color: style.iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning.text,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: context.appColors.textPrimary,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (warning.redirectApiModel?.canNavigate ?? false) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: context.appColors.accent,
              size: 18,
            ),
          ],
        ],
      ),
    );

    if (!(warning.redirectApiModel?.canNavigate ?? false)) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onRedirect(warning.redirectApiModel!),
      child: content,
    );
  }
}

class _WarningItem {
  const _WarningItem({
    required this.text,
    required this.warningType,
    this.redirectApiModel,
  });

  final String text;
  final WarningType warningType;
  final RedirectApiModel? redirectApiModel;
}

class _WarningStyle {
  const _WarningStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  factory _WarningStyle.fromType(BuildContext context, WarningType type) {
    final appColors = context.appColors;

    switch (type) {
      case WarningType.warning:
        return _WarningStyle(
          icon: Icons.warning_amber_rounded,
          iconColor: appColors.warningForeground,
          backgroundColor: appColors.warningBackground,
        );
      case WarningType.error:
        return _WarningStyle(
          icon: Icons.error_outline,
          iconColor: appColors.errorForeground,
          backgroundColor: appColors.errorBackground,
        );
      case WarningType.success:
        return _WarningStyle(
          icon: Icons.check_circle_outline,
          iconColor: appColors.successForeground,
          backgroundColor: appColors.successBackground,
        );
      case WarningType.info:
      default:
        return _WarningStyle(
          icon: Icons.info_outline,
          iconColor: appColors.infoForeground,
          backgroundColor: appColors.infoBackground,
        );
    }
  }
}
