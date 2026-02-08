enum NotificationType {
  global,
  threeDaysBefore,
  oneDayBefore,
  afterResult,
  refereeComment,
  beer,
  fine,
  unknown
}

/// Mapování serverových stringů <-> FE enum
NotificationType notificationTypeFromServer(Object? raw) {
  if (raw == null) return NotificationType.unknown;
  final s = raw.toString().trim();

  // normalize: UPPER_SNAKE
  final upper = s.toUpperCase();

  switch (upper) {
    case 'GLOBAL':
      return NotificationType.global;
    case 'THREE_DAYS_BEFORE':
      return NotificationType.threeDaysBefore;
    case 'ONE_DAY_BEFORE':
      return NotificationType.oneDayBefore;
    case 'AFTER_RESULT':
      return NotificationType.afterResult;
    case 'REFEREE_COMMENT':
      return NotificationType.refereeComment;
    case 'BEER':
      return NotificationType.beer;
    case 'FINE':
      return NotificationType.fine;
    default:
      return NotificationType.unknown;
  }
}

String notificationTypeToServer(NotificationType t) {
  switch (t) {
    case NotificationType.global:
      return 'GLOBAL';
    case NotificationType.threeDaysBefore:
      return 'THREE_DAYS_BEFORE';
    case NotificationType.oneDayBefore:
      return 'ONE_DAY_BEFORE';
    case NotificationType.afterResult:
      return 'AFTER_RESULT';
    case NotificationType.refereeComment:
      return 'REFEREE_COMMENT';
    case NotificationType.beer:
      return 'BEER';
    case NotificationType.fine:
      return 'FINE';
    case NotificationType.unknown:
      return 'UNKNOWN';
  }
}