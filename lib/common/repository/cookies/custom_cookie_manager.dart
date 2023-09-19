import 'package:http/http.dart' as http;

class CustomCookieManager {
  final Map<String, String> _headers = {};
  //Map<String, String> _cookies = {};


  String? getCookie(String name) {
    return _headers[name];
  }

  Map<String, String> getCookies() {
    return _headers;
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      _headers['cookie'] =
      (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}