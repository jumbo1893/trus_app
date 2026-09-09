import 'package:trus_app/services/crash_reporting_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trus_app/features/ai/repository/match_report_api_service.dart';
import 'package:trus_app/models/api/ai/match_report.dart';

/// Inline content of the last match card, without a separate card or style selector.
class MatchReportCard extends ConsumerStatefulWidget {
  const MatchReportCard({super.key, required this.matchId});
  final int matchId;
  @override
  ConsumerState<MatchReportCard> createState() => _MatchReportCardState();
}

class _MatchReportCardState extends ConsumerState<MatchReportCard> {
  MatchReport? _report;
  bool _opened = false;
  bool _loading = false;
  bool _generating = false;
  bool _canGenerate = false;
  bool _teamGenerating = false;
  String? _error;

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final state = await ref
          .read(matchReportApiServiceProvider)
          .getReports(widget.matchId);
      if (!mounted) return;
      setState(() {
        _report = state.report;
        _canGenerate = state.canGenerate;
        _teamGenerating = state.generating;
      });
    } catch (error, stack) {
      await CrashReportingService.recordError(
        error,
        stack,
        reason: 'match_report.request',
      );
      if (mounted) {
        setState(() {
          _error = 'Report se nepodařilo načíst nebo vytvořit. Zkus to znovu.';
          _canGenerate = false;
        });
      }
    } finally {
      if (mounted && showLoading) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _generate() async {
    if (_generating || !_canGenerate) return;
    setState(() {
      _generating = true;
      _error = null;
      _canGenerate = false;
    });
    try {
      final report = await ref
          .read(matchReportApiServiceProvider)
          .generate(widget.matchId);
      if (!mounted) return;
      setState(() {
        _report = report;
      });
      // Refresh server-authoritative membership/permission after creating the shared report.
      await _load(showLoading: false);
    } catch (error, stack) {
      await CrashReportingService.recordError(
        error,
        stack,
        reason: 'match_report.request',
      );
      if (!mounted) return;
      await _load(showLoading: false);
      if (mounted) {
        setState(() {
          _error = 'Report se nepodařilo načíst nebo vytvořit. Zkus to znovu.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _generating = false;
        });
      }
    }
  }

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: _report!.text));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report zkopírován.')));
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Text se nepodařilo zkopírovat.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _generating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.auto_awesome),
          label: Text(_opened ? 'Skrýt report zápasu' : 'Report zápasu'),
          onPressed: () {
            setState(() {
              _opened = !_opened;
            });
            if (_opened && !busy) _load();
          },
        ),
        if (_opened) ...[
          if (busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(_generating ? 'TrusBot píše report…' : 'Načítám report…'),
            const SizedBox(height: 12),
          ],
          if (_report != null) ...[
            Text(
              'Vygenerováno ${DateFormat('d. M. yyyy HH:mm').format(_report!.generatedAt.toLocal())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            SelectableText(_report!.text),
            const SizedBox(height: 12),
          ],
          if (_teamGenerating && !busy) ...[
            const Text('Report se právě připravuje.'),
            TextButton(onPressed: _load, child: const Text('Načíst report')),
          ],
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(
              onPressed: busy ? null : _load,
              child: const Text('Znovu načíst report'),
            ),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_canGenerate || _generating)
                ElevatedButton.icon(
                  onPressed: busy ? null : _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    _report == null
                        ? 'Vygenerovat report'
                        : 'Vygenerovat znovu',
                  ),
                ),
              if (_report != null)
                OutlinedButton.icon(
                  onPressed: _copy,
                  icon: const Icon(Icons.copy),
                  label: const Text('Kopírovat text'),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
