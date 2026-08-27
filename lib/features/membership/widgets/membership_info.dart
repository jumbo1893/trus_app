import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trus_app/features/membership/repository/membership_api_service.dart';
import 'package:trus_app/models/api/membership/membership.dart';
import 'package:trus_app/theme/app_colors.dart';

class MembershipInfoButton extends ConsumerWidget {
  final String tooltip;

  const MembershipInfoButton({
    super.key,
    this.tooltip = 'Jak funguje členství',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: tooltip,
    onPressed: () => showMembershipInfo(context),
    icon: const Icon(Icons.info_outline_rounded),
  );
}

class MembershipStatusCard extends ConsumerWidget {
  const MembershipStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(membershipProvider);
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: membership.when(
        loading: () => const Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Načítám členství…')),
            MembershipInfoButton(),
          ],
        ),
        error: (_, __) => Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.errorForeground),
            const SizedBox(width: 10),
            const Expanded(child: Text('Členství se nepodařilo načíst.')),
            IconButton(
              tooltip: 'Načíst znovu',
              onPressed: () => ref.invalidate(membershipProvider),
              icon: const Icon(Icons.refresh_rounded),
            ),
            const MembershipInfoButton(),
          ],
        ),
        data: (value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TierIcon(tier: value.effectiveTier),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.effectiveTierLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const MembershipInfoButton(),
              ],
            ),
            const SizedBox(height: 12),
            if (value.effectiveTier == 'STANDARD')
              _DrinkProgress(membership: value)
            else
              Text(
                _currentTierStatus(value),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.35,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MembershipUserName extends ConsumerWidget {
  final String name;

  const MembershipUserName({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(membershipProvider).valueOrNull;
    final tier = membership?.effectiveTier ?? 'STANDARD';
    final textStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: context.appColors.textPrimary,
    );
    if (tier == 'STANDARD') {
      return Text(name, textAlign: TextAlign.center, style: textStyle);
    }
    final gradient = LinearGradient(
      colors: tier == 'ULTRA'
          ? const [Color(0xFF7C3AED), Color(0xFFC026D3), Color(0xFF8B5CF6)]
          : const [Color(0xFFF59E0B), Color(0xFFFFD54F), Color(0xFFD97706)],
    );
    final iconColor = tier == 'ULTRA'
        ? const Color(0xFFA855F7)
        : const Color(0xFFF59E0B);
    return Semantics(
      label: '$name, ${membership?.effectiveTierLabel ?? tier}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tier == 'ULTRA'
                ? Icons.auto_awesome_rounded
                : Icons.workspace_premium_rounded,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: gradient.createShader,
              child: Text(name, textAlign: TextAlign.center, style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showMembershipInfo(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.appColors.backgroundPrimary,
      barrierColor: Colors.black.withValues(alpha: .62),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _MembershipInfoSheet(),
    );

class _MembershipInfoSheet extends ConsumerWidget {
  const _MembershipInfoSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(membershipProvider);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: context.appColors.backgroundPrimary,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .82,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomPadding),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: context.appColors.accentSoft,
                  foregroundColor: context.appColors.accent,
                  child: const Icon(Icons.card_membership_rounded, size: 25),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Úroveň účtu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sbírej achievementy a pij piva/panáky a vylepšuj si tím úroveň svého účtu',
              style: TextStyle(
                color: context.appColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            membership.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => OutlinedButton.icon(
                onPressed: () => ref.invalidate(membershipProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Načíst stav znovu'),
              ),
              data: (value) => _CurrentMembership(membership: value),
            ),
            const SizedBox(height: 18),
            const _TierExplanation(
              icon: Icons.person_outline_rounded,
              title: 'Standard',
              subtitle: 'Pouze 2 dotazy denně na TrusBota',
            ),
            _TierExplanation(
              icon: Icons.workspace_premium_outlined,
              title: 'Premium',
              subtitle: '20 dotazů denně na TrusBota',
              detail:
                  'Za každých 10 nově vypitých piv nebo panáků získáváš 7 dní Premium členství',
              content: membership.valueOrNull == null
                  ? null
                  : _PremiumProgress(
                      membership: membership.valueOrNull!,
                    ),
            ),
            const _TierExplanation(
              icon: Icons.auto_awesome_rounded,
              title: 'Ultra',
              subtitle: 'Neomezený počet dotazů na TrusBota',
              detail:
                  'Za každý nově získaný achievement získáváš 7 dní Ultra členství',
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentMembership extends StatelessWidget {
  final Membership membership;

  const _CurrentMembership({required this.membership});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.accent.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TierIcon(tier: membership.effectiveTier),
              const SizedBox(width: 10),
              Text(
                'Teď máš ${membership.effectiveTierLabel}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentTierStatus(membership),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PremiumProgress extends StatelessWidget {
  final Membership membership;

  const _PremiumProgress({required this.membership});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      _DrinkProgress(membership: membership),
    ],
  );
}

class _DrinkProgress extends StatelessWidget {
  final Membership membership;

  const _DrinkProgress({required this.membership});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.sports_bar_rounded, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'Další Premium týden: ${membership.drinksTowardNextPremium}/${membership.drinksPerPremiumWeek}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: membership.drinkProgress,
          minHeight: 9,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        membership.drinksToNextPremium == 1
            ? 'Chybí 1 pivo nebo panák.'
            : 'Chybí ${membership.drinksToNextPremium} piv nebo panáků.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary),
      ),
    ],
  );
}

class _TierExplanation extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? detail;
  final Widget? content;

  const _TierExplanation({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.detail,
    this.content,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.appColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
                if (detail?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                if (content != null) content!,
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TierIcon extends StatelessWidget {
  final String tier;

  const _TierIcon({required this.tier});

  @override
  Widget build(BuildContext context) {
    final color = switch (tier) {
      'ULTRA' => const Color(0xFFA855F7),
      'PREMIUM' => const Color(0xFFF59E0B),
      _ => context.appColors.accent,
    };
    return CircleAvatar(
      radius: 19,
      backgroundColor: color.withValues(alpha: .16),
      foregroundColor: color,
      child: Icon(switch (tier) {
        'ULTRA' => Icons.auto_awesome_rounded,
        'PREMIUM' => Icons.workspace_premium_rounded,
        _ => Icons.person_rounded,
      }, size: 21),
    );
  }
}

String _formatDate(DateTime date) =>
    DateFormat('d. M. yyyy HH:mm').format(date.toLocal());

String _currentTierStatus(Membership membership) =>
    switch (membership.effectiveTier) {
      'ULTRA' when membership.unlimitedTier == 'ULTRA' =>
        'Neomezený Ultra účet.',
      'ULTRA' when membership.ultraUntil != null =>
        'Ultra účet vyprší za ${_remainingTime(membership.ultraUntil!)}.',
      'ULTRA' => 'Ultra účet je aktivní.',
      'PREMIUM' when membership.unlimitedTier == 'PREMIUM' =>
        'Neomezený Premium účet.',
      'PREMIUM' when membership.premiumUntil != null =>
        'Premium účet vyprší za ${_remainingTime(membership.premiumUntil!)}.',
      'PREMIUM' => 'Premium účet je aktivní.',
      _ => 'Podívej se na podmínky vylepšení úrovně účtu.',
    };

String _remainingTime(DateTime until) {
  final duration = until.difference(DateTime.now());
  if (duration.isNegative || duration.inSeconds <= 0) return 'méně než minutu';
  final totalMinutes = (duration.inSeconds + 59) ~/ 60;
  final days = totalMinutes ~/ (24 * 60);
  final hours = (totalMinutes.remainder(24 * 60)) ~/ 60;
  final minutes = totalMinutes.remainder(60);
  final parts = <String>[];
  if (days > 0) parts.add('$days ${_daysLabel(days)}');
  if (hours > 0) parts.add('$hours ${_hoursLabel(hours)}');
  if (parts.isEmpty || (days == 0 && parts.length < 2 && minutes > 0)) {
    parts.add('$minutes ${_minutesLabel(minutes)}');
  }
  return parts.take(2).join(', ');
}

String _daysLabel(int value) => value == 1
    ? 'den'
    : value >= 2 && value <= 4
    ? 'dny'
    : 'dní';

String _hoursLabel(int value) => value == 1
    ? 'hodinu'
    : value >= 2 && value <= 4
    ? 'hodiny'
    : 'hodin';

String _minutesLabel(int value) => value == 1
    ? 'minutu'
    : value >= 2 && value <= 4
    ? 'minuty'
    : 'minut';
