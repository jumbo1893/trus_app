import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';

import 'cookie_manager.dart';
import 'custom_cookie_manager.dart';


class HeaderProvider {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final CustomCookieManager _cookieJar = CookieManager().cookieJar;
  final Ref ref;

  CustomCookieManager get cookieJar => _cookieJar;

  HeaderProvider(this.ref);

  Future<Map<String, String>> getHeaders() async {
    final cookies = _cookieJar.getCookies();
    final deviceInfo = await _getDeviceInfo();
    final appTeamHeader = await _getAppTeamHeader();
    return {
      ...cookies,
      'Content-Type': 'application/json; charset=UTF-8',
      'app-team-id': '1',
      'device': deviceInfo,
      if (appTeamHeader != null) ...appTeamHeader,
    };
  }

  Future<String> _getDeviceInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      return 'android ${androidInfo.version.release} - ${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      return 'ios ${iosInfo.systemVersion} - ${iosInfo.name}';
    }
    return 'unknown';
  }

  Future<Map<String, String>?> _getAppTeamHeader() async {
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
    if (appTeam != null) {
      return {'app-team-id': appTeam.id.toString()};
    }
    return null;
  }
}