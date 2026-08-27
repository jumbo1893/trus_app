import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/ai/controller/ai_assistant_controller.dart';
import 'package:trus_app/features/ai/state/ai_assistant_state.dart';
import 'package:trus_app/features/ai/widgets/trusbot_markdown_text.dart';
import 'package:trus_app/features/membership/widgets/membership_info.dart';
import 'package:trus_app/models/api/ai/ai_models.dart';
import 'package:trus_app/theme/app_colors.dart';

class AiAssistantScreen extends CustomConsumerStatefulWidget {
  static const String id = 'ai-assistant-screen';

  const AiAssistantScreen({super.key}) : super(title: 'TrusBot', name: id);

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _questionFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();

  bool _speechInitialized = false;
  bool _speechAvailable = false;
  bool _isListening = false;
  String? _speechLocaleId;
  String _dictationPrefix = '';

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _questionFocusNode.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submit() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      if (!mounted) return;
    }
    FocusScope.of(context).unfocus();
    final sent = await ref
        .read(aiAssistantControllerProvider.notifier)
        .submit(_questionController.text);
    if (sent) {
      _questionController.clear();
      _scrollToBottom();
    }
  }

  void _useSuggestion(String question) {
    _questionController
      ..text = question
      ..selection = TextSelection.collapsed(offset: question.length);
    _questionFocusNode.requestFocus();
    _scrollToBottom();
  }

  Future<void> _toggleDictation() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    FocusScope.of(context).unfocus();
    if (!await _requestSpeechPermissions() || !mounted) return;
    if (!_speechInitialized) {
      await _initializeSpeech();
      if (!mounted) return;
    }
    if (!_speechAvailable) {
      _showSpeechMessage(
        'Diktování není dostupné. Zkontroluj oprávnění k mikrofonu.',
      );
      return;
    }

    _dictationPrefix = _questionController.text.trimRight();
    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          localeId: _speechLocaleId,
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
          autoPunctuation: true,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 4),
        ),
      );
      if (mounted) {
        setState(() => _isListening = _speechToText.isListening);
      }
    } catch (_) {
      _showSpeechMessage('Diktování se nepodařilo spustit.');
    }
  }

  Future<bool> _requestSpeechPermissions() async {
    var microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      microphoneStatus = await Permission.microphone.request();
    }
    if (!mounted) return false;
    if (!microphoneStatus.isGranted) {
      await _handleDeniedSpeechPermission(
        microphoneStatus,
        'Bez přístupu k mikrofonu nelze diktovat.',
      );
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      var speechStatus = await Permission.speech.status;
      if (!speechStatus.isGranted) {
        speechStatus = await Permission.speech.request();
      }
      if (!mounted) return false;
      if (!speechStatus.isGranted) {
        await _handleDeniedSpeechPermission(
          speechStatus,
          'Bez povolení rozpoznávání řeči nelze diktovat.',
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _handleDeniedSpeechPermission(
    PermissionStatus status,
    String message,
  ) async {
    if (!status.isPermanentlyDenied && !status.isRestricted) {
      _showSpeechMessage(message);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Povolit diktování'),
        content: Text('$message Oprávnění můžeš zapnout v nastavení aplikace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: const Text('Otevřít nastavení'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechAvailable = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        options: [SpeechToText.androidNoBluetooth, SpeechToText.iosNoBluetooth],
      );
      _speechInitialized = true;
      if (!_speechAvailable) return;

      final locales = await _speechToText.locales();
      final czechLocales = locales.where(
        (locale) => locale.localeId.toLowerCase().startsWith('cs'),
      );
      _speechLocaleId = czechLocales.isNotEmpty
          ? czechLocales.first.localeId
          : (await _speechToText.systemLocale())?.localeId;
    } catch (_) {
      _speechInitialized = true;
      _speechAvailable = false;
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognized = result.recognizedWords.trim();
    if (recognized.isEmpty) return;
    final separator = _dictationPrefix.isEmpty ? '' : ' ';
    final text = '$_dictationPrefix$separator$recognized';
    _questionController
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    setState(() {
      _isListening = status == SpeechToText.listeningStatus;
    });
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() => _isListening = false);
    final message = switch (error.errorMsg) {
      'error_permission' ||
      'error_permission_denied' => 'Pro diktování je potřeba povolit mikrofon.',
      'error_no_match' => 'Řeči se nepodařilo porozumět. Zkus to znovu.',
      'error_network' => 'Rozpoznávání řeči teď nemá připojení.',
      _ => 'Diktování se přerušilo. Zkus to znovu.',
    };
    _showSpeechMessage(message);
  }

  void _showSpeechMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiAssistantControllerProvider);
    final controller = ref.read(aiAssistantControllerProvider.notifier);
    final usage = state.usage.valueOrNull;
    final canAsk = !state.submitting && (usage?.canAsk ?? false);
    final keyboardVisible = View.of(context).viewInsets.bottom > 0;

    ref.listen<int>(
      aiAssistantControllerProvider.select(
        (value) => value.questions.valueOrNull?.length ?? 0,
      ),
      (_, __) => _scrollToBottom(),
    );

    return Material(
      color: context.appColors.backgroundPrimary,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (!keyboardVisible)
              _AssistantHeader(state: state, onRefresh: controller.load),
            Expanded(
              child: state.questions.when(
                loading: () => const Center(child: Loader()),
                error: (error, _) => _LoadError(
                  message: error.toString(),
                  onRetry: controller.load,
                ),
                data: (questions) => _ConversationList(
                  controller: _scrollController,
                  questions: questions,
                  pendingQuestion: state.pendingQuestion,
                  errorMessage: state.errorMessage,
                  onSuggestionSelected: _useSuggestion,
                ),
              ),
            ),
            _QuestionComposer(
              controller: _questionController,
              focusNode: _questionFocusNode,
              enabled: canAsk,
              submitting: state.submitting,
              disabledText: _disabledText(usage),
              listening: _isListening,
              onDictation: _toggleDictation,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  String? _disabledText(AiUsage? usage) {
    if (usage == null) return 'Načítám dostupný limit…';
    if (!usage.enabled) return 'TrusBot není pro tento účet povolen.';
    if (!usage.canAsk) return 'Dnešní limit dotazů je vyčerpán.';
    return null;
  }
}

class _AssistantHeader extends StatelessWidget {
  final AiAssistantState state;
  final Future<void> Function() onRefresh;

  const _AssistantHeader({required this.state, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: const Text('💩', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Čus Trus! Jsem TrusBot',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zeptej se mě na cokoliv co se týká Liščího Trusu a statistik.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    state.usage.when(
                      loading: () => const _UsageChip(label: 'Načítám limit…'),
                      error: (_, __) => const _UsageChip(
                        label: 'Limit se nepodařilo načíst',
                        error: true,
                      ),
                      data: (usage) => _UsageChip(
                        label: usage.unlimited
                            ? '${usage.tierLabel} · neomezeně'
                            : '${usage.tierLabel} · ${usage.usedToday}/${usage.dailyLimit} dnes',
                        error: !usage.enabled || !usage.canAsk,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Informace o členství',
                onPressed: () => showMembershipInfo(context),
                icon: const Icon(Icons.info_outline_rounded),
              ),
              IconButton(
                tooltip: 'Obnovit',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageChip extends StatelessWidget {
  final String label;
  final bool error;

  const _UsageChip({required this.label, this.error = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = error ? colors.error : colors.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  final ScrollController controller;
  final List<AiQuestion> questions;
  final String? pendingQuestion;
  final String? errorMessage;
  final ValueChanged<String> onSuggestionSelected;

  const _ConversationList({
    required this.controller,
    required this.questions,
    required this.pendingQuestion,
    required this.errorMessage,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = questions.isEmpty && pendingQuestion == null;
    return ListView(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _HistoryHeader(questionCount: questions.length),
        if (isEmpty)
          _EmptyConversation(onSuggestionSelected: onSuggestionSelected),
        for (final question in questions) _QuestionPair(question: question),
        if (pendingQuestion != null) ...[
          _UserBubble(text: pendingQuestion!),
          const _AssistantThinkingBubble(),
        ],
        if (errorMessage != null) _InlineError(message: errorMessage!),
      ],
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  final int questionCount;

  const _HistoryHeader({required this.questionCount});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 2, 2, 10),
    child: Row(
      children: [
        Icon(
          Icons.history_rounded,
          size: 19,
          color: context.appColors.textSecondary,
        ),
        const SizedBox(width: 7),
        Text(
          'Historie',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (questionCount > 0)
          Text(
            '$questionCount ${_questionLabel(questionCount)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
      ],
    ),
  );

  String _questionLabel(int count) {
    if (count == 1) return 'dotaz';
    if (count >= 2 && count <= 4) return 'dotazy';
    return 'dotazů';
  }
}

class _EmptyConversation extends StatelessWidget {
  static const suggestions = [
    'Kdo letos vypil nejvíce piv?',
    'Jaké informace o mě víš?',
    'Řekni mi nějaké trusí pokřiky',
    'Co musím udělat abych splnil achievement Ledový muž?',
  ];

  final ValueChanged<String> onSuggestionSelected;

  const _EmptyConversation({required this.onSuggestionSelected});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
    child: Column(
      children: [
        const Text('💩', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          'Na co se chceš zeptat?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          'Vyber otázku nebo napiš vlastní.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        for (final suggestion in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onSuggestionSelected(suggestion),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(suggestion),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _QuestionPair extends StatelessWidget {
  final AiQuestion question;

  const _QuestionPair({required this.question});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _UserBubble(text: question.question),
      _AssistantBubble(
        text: question.answer,
        error:
            question.status == AiQuestionStatus.failed ||
            question.status == AiQuestionStatus.disabled,
      ),
    ],
  );
}

class _UserBubble extends StatelessWidget {
  final String text;

  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 330),
      margin: const EdgeInsets.only(left: 44, top: 8, bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    ),
  );
}

class _AssistantBubble extends StatelessWidget {
  final String text;
  final bool error;

  const _AssistantBubble({required this.text, this.error = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TrusBotAvatar(),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 350),
            margin: const EdgeInsets.only(right: 30, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: error
                  ? colors.errorContainer
                  : colors.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: TrusBotMarkdownText(
              data: text,
              color: error ? colors.onErrorContainer : colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssistantThinkingBubble extends StatelessWidget {
  const _AssistantThinkingBubble();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _TrusBotAvatar(),
      const SizedBox(width: 8),
      Flexible(
        child: Container(
          margin: const EdgeInsets.only(right: 80, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 9),
              Flexible(child: Text('TrusBot hledá v týmových datech…')),
            ],
          ),
        ),
      ),
    ],
  );
}

class _TrusBotAvatar extends StatelessWidget {
  const _TrusBotAvatar();

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    margin: const EdgeInsets.only(top: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: const Text('💩', style: TextStyle(fontSize: 17)),
  );
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
    ),
  );
}

class _QuestionComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool submitting;
  final String? disabledText;
  final bool listening;
  final VoidCallback onDictation;
  final VoidCallback onSubmit;

  const _QuestionComposer({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.submitting,
    required this.disabledText,
    required this.listening,
    required this.onDictation,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    elevation: 8,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (disabledText != null && !submitting) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 7),
              child: Text(
                disabledText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  minLines: 3,
                  maxLines: 3,
                  maxLength: 1000,
                  textInputAction: TextInputAction.newline,
                  scrollPadding: EdgeInsets.zero,
                  decoration: InputDecoration(
                    hintText: 'Zeptej se TrusBota…',
                    counterText: '',
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: listening ? 'Zastavit diktování' : 'Diktovat dotaz',
                onPressed: enabled ? onDictation : null,
                style: IconButton.styleFrom(
                  backgroundColor: listening
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: listening
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                icon: Icon(listening ? Icons.stop_rounded : Icons.mic_rounded),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: 'Odeslat dotaz',
                onPressed: enabled ? onSubmit : null,
                style: IconButton.styleFrom(
                  backgroundColor: context.appColors.accent,
                  foregroundColor: context.appColors.buttonForeground,
                  disabledBackgroundColor: context.appColors.disabled
                      .withValues(alpha: 0.25),
                  disabledForegroundColor: context.appColors.textMuted,
                ),
                icon: submitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.appColors.buttonForeground,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: enabled
                            ? context.appColors.buttonForeground
                            : context.appColors.textMuted,
                      ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _LoadError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Zkusit znovu'),
          ),
        ],
      ),
    ),
  );
}
