class MatchWeatherApiModel {
  final double? temperature;
  final double? apparentTemperature;
  final int? relativeHumidity;
  final double? precipitation;
  final double? rain;
  final double? snowfall;
  final String? weatherCode;
  final int? cloudCover;
  final double? windSpeed;
  final double? windGusts;
  final int? windDirection;
  final double? surfacePressure;
  final bool? day;
  final DateTime? measuredAt;
  final double? latitude;
  final double? longitude;
  final String? provider;
  final String? sourceType;
  final DateTime? createdAt;

  const MatchWeatherApiModel({
    this.temperature,
    this.apparentTemperature,
    this.relativeHumidity,
    this.precipitation,
    this.rain,
    this.snowfall,
    this.weatherCode,
    this.cloudCover,
    this.windSpeed,
    this.windGusts,
    this.windDirection,
    this.surfacePressure,
    this.day,
    this.measuredAt,
    this.latitude,
    this.longitude,
    this.provider,
    this.sourceType,
    this.createdAt,
  });

  factory MatchWeatherApiModel.fromJson(Map<String, dynamic> json) {
    return MatchWeatherApiModel(
      temperature: _toDouble(json["temperature"]),
      apparentTemperature: _toDouble(json["apparentTemperature"]),
      relativeHumidity: _toInt(json["relativeHumidity"]),
      precipitation: _toDouble(json["precipitation"]),
      rain: _toDouble(json["rain"]),
      snowfall: _toDouble(json["snowfall"]),
      weatherCode: json["weatherCode"] as String?,
      cloudCover: _toInt(json["cloudCover"]),
      windSpeed: _toDouble(json["windSpeed"]),
      windGusts: _toDouble(json["windGusts"]),
      windDirection: _toInt(json["windDirection"]),
      surfacePressure: _toDouble(json["surfacePressure"]),
      day: json["day"] as bool?,
      measuredAt: _toDateTime(json["measuredAt"]),
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      provider: json["provider"] as String?,
      sourceType: json["sourceType"] as String?,
      createdAt: _toDateTime(json["createdAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "temperature": temperature,
      "apparentTemperature": apparentTemperature,
      "relativeHumidity": relativeHumidity,
      "precipitation": precipitation,
      "rain": rain,
      "snowfall": snowfall,
      "weatherCode": weatherCode,
      "cloudCover": cloudCover,
      "windSpeed": windSpeed,
      "windGusts": windGusts,
      "windDirection": windDirection,
      "surfacePressure": surfacePressure,
      "day": day,
      "measuredAt": measuredAt?.toIso8601String(),
      "latitude": latitude,
      "longitude": longitude,
      "provider": provider,
      "sourceType": sourceType,
      "createdAt": createdAt?.toIso8601String(),
    };
  }

  bool get hasTemperature => temperature != null;

  bool get hasPrecipitation =>
      (precipitation ?? 0) > 0 ||
          (rain ?? 0) > 0 ||
          (snowfall ?? 0) > 0;

  String temperatureToString() {
    if (temperature == null) {
      return "";
    }

    return "${temperature!.toStringAsFixed(1)} °C";
  }

  String apparentTemperatureToString() {
    if (apparentTemperature == null) {
      return "";
    }

    return "${apparentTemperature!.toStringAsFixed(1)} °C";
  }

  String humidityToString() {
    if (relativeHumidity == null) {
      return "";
    }

    return "$relativeHumidity %";
  }

  String windSpeedToString() {
    if (windSpeed == null) {
      return "";
    }

    return "${windSpeed!.toStringAsFixed(1)} km/h";
  }

  String weatherToString() {
    final parts = <String>[];

    if (weatherCode != null && weatherCode!.isNotEmpty) {
      parts.add(weatherCode!);
    }

    if (temperature != null) {
      parts.add(temperatureToString());
    }

    return parts.join(", ");
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}