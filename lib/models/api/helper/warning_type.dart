enum WarningType {
  info,
  warning,
  error,
  nullType,
  success,
}

extension WarningTypeExtension on WarningType {
  static WarningType? fromJson(String? value) {
    switch (value) {
      case "INFO":
        return WarningType.info;
      case "WARNING":
        return WarningType.warning;
      case "ERROR":
        return WarningType.error;
      case "NULL":
        return WarningType.nullType;
      case "SUCCESS":
        return WarningType.nullType;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case WarningType.info:
        return "INFO";
      case WarningType.warning:
        return "WARNING";
      case WarningType.error:
        return "ERROR";
      case WarningType.nullType:
        return "NULL";
        case WarningType.success:
        return "SUCCESS";
    }
  }
}