import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/storage_dirs.dart';

class Task6FilesScreen extends StatefulWidget {
  const Task6FilesScreen({super.key});

  @override
  State<Task6FilesScreen> createState() => _Task6FilesScreenState();
}

class _Task6FilesScreenState extends State<Task6FilesScreen> {
  final _sections = <String, List<String>>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<List<String>> _locate(DirSpec spec, int index) async {
    if (!spec.supported.contains(currentPlatform)) {
      return [unsupportedMessage(spec, null)];
    }
    try {
      final dirs = await spec.resolve();
      final dir = dirs.whereType<Directory>().firstOrNull;
      if (dir == null) {
        return [unsupportedMessage(spec, 'платформа вернула null')];
      }
      if (!await dir.exists()) {
        return ['Директория не существует: ${dir.path}'];
      }
      final out = <String>['Директория: ${dir.path}'];
      final target = File(
          '${dir.path}${Platform.pathSeparator}developer_$index.json');
      final found = <File>[if (await target.exists()) target];
      await for (final e in dir.list(followLinks: false)) {
        if (e is File &&
            e.path != target.path &&
            e.uri.pathSegments.last.startsWith('developer_') &&
            e.path.endsWith('.json')) {
          found.add(e);
        }
      }
      if (found.isEmpty) {
        out.add('Файл developer_$index.json ещё не создан');
      } else {
        for (final f in found) {
          out.add('Файл: ${f.path} (${await f.length()} байт)');
        }
      }
      return out;
    } on UnsupportedError catch (e) {
      return [unsupportedMessage(spec, e.message)];
    } on MissingPlatformDirectoryException catch (e) {
      return [unsupportedMessage(spec, e.message)];
    } on FileSystemException catch (e) {
      return ['Ошибка файловой системы: ${e.message} ${e.path ?? ''}'];
    } catch (e) {
      return ['Ошибка: $e'];
    }
  }

  Future<void> _load() async {
    final s = <String, List<String>>{};
    for (var i = 0; i < dirSpecs.length; i++) {
      final spec = dirSpecs[i];
      s['${i + 1}. ${spec.title}'] = await _locate(spec, i);
    }
    if (mounted) {
      setState(() {
        _sections
          ..clear()
          ..addAll(s);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расположение файлов из задания 6'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final e in _sections.entries) ...[
                  Text(e.key,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  for (final f in e.value)
                    SelectableText(f, style: const TextStyle(fontSize: 12)),
                  const Divider(height: 24),
                ],
              ],
            ),
    );
  }
}
