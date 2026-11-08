import 'package:flutter/material.dart';

import '../services/storage_dirs.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<DirResult>? _results;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final res = <DirResult>[];
    for (var i = 0; i < dirSpecs.length; i++) {
      res.add(await writeAndRead(dirSpecs[i], i));
    }
    if (mounted) setState(() => _results = res);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Файловая система'),
        actions: [IconButton(onPressed: _run, icon: const Icon(Icons.refresh))],
      ),
      body: results == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: results.length,
              itemBuilder: (_, i) => _card(results[i]),
            ),
    );
  }

  Widget _card(DirResult r) {
    final ok = r.error == null;
    final d = r.content;
    return Card(
      color: ok ? null : Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(ok ? Icons.check_circle : Icons.error,
                  color: ok ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(r.spec.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ]),
            if (ok) ...[
              SelectableText('Путь: ${r.directory!.path}',
                  style: const TextStyle(fontSize: 12)),
              if (d != null)
                Text('Считано: ${d.name}, ${d.role}, ${d.specialty}, '
                    '${d.salary.toStringAsFixed(0)} ₽, ☕ ${d.cupsOfCoffee}'),
            ] else
              Text(r.error!),
          ],
        ),
      ),
    );
  }
}
