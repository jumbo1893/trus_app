enum MatchParticipationStatus { attending, maybe, notAttending }

extension MatchParticipationStatusExtension on MatchParticipationStatus {
  static MatchParticipationStatus? fromJson(String? value) {
    switch (value) {
      case 'ATTENDING':
        return MatchParticipationStatus.attending;
      case 'MAYBE':
        return MatchParticipationStatus.maybe;
      case 'NOT_ATTENDING':
        return MatchParticipationStatus.notAttending;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case MatchParticipationStatus.attending:
        return 'ATTENDING';
      case MatchParticipationStatus.maybe:
        return 'MAYBE';
      case MatchParticipationStatus.notAttending:
        return 'NOT_ATTENDING';
    }
  }

  String get label {
    switch (this) {
      case MatchParticipationStatus.attending:
        return 'Zúčastním se';
      case MatchParticipationStatus.maybe:
        return 'Možná';
      case MatchParticipationStatus.notAttending:
        return 'Nezúčastním se';
    }
  }
}
