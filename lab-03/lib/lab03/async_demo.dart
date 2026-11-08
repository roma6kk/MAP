import 'dart:async';

// ! 4

Future<String> fetchProjectFromServer(String title) async {
  await Future.delayed(const Duration(milliseconds: 300));
  if (title.isEmpty) {
    throw ArgumentError('название проекта не может быть пустым');
  }
  return 'Проект «$title» загружен с сервера';
}

// ! 5

// Способ 1
Future<String> demoFutureAwait() async {
  final data = await fetchProjectFromServer('Мобильное приложение');
  return 'await-стиль: $data';
}

// Способ 2
Future<String> demoFutureChain() {
  return fetchProjectFromServer('Веб-сервис')
      .then((data) => '$data - валидация пройдена')
      .then((data) => '$data - сохранено в кэш')
      .then((data) => 'then-цепочка: $data');
}

Future<String> demoFutureError() async {
  try {
    await fetchProjectFromServer('');
    return 'ошибки не было';
  } on ArgumentError catch (error) {
    return 'try/catch: поймали ArgumentError — «${error.message}»';
  }
}

Future<String> demoFutureErrorCallback() {
  return Future<String>.error(
          TimeoutException('сервер не ответил', const Duration(seconds: 2)))
      .then((value) => 'этот then не выполнится')
      .catchError((Object error) => 'catchError: обработали $error');
}

// ! 6 single subscription / broadcast

Stream<int> buildTicks({int count = 5}) async* {
  for (var tick = 1; tick <= count; tick++) {
    await Future.delayed(const Duration(milliseconds: 50));
    yield tick;
  }
}

Stream<String> compileSources({required int count}) async* {
  for (var step = 1; step <= count; step++) {
    await Future.delayed(const Duration(milliseconds: 50));
    if (step == count) throw Exception('ошибка компиляции на шаге $step');
    yield 'шаг $step: OK';
  }
}

Future<String> demoSingleSubscriptionStream() async {
  final lines = <String>[];
  var received = 0;
  final finished = Completer<void>();

  late final StreamSubscription<int> subscription;
  subscription = buildTicks(count: 5)
      .map((tick) => tick * 10)
      .where((value) => value.isEven)
      .listen(
    (value) {
      received++;
      lines.add('  событие $received: $value');
      if (received == 2) {
        subscription.cancel(); // отмена подписки
        lines.add('  подписка отменена (cancel()) после 2 событий');
        finished.complete();
      }
    },
    onDone: finished.complete,
    onError: finished.completeError,
  );

  await finished.future;
  return lines.join('\n');
}

Future<String> demoStreamError() async {
  final lines = <String>[];
  final finished = Completer<void>();

  compileSources(count: 3).listen(
    (event) => lines.add('  $event'),
    onError: (Object error) => lines.add('  onError: $error'),
    onDone: finished.complete,
  );

  await finished.future;
  return lines.join('\n');
}

Future<String> demoSecondListenFails() async {
  final stream = buildTicks(count: 1);
  stream.listen((_) {});
  try {
    stream.listen((_) {});
    return 'вторая подписка прошла';
  } on StateError {
    return 'вторая подписка отклонена: StateError '
        '(stream has already been listened to)';
  }
}

// Broadcast stream
Future<String> demoBroadcastStream() async {
  final lines = <String>[];

  Stream<String> releaseFeed() async* {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    yield 'релиз 1.0';
    await Future<void>.delayed(const Duration(milliseconds: 30));
    yield 'релиз 1.1';
    await Future<void>.delayed(const Duration(milliseconds: 30));
    yield 'релиз 1.2';
  }

  final broadcast = releaseFeed().asBroadcastStream();
  final got1 = <String>[];
  final got2 = <String>[];

  broadcast.listen(got1.add);
  final sub2 = broadcast.listen(got2.add);

  await Future<void>.delayed(const Duration(milliseconds: 70));
  sub2.cancel();
  lines.add('  подписчик 2 отменил подписку (cancel())');

  await Future<void>.delayed(const Duration(milliseconds: 70));
  await broadcast.drain<void>(); // дожидаемся конца потока
  for (final event in got1) {
    lines.add('  подписчик 1: $event');
  }
  for (final event in got2) {
    lines.add('  подписчик 2: $event');
  }
  lines.add('  после cancel() подписчик 2 не получил «релиз 1.2»');
  return lines.join('\n');
}