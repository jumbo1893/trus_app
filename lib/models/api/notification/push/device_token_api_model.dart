import 'package:trus_app/config.dart';

import '../../interfaces/json_and_http_converter.dart';
class DeviceTokenApiModel implements JsonAndHttpConverter {
  final String token;

  DeviceTokenApiModel({
    required this.token,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "token": token,
    };
  }

  @override
  factory DeviceTokenApiModel.fromJson(Map<String, dynamic> json) {
    return DeviceTokenApiModel(
      token: json["token"] ?? "",
    );
  }

  @override
  String httpRequestClass() {
    return tokenApi;
  }
}
