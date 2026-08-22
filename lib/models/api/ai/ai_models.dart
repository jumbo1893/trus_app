enum AiQuestionStatus {
  pending,
  completed,
  failed,
  limitReached,
  disabled,
  unknown;

  static AiQuestionStatus fromJson(String? value) => switch (value) {
    'PENDING' => AiQuestionStatus.pending,
    'COMPLETED' => AiQuestionStatus.completed,
    'FAILED' => AiQuestionStatus.failed,
    'LIMIT_REACHED' => AiQuestionStatus.limitReached,
    'DISABLED' => AiQuestionStatus.disabled,
    _ => AiQuestionStatus.unknown,
  };
}

class AiUsage {
  final String tier;
  final int usedToday;
  final int? dailyLimit;
  final int? remainingToday;
  final bool unlimited;
  final bool enabled;
  final DateTime date;

  const AiUsage({
    required this.tier,
    required this.usedToday,
    required this.dailyLimit,
    required this.remainingToday,
    required this.unlimited,
    required this.enabled,
    required this.date,
  });

  factory AiUsage.fromJson(Map<String, dynamic> json) => AiUsage(
    tier: json['tier'] as String? ?? 'STANDARD',
    usedToday: (json['usedToday'] as num?)?.toInt() ?? 0,
    dailyLimit: (json['dailyLimit'] as num?)?.toInt(),
    remainingToday: (json['remainingToday'] as num?)?.toInt(),
    unlimited: json['unlimited'] as bool? ?? false,
    enabled: json['enabled'] as bool? ?? true,
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
  );

  bool get canAsk => enabled && (unlimited || (remainingToday ?? 0) > 0);

  String get tierLabel => switch (tier) {
    'PREMIUM' => 'Premium',
    'ULTRA' => 'Ultra',
    _ => 'Standard',
  };
}

class AiQuestion {
  final int? id;
  final String question;
  final String answer;
  final AiQuestionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final AiUsage usage;

  const AiQuestion({
    required this.id,
    required this.question,
    required this.answer,
    required this.status,
    required this.createdAt,
    required this.completedAt,
    required this.usage,
  });

  factory AiQuestion.fromJson(Map<String, dynamic> json) => AiQuestion(
    id: (json['id'] as num?)?.toInt(),
    question: json['question'] as String? ?? '',
    answer: json['answer'] as String? ?? '',
    status: AiQuestionStatus.fromJson(json['status'] as String?),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    usage: AiUsage.fromJson(
      (json['usage'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
  );
}
