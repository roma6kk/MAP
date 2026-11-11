import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lab_09/main.dart';
import 'package:lab_09/models/app_user.dart';
import 'package:lab_09/models/favorite.dart';
import 'package:lab_09/models/shipment.dart';
import 'package:lab_09/services/hive_service.dart';

late Directory _dir;
var _n = 0;

Shipment _ship(String id) => Shipment(
      id: id,
      image: 'missing.png',
      name: 'Item $id',
      status: 'Pending',
      fromPlace: 'A',
      toPlace: 'B',
      sentDate: 'd1',
      estimatedDate: 'd2',
      description: 'desc',
    );

/// Свежие in-memory боксы (bytes: пустой буфер — файл на диске не создаётся).
Future<HiveService> _hive() async {
  final i = _n++;
  final users = await Hive.openBox<AppUser>('users$i', bytes: Uint8List(0));
  final shipments = await Hive.openBox<Shipment>('shipments$i', bytes: Uint8List(0));
  final favorites = await Hive.openBox<Favorite>('favorites$i', bytes: Uint8List(0));
  await users.putAll({
    'u1': AppUser(id: 'u1', name: 'Anna', role: UserRole.admin),
    'u3': AppUser(id: 'u3', name: 'John', role: UserRole.user),
  });
  await shipments.putAll({'S1': _ship('S1'), 'S2': _ship('S2')});
  return HiveService.withBoxes(users, shipments, favorites);
}

String? _badge(WidgetTester tester) {
  final badge = tester.widget<Badge>(find.byKey(const Key('favorites-badge')));
  return badge.isLabelVisible ? (badge.label as Text).data : null;
}

void main() {
  setUpAll(() async {
    _dir = await Directory.systemTemp.createTemp('hive_p');
    Hive
      ..init(_dir.path)
      ..registerAdapter(AppUserAdapter())
      ..registerAdapter(ShipmentAdapter())
      ..registerAdapter(FavoriteAdapter());
  });
  tearDownAll(() => _dir.delete(recursive: true));

  testWidgets('карточка в списке и бейдж в шапке связаны через общий FavoritesProvider', (tester) async {
    final hive = await tester.runAsync(_hive);
    await tester.pumpWidget(DeliveryApp(hive: hive!));
    expect(_badge(tester), isNull);

    await tester.tap(find.byKey(const Key('fav-S1')));
    await tester.pumpAndSettle();
    expect(_badge(tester), '1');

    await tester.tap(find.byKey(const Key('fav-S2')));
    await tester.pumpAndSettle();
    expect(_badge(tester), '2');
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(2));
  });

  testWidgets('смена пользователя: ProxyProvider переключает избранное, FAB зависит от роли', (tester) async {
    final hive = await tester.runAsync(_hive);
    await tester.pumpWidget(DeliveryApp(hive: hive!));
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byKey(const Key('fav-S1')));
    await tester.pumpAndSettle();
    expect(_badge(tester), '1');

    await tester.tap(find.text('Current user (tap to switch)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('John'));
    await tester.pumpAndSettle();

    expect(find.text('John · user'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(_badge(tester), isNull, reason: 'у John своё (пустое) избранное');
    expect(tester.takeException(), isNull);
  });

  testWidgets('экран избранного и детали обновляются без setState', (tester) async {
    final hive = await tester.runAsync(_hive);
    await tester.pumpWidget(DeliveryApp(hive: hive!));

    await tester.tap(find.byTooltip('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Избранное пусто'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Item S2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Item S2'), findsOneWidget);
    expect(find.text('Favorites — Anna'), findsOneWidget);
  });
}
