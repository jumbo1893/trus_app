import 'dart:io';

import 'package:web_socket_channel/io.dart';

IOWebSocketChannel createInsecureChannel(String url) {
  final client = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

  return IOWebSocketChannel.connect(
    Uri.parse(url),
    customClient: client,
  );
}
