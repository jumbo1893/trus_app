import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/widgets/system_navigation_safe_area.dart';

void main() {
  testWidgets('bottom action stays above the system navigation inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: 32);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewPadding();
    });

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SystemNavigationSafeArea(child: child!),
        home: Scaffold(
          bottomNavigationBar: SizedBox(
            height: 64,
            child: TextButton(onPressed: () {}, child: const Text('Akce')),
          ),
        ),
      ),
    );

    expect(tester.getBottomLeft(find.text('Akce')).dy, lessThanOrEqualTo(768));
    expect(tester.getBottomLeft(find.byType(Scaffold)).dy, 768);
  });
}
