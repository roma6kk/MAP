import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_06/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryApp());

    expect(find.text('Current Shipment'), findsOneWidget);
    expect(find.text('Recent Shipment'), findsOneWidget);
    expect(find.text('Mac Mini M4 Pro'), findsWidgets);
  });

  testWidgets('tap on recent shipment opens details with passed data', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryApp());
    await tester.pumpAndSettle();

    // DJI Drone — третья карточка в списке Recent, изначально ниже области
    // видимости: сначала доскролливаем её, затем тапаем.
    final drone = find.text('DJI Drone');
    await tester.scrollUntilVisible(drone, 200, scrollable: find.byType(Scrollable));
    await tester.pumpAndSettle();
    await tester.tap(drone);
    await tester.pumpAndSettle();

    expect(find.text('Shipment Details'), findsOneWidget);
    expect(find.text('ID: K37956307'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
  });
}