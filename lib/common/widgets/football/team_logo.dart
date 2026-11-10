import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:trus_app/theme/app_colors.dart';

class TeamLogo extends StatelessWidget {
  const TeamLogo({super.key, this.url, this.size = 36});

  final String? url;
  final double size;

  static final Map<String, Future<Uint8List?>> _processed = {};

  static Future<Uint8List?> _load(String url) {
    return _processed.putIfAbsent(url, () {
      if (_processed.length >= 128) {
        _processed.remove(_processed.keys.first);
      }
      return _fetchAndProcess(url).then((bytes) {
        if (bytes == null) _processed.remove(url);
        return bytes;
      });
    });
  }

  static Future<Uint8List?> _fetchAndProcess(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 12),
      );
      if (response.statusCode != 200 ||
          response.bodyBytes.length > 2 * 1024 * 1024) {
        return null;
      }
      return await compute(removeWhiteBackground, response.bodyBytes);
    } catch (_) {
      _processed.remove(url);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url ?? '');
    final valid = uri != null && uri.scheme == 'https' && uri.host == 'pkfl.cz';
    final fallback = Icon(
      Icons.shield_outlined,
      size: size * 0.75,
      color: context.appColors.accent,
    );

    return SizedBox(
      width: size,
      height: size,
      child: !valid
          ? fallback
          : FutureBuilder<Uint8List?>(
              future: _load(url!),
              builder: (context, snapshot) {
                final bytes = snapshot.data;
                return bytes == null
                    ? fallback
                    : Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => fallback,
                      );
              },
            ),
    );
  }
}

@visibleForTesting
Uint8List? removeWhiteBackground(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  final scale = decoded.width > decoded.height ? decoded.width : decoded.height;
  final source = scale > 256
      ? img.copyResize(
          decoded,
          width: (decoded.width * 256 / scale).round(),
          height: (decoded.height * 256 / scale).round(),
        )
      : decoded;
  final image = source.convert(format: img.Format.uint8, numChannels: 4);
  final width = image.width;
  final height = image.height;
  final visited = Uint8List(width * height);
  final queue = Int32List(width * height);
  var head = 0;
  var tail = 0;

  bool isBackground(int x, int y) {
    final pixel = image.getPixel(x, y);
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    return min >= 225 && max - min <= 30;
  }

  void add(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    final index = y * width + x;
    if (visited[index] != 0 || !isBackground(x, y)) return;
    visited[index] = 1;
    queue[tail++] = index;
  }

  for (var x = 0; x < width; x++) {
    add(x, 0);
    add(x, height - 1);
  }
  for (var y = 0; y < height; y++) {
    add(0, y);
    add(width - 1, y);
  }

  while (head < tail) {
    final index = queue[head++];
    final x = index % width;
    final y = index ~/ width;
    final pixel = image.getPixel(x, y);
    image.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 0);
    add(x - 1, y);
    add(x + 1, y);
    add(x, y - 1);
    add(x, y + 1);
  }

  return Uint8List.fromList(img.encodePng(image));
}
