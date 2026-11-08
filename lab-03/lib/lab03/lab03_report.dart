import 'dart:convert';

import 'async_demo.dart';
import 'developer.dart';

Future<String> buildLabReport() async {
  final lines = <String>[];

  // ! 1
  final flutter = FlutterDeveloper('Анна', 120000);
  final backend = BackendDeveloper('Мария', 145000);
  final intern = FlutterDeveloper.intern('Илья');

  lines.add('Задание 1. Mixins');
  lines.add(
      '  class FlutterDeveloper extends DeveloperBase with CoffeeLover, CodeReviewer, Reportable');
  lines.add(
      '  class BackendDeveloper  extends DeveloperBase with Presenter, CodeReviewer, Reportable');
  lines.add('  ${flutter.drinkCoffee()}');
  lines.add('  ${flutter.drinkCoffee()}');
  lines.add('  ${flutter.reviewCode(file: 'lib/main.dart', approve: true)}');
  lines.add('  ${backend.present('REST API')}');
  lines.add('  ${flutter.buildReport()}');
  lines.add('  ${backend.buildReport()}');
  lines.add(
      '  Всего создано FlutterDeveloper: ${FlutterDeveloper.totalDevelopers}, стек: ${FlutterDeveloper.stack()}');
  lines.add('  (mixins нельзя инстанцировать: CoffeeLover() — ошибка компиляции)');

  // ! 2
  final team = Team()..add(flutter)..add(backend)..add(intern);

  lines.add('Задание 2. Comparable / Iterator / Iterable');
  lines.add('  Исходный порядок:');
  for (final d in team) {
    lines.add('   - $d');
  }

  team.sortBySalary();
  lines.add('  После team.sortBySalary() (работает Comparable.compareTo):');
  for (final d in team) {
    lines.add('   - $d — ${d.salary.toStringAsFixed(0)} ₽');
  }

  final iterator = team.iterator;
  final viaIterator = <String>[];
  while (iterator.moveNext()) {
    viaIterator.add(iterator.current.name);
  }
  lines.add('  Явный Iterator (moveNext/current): ${viaIterator.join(' -> ')}');

  final rich = team.where((d) => d.salary > 100000).map((d) => d.name).join(', ');
  lines.add('  where(salary > 100000) -> $rich');
  lines.add(
      '  map(toUpperCase) -> ${team.map((d) => d.name.toUpperCase()).join(', ')}');
  lines.add(
      '  fold -> сумма зарплат: ${team.fold(0, (sum, d) => sum + d.salary.toInt())} ₽');
  lines.add(
      '  any(salary <= 50000 — есть ли стажёр) -> ${team.any((d) => d.salary <= 50000)}');

  // ! 3
  final toSave = FlutterDeveloper('Борис', 98000)..drinkCoffee();
  final json = toSave.toJson();
  final encoded = jsonEncode(json);
  final restored =
      DeveloperBase.fromJson(jsonDecode(encoded) as Map<String, dynamic>);

  lines.add('Задание 3. Сериализация в JSON');
  lines.add('  toJson() -> $json');
  lines.add('  jsonEncode() -> $encoded');
  lines.add(
      '  jsonDecode() + DeveloperBase.fromJson() -> ${(restored as Reportable).buildReport()}');
  if (restored is FlutterDeveloper) {
    lines.add(
        '  Восстановлен подкласс ${restored.runtimeType}, состояние mixin: cupsOfCoffee = ${restored.cupsOfCoffee}');
  }

  final project = Project('Мобильное приложение', ['Flutter', 'Dart']);
  final projectJson = jsonEncode(project.toJson());
  final restoredProject =
      Project.fromJson(jsonDecode(projectJson) as Map<String, dynamic>);
  lines.add(
      '  Project: $projectJson -> «${restoredProject.title}», ${restoredProject.technologies}');

  // !  4
  lines.add('Задание 4. Асинхронный метод (имитация загрузки с сервера)');
  final loaded = await fetchProjectFromServer('Мобильное приложение');
  lines.add('  await fetchProjectFromServer(...) -> $loaded');

  // ! 5
  lines.add('Задание 5. Future<T>');
  lines.add('  ${await demoFutureAwait()}');
  lines.add('  ${await demoFutureChain()}');
  lines.add('  ${await demoFutureError()}');
  lines.add('  ${await demoFutureErrorCallback()}');

  // ! 6
  lines.add('Задание 6. Stream<T> — single subscription: подписка, map/where, cancel()');
  lines.add(await demoSingleSubscriptionStream());
  lines.add('  ---');
  lines.add('  Ошибка в потоке (async* throw):');
  lines.add(await demoStreamError());
  lines.add('  ---');
  lines.add(await demoSecondListenFails());
  lines.add('  ---');
  lines.add('  Broadcast stream (asBroadcastStream, два подписчика):');
  lines.add(await demoBroadcastStream());

  return lines.join('\n');
}