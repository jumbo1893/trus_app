import 'package:dio/dio.dart';

class CustomCookieManager {
  final Map<String, String> _headers = {};
  //Map<String, String> _cookies = {};


  String? getCookie(String name) {
    return _headers[name];
  }

  Map<String, String> getCookies() {
    return _headers;
  }

  void updateCookie(Response<dynamic> response) {
    List<String>? rawCookies  = response.headers['set-cookie'];
    if (rawCookies != null) {
      _headers['cookie'] = rawCookies.join('; ');
    }
  }
}