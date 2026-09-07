import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData previewTheme() {
  final theme = AppTheme.light();
  if (Platform.environment['UX_PREVIEWS'] != '1') return theme;
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Roboto'),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: 'Roboto',
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: 'Roboto', fontSize: 12),
      ),
    ),
  );
}

Future<void> loadPreviewFont() async {
  if (Platform.environment['UX_PREVIEWS'] != '1') return;
  final font = File(
    Platform.environment['UX_PREVIEW_FONT'] ??
        '${Platform.environment['WINDIR'] ?? 'C:/Windows'}/Fonts/segoeui.ttf',
  );
  if (await font.exists()) {
    for (final family in ['Roboto', 'Ahem']) {
      final loader = FontLoader(
        family,
      )..addFont(font.readAsBytes().then((data) => ByteData.sublistView(data)));
      await loader.load();
    }
  }
  final icons = File(
    Platform.environment['UX_PREVIEW_ICON_FONT'] ??
        '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/MaterialIcons-Regular.otf',
  );
  if (await icons.exists()) {
    await (FontLoader('MaterialIcons')..addFont(
          icons.readAsBytes().then((data) => ByteData.sublistView(data)),
        ))
        .load();
  }
}

Future<void> capturePreview(WidgetTester tester, String name) async {
  if (Platform.environment['UX_PREVIEWS'] != '1') return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).first,
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('../../tmp/ux-previews');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
