import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trus_app/features/home/widget/home_section_card.dart';
import 'package:trus_app/features/match/post_match_flow.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/match/planned_match.dart';
import 'package:trus_app/theme/app_colors.dart';

/// Dashboard card of an in-progress event with its running clock and live score.
class LiveMatchCard extends StatefulWidget {
  final PlannedMatch planned;
  final MatchApiModel? recorded;
  final VoidCallback onOpen;

  const LiveMatchCard({
    super.key,
    required this.planned,
    required this.recorded,
    required this.onOpen,
  });

  @override
  State<LiveMatchCard> createState() => _LiveMatchCardState();
}

class _LiveMatchCardState extends State<LiveMatchCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final planned = widget.planned;
    final score = widget.recorded?.simpleResultToString() ?? '';
    final title = planned.opponent?.isNotEmpty == true
        ? planned.opponent!
        : (widget.recorded?.name ?? '');
    return HomeSectionCard(
      child: InkWell(
        onTap: widget.onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: colors.errorSolid),
                const SizedBox(width: 6),
                Text(
                  'PRÁVĚ PROBÍHÁ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.errorSolid,
                  ),
                ),
                const Spacer(),
                if (planned.hasScore)
                  Text(
                    livePhaseLabel(planned, DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (planned.hasScore)
                  Text(
                    score.isEmpty ? '0:0' : score,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onOpen,
                icon: Icon(
                  planned.hasScore ? Icons.sports_soccer : Icons.groups_outlined,
                ),
                label: Text(
                  planned.hasScore ? 'Zapisovat skóre a góly' : 'Sestava',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
