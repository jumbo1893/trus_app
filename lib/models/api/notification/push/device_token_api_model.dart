import 'package:trus_app/config.dart';

import '../../interfaces/json_and_http_converter.dart';

class DeviceTokenApiModel implements JsonAndHttpConverter {
  final String token;
  final String clientDeviceId;

  DeviceTokenApiModel({
    required this.token,
    required this.clientDeviceId,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "clientDeviceId": clientDeviceId,
    };
  }

  factory DeviceTokenApiModel.fromJson(Map<String, dynamic> json) {
    return DeviceTokenApiModel(
      token: json["token"] ?? "",
      clientDeviceId: json["clientDeviceId"] ?? "",
    );
  }

  @override
  String httpRequestClass() {
    return tokenApi;
  }
}