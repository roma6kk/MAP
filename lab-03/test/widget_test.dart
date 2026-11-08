import 'package:flutter_test/flutter_test.dart';

import 'package:lab_03/main.dart';

void main() {
  testWidgets('Лабораторная 3: команда и отчёт по заданиям', (tester) async {
    await tester.pumpWidget(const DeveloperLabApp());
    expect(find.textContaining('Лабораторная 3'), findsOneWidget);
    expect(find.text('Анна'), findsOneWidget);
    expect(find.text('Мария'), findsOneWidget);

    // Задание 5: отчёт собирается через Future<T> — продвигаем
    // фейковое время, чтобы все await/таймеры выполнились.
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));

    expect(find.textContaining('Задание 1. Mixins'), findsOneWidget);
    expect(find.textContaining('Comparable / Iterator / Iterable'), findsOneWidget);
    expect(find.textContaining('Задание 3. Сериализация в JSON'), findsOneWidget);
    expect(find.textContaining('Задание 5. Future'), findsOneWidget);
    expect(find.textContaining('подписка отменена (cancel())'), findsOneWidget);
    expect(find.textContaining('Broadcast stream'), findsOneWidget);
  });
}