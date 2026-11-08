import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../models/developer.dart';

class IsolateReport {
  IsolateReport(this.count, this.millis, this.path);
  final int count;
  final int millis;
  final String path;
}

List<Developer> _generate(int n) => List.generate(
      n,
      (i) => Developer(
        id: i,
        name: 'Developer #$i',
        specialty: i.isEven ? 'Flutter / Dart' : 'Backend / API',
        role: Developer.roles[i % 2],
        salary: 50000.0 + (i % 100) * 1000,
        cupsOfCoffee: i % 10,
      ),
    );

class _WriteJob {
  _WriteJob(this.path, this.count, this.reply);
  final String path;
  final int count;
  final SendPort reply;
}

void _writeEntry(_WriteJob job) {
  final sw = Stopwatch()..start();
  final json = jsonEncode(_generate(job.count).map((d) => d.toJson()).toList());
  File(job.path).writeAsStringSync(json);
  job.reply.send(sw.elapsedMilliseconds);
}

Future<IsolateReport> writeWithSpawn(String path, int count) async {
  final port = ReceivePort();
  final isolate = await Isolate.spawn(_writeEntry, _WriteJob(path, count, port.sendPort));
  final millis = await port.first as int;
  port.close();
  isolate.kill();
  return IsolateReport(count, millis, path);
}

List<Developer> _parse(String path) {
  final list = jsonDecode(File(path).readAsStringSync()) as List;
  return list
      .map((e) => Developer.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<IsolateReport> readWithCompute(String path) async {
  final sw = Stopwatch()..start();
  final list = await compute(_parse, path);
  return IsolateReport(list.length, sw.elapsedMilliseconds, path);
}

IsolateReport readInMain(String path) {
  final sw = Stopwatch()..start();
  final list = _parse(path);
  return IsolateReport(list.length, sw.elapsedMilliseconds, path);
}
