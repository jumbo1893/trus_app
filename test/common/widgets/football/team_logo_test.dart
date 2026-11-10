import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trus_app/common/widgets/football/team_logo.dart';

void main() {
  test('removes edge white but keeps enclosed white parts of a crest', () {
    final source = img.Image(width: 5, height: 5, numChannels: 4);
    img.fill(source, color: img.ColorRgba8(255, 255, 255, 255));
    for (var y = 1; y <= 3; y++) {
      for (var x = 1; x <= 3; x++) {
        source.setPixelRgba(x, y, 0, 0, 0, 255);
      }
    }
    source.setPixelRgba(2, 2, 255, 255, 255, 255);

    final output = removeWhiteBackground(
      Uint8List.fromList(img.encodePng(source)),
    );
    expect(output, isNotNull);
    final result = img.decodePng(output!)!;
    expect(result.getPixel(0, 0).a, 0);
    expect(result.getPixel(1, 1).a, 255);
    expect(result.getPixel(2, 2).a, 255);
  });
}
