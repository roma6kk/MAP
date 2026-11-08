import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_04_05/main.dart';
import 'package:lab_04_05/screens/tracking_screen.dart';
import 'package:lab_04_05/theme.dart';

const _images = [
  AppImages.truckRed,
  AppImages.box,
  AppImages.boxBig,
  AppImages.macMini,
  AppImages.speaker,
  AppImages.drone,
  AppImages.courier,
  AppImages.mapBase,
];

Future<void> _precacheImages(WidgetTester tester, BuildContext context) async {
  await tester.runAsync(() async {
    for (final path in _images) {
      await precacheImage(AssetImage(path), context);
    }
  });
}

void main() {
  testWidgets('capture home screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    await tester.pumpWidget(const DeliveryApp());
    await _precacheImages(tester, tester.element(find.byType(DeliveryApp)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(DeliveryApp),
      matchesGoldenFile('screenshots/home_screen.png'),
    );
    tester.view.reset();
  });

  testWidgets('capture tracking screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(body: TrackingScreen()),
    ));
    await _precacheImages(tester, tester.element(find.byType(TrackingScreen)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('screenshots/tracking_screen.png'),
    );
    tester.view.reset();
  });
}
