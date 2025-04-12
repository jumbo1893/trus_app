import 'dart:io';

import 'custom_cookie_manager.dart';




class CookieManager {
  static final CookieManager _instance = CookieManager._internal();
  List<Cookie> cookies = [];

  factory CookieManager() {
    return _instance;
  }

  CookieManager._internal() {
    _cookieJar = CustomCookieManager();
  }

  late CustomCookieManager _cookieJar;

  CustomCookieManager get cookieJar => _cookieJar;

}
