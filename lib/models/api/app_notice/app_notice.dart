enum AppNoticeActionType {
  close,
  openUrl,
  openScreen;

  static AppNoticeActionType fromJson(Object? value) {
    switch (value?.toString()) {
      case 'OPEN_URL':
        return AppNoticeActionType.openUrl;
      case 'OPEN_SCREEN':
        return AppNoticeActionType.openScreen;
      case 'CLOSE':
      default:
        return AppNoticeActionType.close;
    }
  }
}

enum AppNoticeActionStyle {
  primary,
  secondary;

  static AppNoticeActionStyle fromJson(Object? value) {
    return value?.toString() == 'SECONDARY'
        ? AppNoticeActionStyle.secondary
        : AppNoticeActionStyle.primary;
  }
}

class AppNoticeAction {
  final int id;
  final String label;
  final AppNoticeActionType type;
  final AppNoticeActionStyle style;
  final String? value;

  const AppNoticeAction({
    required this.id,
    required this.label,
    required this.type,
    required this.style,
    this.value,
  });

  factory AppNoticeAction.fromJson(Map<String, dynamic> json) {
    return AppNoticeAction(
      id: json['id'] as int,
      label: json['label'] as String? ?? '',
      type: AppNoticeActionType.fromJson(json['type']),
      style: AppNoticeActionStyle.fromJson(json['style']),
      value: json['value'] as String?,
    );
  }
}

class AppNotice {
  final int id;
  final String title;
  final String message;
  final bool dismissible;
  final List<AppNoticeAction> actions;

  const AppNotice({
    required this.id,
    required this.title,
    required this.message,
    required this.dismissible,
    required this.actions,
  });

  factory AppNotice.fromJson(Map<String, dynamic> json) {
    return AppNotice(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      dismissible: json['dismissible'] as bool? ?? true,
      actions: (json['actions'] as List<dynamic>? ?? const [])
          .map(
            (action) =>
                AppNoticeAction.fromJson(action as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class CurrentAppNotice {
  final AppNotice? notice;

  const CurrentAppNotice({required this.notice});

  factory CurrentAppNotice.fromJson(Map<String, dynamic> json) {
    final noticeJson = json['notice'];
    return CurrentAppNotice(
      notice: noticeJson is Map<String, dynamic>
          ? AppNotice.fromJson(noticeJson)
          : null,
    );
  }
}
