import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'onboarding_repository.dart';
import 'onboarding_screen.dart';

/// Registration opens this route before MainScreen. Network failures are
/// retryable/skippable here and must not strand a successfully registered user.
class OnboardingEntry extends ConsumerStatefulWidget {
  const OnboardingEntry({super.key});
  @override
  ConsumerState<OnboardingEntry> createState() => _OnboardingEntryState();
}

class _OnboardingEntryState extends ConsumerState<OnboardingEntry> {
  OnboardingProgress? _progress;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (_loading || !mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final current = await repository.load();
      if (!mounted) return;
      // Do not activate old accounts or replay completed onboarding from a
      // stale settings card / when an existing member joins another team.
      if (!current.available || current.finished) {
        Navigator.pop(context);
        return;
      }
      final progress = await repository.start();
      if (!mounted) return;
      if (progress.finished) {
        Navigator.pop(context);
        return;
      }
      if (mounted) setState(() => _progress = progress);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ServerException
              ? 'Server průvodce odmítl: ${error.cause}\nPokud proběhla aktualizace klienta, ověř také nasazení nového backendu.'
              : 'Průvodce se nepodařilo načíst. Zkus to znovu, nebo nastavení dokonči později.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_progress case final progress?) {
      return OnboardingScreen(initial: progress);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavení aplikace'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (_loading) const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            Text(
              _error ??
                  'Připravujeme krátkého průvodce. Všechny kroky můžeš přeskočit.',
            ),
            if (_error != null)
              FilledButton(onPressed: _load, child: const Text('Zkusit znovu')),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dokončit později'),
            ),
          ],
        ),
      ),
    );
  }
}
