import 'package:flutter_test/flutter_test.dart';

import 'package:lab_04_05/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryApp());

    expect(find.text('Current Shipment'), findsOneWidget);
    expect(find.text('Recent Shipment'), findsOneWidget);
    expect(find.text('Mac Mini M4 Pro'), findsWidgets);
  });
}