import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/isolate_service.dart';

class IsolateScreen extends StatefulWidget {
  const IsolateScreen({super.key});

  @override
  State<IsolateScreen> createState() => _IsolateScreenState();
}

class _IsolateScreenState extends State<IsolateScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();
  final _log = <String>[];
  bool _busy = false;
  static const _count = 200000;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<String> get _path async =>
      '${(await getTemporaryDirectory()).path}/developers_big.json';

  Future<void> _guard(Future<void> Function() body) async {
    setState(() => _busy = true);
    try {
      await body();
    } catch (e) {
      _log.insert(0, 'Ошибка: $e');
    }
    if (mounted) setState(() => _busy = false);
  }

  void _add(String s) => setState(() => _log.insert(0, s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Изоляты')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: RotationTransition(
                turns: _ctrl,
                child: const Icon(Icons.refresh, size: 48),
              ),
            ),
            const Text('Если спиннер замирает — main isolate заблокирован.',
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _guard(() async {
                        final r = await writeWithSpawn(await _path, _count);
                        _add('Isolate.spawn: записано ${r.count} шт. за '
                            '${r.millis} мс\n${r.path}');
                      }),
              child: const Text('Запись файла (Isolate.spawn)'),
            ),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _guard(() async {
                        final r = await readWithCompute(await _path);
                        _add('compute: прочитано ${r.count} шт. за '
                            '${r.millis} мс');
                      }),
              child: const Text('Чтение файла (compute)'),
            ),
            FilledButton.tonal(
              onPressed: _busy
                  ? null
                  : () => _guard(() async {
                        final path = await _path;
                        await Future<void>.delayed(
                            const Duration(milliseconds: 50));
                        final r = readInMain(path);
                        _add('main isolate: прочитано ${r.count} шт. за '
                            '${r.millis} мс (UI был заблокирован)');
                      }),
              child: const Text('Чтение в main isolate (для сравнения)'),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [for (final l in _log) ListTile(title: Text(l))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
