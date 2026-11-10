import 'package:flutter/material.dart';

import '../services/hive_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String _log = '';
  bool _busy = false;

  Future<void> _run(Future<String> Function() f) async {
    setState(() => _busy = true);
    try {
      final r = await f();
      setState(() => _log = r);
    } catch (e) {
      setState(() => _log = 'Ошибка: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security / storage')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Боксы зашифрованы AES-256. Ключ лежит в защищённом хранилище ОС '
                '(flutter_secure_storage).'),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: _busy ? null : () => _run(HiveService.instance.demoWrongKey),
                child: const Text('Прочитать с неправильным ключом')),
            const SizedBox(height: 8),
            FilledButton(
                onPressed: _busy ? null : () => _run(HiveService.instance.compactAll),
                child: const Text('Сжать боксы (compact)')),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: SelectableText(_log))),
          ],
        ),
      ),
    );
  }
}
