import 'package:flutter/material.dart';

import '../db/developer_db.dart';
import '../models/developer.dart';
import 'developer_edit_screen.dart';

class DeveloperDetailsScreen extends StatefulWidget {
  const DeveloperDetailsScreen({super.key, required this.id});
  final int id;

  @override
  State<DeveloperDetailsScreen> createState() => _DeveloperDetailsScreenState();
}

class _DeveloperDetailsScreenState extends State<DeveloperDetailsScreen> {
  Developer? _dev;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await DeveloperDb.instance.getById(widget.id);
    if (mounted) setState(() => _dev = d);
  }

  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeveloperEditScreen(developer: _dev)),
    );
    _load();
  }

  Future<void> _delete() async {
    await DeveloperDb.instance.delete(widget.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final d = _dev;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация'),
        actions: [
          IconButton(onPressed: d == null ? null : _edit, icon: const Icon(Icons.edit)),
          IconButton(onPressed: d == null ? null : _delete, icon: const Icon(Icons.delete)),
        ],
      ),
      body: d == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _row('ID', '${d.id}'),
                _row('Имя', d.name),
                _row('Специальность', d.specialty),
                _row('Роль', d.role),
                _row('Зарплата', '${d.salary.toStringAsFixed(0)} ₽'),
                _row('Чашек кофе', '${d.cupsOfCoffee}'),
              ],
            ),
    );
  }

  Widget _row(String k, String v) => ListTile(
        title: Text(k, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(v, style: const TextStyle(fontSize: 18)),
      );
}
