import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/membership/repository/membership_api_service.dart';

class MembershipTierBadge extends ConsumerWidget {
  const MembershipTierBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(membershipProvider).valueOrNull?.effectiveTier;
    if (tier != 'PREMIUM' && tier != 'ULTRA') {
      return const SizedBox.shrink();
    }

    final color = tier == 'ULTRA'
        ? const Color(0xFFA855F7)
        : const Color(0xFFF59E0B);
    final label = tier == 'ULTRA' ? 'Ultra' : 'Premium';

    return Semantics(
      label: 'Úroveň účtu $label',
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: .7)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: .25,
          ),
        ),
      ),
    );
  }
}
