import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_repository.dart';
import 'onboarding_screen.dart';

/// Settings offers a continuation only, never a new/replayed onboarding.
class OnboardingCard extends ConsumerStatefulWidget {
  const OnboardingCard({super.key});
  @override
  ConsumerState<OnboardingCard> createState() => _OnboardingCardState();
}

class _OnboardingCardState extends ConsumerState<OnboardingCard> {
  bool _opening = false;

  Future<void> _open() async {
    if (_opening || !mounted) return;
    setState(() => _opening = true);
    try {
      await openOnboarding(context, ref);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = onboardingProgressProvider(onboardingKey(ref));
    final state = ref.watch(provider);
    final progress = state.valueOrNull;
    if (progress == null || !progress.available || progress.finished) {
      return const SizedBox.shrink();
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.explore_outlined),
        title: const Text('Dokončit nastavení'),
        subtitle: const Text('Profil, oznámení, kroky a představení appky'),
        trailing: _opening
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: _opening ? null : _open,
      ),
    );
  }
}
