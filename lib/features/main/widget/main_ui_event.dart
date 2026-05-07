import 'package:trus_app/features/main/main_ui_event_type.dart';

class MainUiEvent {
  final MainUiEventType type;
  final int id;

  const MainUiEvent({
    required this.type,
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MainUiEvent &&
              runtimeType == other.runtimeType &&
              type == other.type &&
              id == other.id;

  @override
  int get hashCode => Object.hash(type, id);
}