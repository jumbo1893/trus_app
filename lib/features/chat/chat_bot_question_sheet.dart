import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/season_util.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import 'chat_repository.dart';

class ChatBotQuestionSheet extends StatefulWidget {
  final ChatMessage message;
  final Future<List<SeasonApiModel>> Function() loadSeasons;
  final Future<List<MatchApiModel>> Function(int seasonId) loadMatches;
  final Future<void> Function(String text) send;

  const ChatBotQuestionSheet({
    super.key,
    required this.message,
    required this.loadSeasons,
    required this.loadMatches,
    required this.send,
  });

  @override
  State<ChatBotQuestionSheet> createState() => _ChatBotQuestionSheetState();
}

class _ChatBotQuestionSheetState extends State<ChatBotQuestionSheet> {
  final _question = TextEditingController();
  final Map<int, MatchApiModel> _selectedMatches = {};
  final Map<int, List<MatchApiModel>> _matchesBySeason = {};
  List<SeasonApiModel> _seasons = const [];
  List<MatchApiModel> _visibleMatches = const [];
  SeasonApiModel? _currentSeason;
  SeasonApiModel? _selectedSeason;
  int _matchRequest = 0;
  bool _optionsOpen = false;
  bool _matchesOpen = false;
  bool _seasonsLoaded = false;
  bool _loadingSeasons = false;
  bool _loadingMatches = false;
  bool _sending = false;
  String? _seasonError;
  String? _matchError;
  String? _sendError;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<T> _retryOnce<T>(Future<T> Function() fetch) async {
    try {
      return await fetch();
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return fetch();
    }
  }

  Future<void> _ensureSeasons() async {
    if (_seasonsLoaded || _loadingSeasons) return;
    setState(() {
      _loadingSeasons = true;
      _seasonError = null;
    });
    try {
      final seasons = await _retryOnce(widget.loadSeasons);
      if (!mounted) return;
      setState(() {
        _seasons = seasons.where((season) => season.id != null).toList();
        _seasonsLoaded = true;
        _currentSeason = _seasons.isEmpty
            ? null
            : returnCurrentSeason(_seasons);
      });
      if (_matchesOpen) _loadMatchesForSeason();
    } catch (_) {
      if (mounted) setState(() => _seasonError = 'Sezony se nepodařilo načíst');
    } finally {
      if (mounted) setState(() => _loadingSeasons = false);
    }
  }

  Future<void> _loadMatchesForSeason() async {
    final seasonId = (_selectedSeason ?? _currentSeason)?.id;
    if (seasonId == null) return;
    final request = ++_matchRequest;
    final cached = _matchesBySeason[seasonId];
    if (cached != null) {
      setState(() {
        _visibleMatches = cached;
        _matchError = null;
        _loadingMatches = false;
      });
      return;
    }
    setState(() {
      _visibleMatches = const [];
      _matchError = null;
      _loadingMatches = true;
    });
    try {
      final matches = await _retryOnce(() => widget.loadMatches(seasonId));
      final ordered = [...matches.where((match) => match.id != null)]
        ..sort((a, b) => b.date.compareTo(a.date));
      _matchesBySeason[seasonId] = ordered;
      if (!mounted || request != _matchRequest) return;
      setState(() => _visibleMatches = ordered);
    } catch (_) {
      if (mounted && request == _matchRequest) {
        setState(() => _matchError = 'Zápasy se nepodařilo načíst');
      }
    } finally {
      if (mounted && request == _matchRequest) {
        setState(() => _loadingMatches = false);
      }
    }
  }

  void _selectSeason(SeasonApiModel? season) {
    if (_selectedSeason?.id == season?.id) return;
    setState(() {
      _selectedSeason = season;
      _selectedMatches.clear();
    });
    if (_matchesOpen) _loadMatchesForSeason();
  }

  String _selectionSummary() => _selectedSeason == null
      ? 'Bez sezony · ${_selectedMatches.length} zápasů'
      : '${_selectedSeason!.name} · ${_selectedMatches.length} zápasů';

  String _promptText() {
    final question = _question.text.trim().isEmpty
        ? 'Je to pravda?'
        : _question.text.trim();
    final parts = <String>['TrusBote, $question'];
    if (_selectedMatches.isNotEmpty) {
      final matches = _selectedMatches.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      parts.add(
        'Zápasy: ${matches.map((match) => '${match.name} (id ${match.id})').join('; ')}.',
      );
    }
    if (_selectedSeason != null) {
      parts.add(
        'Sezona: ${_selectedSeason!.name} (id ${_selectedSeason!.id}).',
      );
    }
    return parts.join(' ');
  }

  Future<void> _submit() async {
    if (_sending) return;
    final text = _promptText();
    if (text.length > 4000) {
      setState(() => _sendError = 'Vyber méně zápasů nebo zkrať dotaz');
      return;
    }
    setState(() {
      _sending = true;
      _sendError = null;
    });
    try {
      await widget.send(text);
      if (mounted) {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _sendError = 'Dotaz se nepodařilo odeslat: $error');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      16,
      16,
      MediaQuery.viewInsetsOf(context).bottom + 16,
    ),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zeptat se TrusBota',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Ověř si zprávu u TrusBota. Volitelně můžeš přidat doplňující dotaz a upřesnit zápasy či sezonu v možnostech.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.message.author}: ${widget.message.text ?? (widget.message.image ? '[Obrázek]' : '')}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              key: const ValueKey('chat_bot_quote'),
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              key: const ValueKey('chat_bot_options'),
              title: const Text('Možnosti'),
              subtitle: _optionsOpen ? null : Text(_selectionSummary()),
              onExpansionChanged: (open) {
                setState(() => _optionsOpen = open);
                if (open) _ensureSeasons();
              },
              children: [
                if (_loadingSeasons) const LinearProgressIndicator(),
                if (_seasonError != null)
                  TextButton(
                    onPressed: _ensureSeasons,
                    child: Text('$_seasonError · Zkusit znovu'),
                  ),
                if (_seasonsLoaded) ...[
                  ExpansionTile(
                    key: const ValueKey('chat_bot_seasons'),
                    title: const Text('Sezona'),
                    subtitle: Text(_selectedSeason?.name ?? 'Bez sezony'),
                    children: [
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          key: const ValueKey('chat_bot_season_list'),
                          itemCount: _seasons.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return ListTile(
                                key: const ValueKey('chat_bot_season_none'),
                                dense: true,
                                title: const Text('Bez sezony'),
                                selected: _selectedSeason == null,
                                trailing: _selectedSeason == null
                                    ? const Icon(Icons.check_circle)
                                    : null,
                                onTap: () => _selectSeason(null),
                              );
                            }
                            final season = _seasons[index - 1];
                            return ListTile(
                              key: ValueKey('chat_bot_season_${season.id}'),
                              dense: true,
                              title: Text(season.name),
                              selected: _selectedSeason?.id == season.id,
                              trailing: _selectedSeason?.id == season.id
                                  ? const Icon(Icons.check_circle)
                                  : null,
                              onTap: () => _selectSeason(season),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    key: const ValueKey('chat_bot_matches'),
                    title: const Text('Zápasy'),
                    subtitle: Text('${_selectedMatches.length} vybráno'),
                    onExpansionChanged: (open) {
                      setState(() => _matchesOpen = open);
                      if (open) _loadMatchesForSeason();
                    },
                    children: [
                      if (_loadingMatches) const LinearProgressIndicator(),
                      if (_matchError != null)
                        TextButton(
                          onPressed: _loadMatchesForSeason,
                          child: Text('$_matchError · Zkusit znovu'),
                        ),
                      if (!_loadingMatches &&
                          _matchError == null &&
                          _visibleMatches.isEmpty)
                        const Text('V této sezoně nejsou žádné zápasy'),
                      if (!_loadingMatches &&
                          _matchError == null &&
                          _visibleMatches.isNotEmpty)
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            key: const ValueKey('chat_bot_match_list'),
                            itemCount: _visibleMatches.length,
                            itemBuilder: (context, index) {
                              final match = _visibleMatches[index];
                              final id = match.id!;
                              return CheckboxListTile(
                                key: ValueKey('chat_bot_match_$id'),
                                dense: true,
                                title: Text(match.name),
                                subtitle: Text(
                                  MaterialLocalizations.of(
                                    context,
                                  ).formatMediumDate(match.date),
                                ),
                                value: _selectedMatches.containsKey(id),
                                onChanged: (selected) => setState(() {
                                  if (selected == true) {
                                    _selectedMatches[id] = match;
                                  } else {
                                    _selectedMatches.remove(id);
                                  }
                                }),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _question,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Doplňující dotaz (volitelné)',
                hintText: 'Je to pravda?',
              ),
            ),
            if (_sendError != null)
              Text(
                _sendError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sending ? null : _submit,
                child: const Text('Zeptat se'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
