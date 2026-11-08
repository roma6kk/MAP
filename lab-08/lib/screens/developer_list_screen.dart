import 'package:flutter/material.dart';

import '../db/developer_db.dart';
import '../models/developer.dart';
import 'developer_details_screen.dart';
import 'developer_edit_screen.dart';
import 'files_screen.dart';
import 'isolate_screen.dart';
import 'task6_files_screen.dart';

class DeveloperListScreen extends StatefulWidget {
  const DeveloperListScreen({super.key});

  @override
  State<DeveloperListScreen> createState() => _DeveloperListScreenState();
}

class _DeveloperListScreenState extends State<DeveloperListScreen> {
  final _db = DeveloperDb.instance;
  final _searchCtrl = TextEditingController();
  List<Developer> _items = [];
  List<SortRule> _sort = [const SortRule(SortField.name)];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final items = await _db.query(search: _searchCtrl.text, sort: _sort);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _tapSort(SortField f) {
    final i = _sort.indexWhere((r) => r.field == f);
    setState(() {
      if (i < 0) {
        _sort = [..._sort, SortRule(f)];
      } else {
        _sort = [..._sort]..[i] = _sort[i].toggled();
      }
    });
    _reload();
  }

  void _removeSort(SortField f) {
    setState(() => _sort = _sort.where((r) => r.field != f).toList());
    _reload();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _reload();
  }

  Future<void> _delete(Developer d) async {
    await _db.delete(d.id!);
    _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Удалён: ${d.name}')),
    );
  }

  void _menu(String v) {
    switch (v) {
      case 'files':
        _open(const FilesScreen());
      case 'isolate':
        _open(const IsolateScreen());
      case 'task6':
        _open(const Task6FilesScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Разработчики'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _menu,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'files', child: Text('Файловая система')),
              PopupMenuItem(value: 'isolate', child: Text('Изоляты')),
              PopupMenuItem(value: 'task6', child: Text('Файлы из задания 6')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _open(const DeveloperEditScreen()),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _reload(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Поиск по имени, специальности, роли',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final f in SortField.values) _sortChip(f),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('Ничего не найдено'))
                    : ListView.builder(
                        itemExtent: 84,
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _tile(_items[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(SortField f) {
    final i = _sort.indexWhere((r) => r.field == f);
    final active = i >= 0;
    final arrow = active ? (_sort[i].ascending ? '↑' : '↓') : '';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onLongPress: active ? () => _removeSort(f) : null,
        child: ChoiceChip(
          selected: active,
          label: Text(active ? '${i + 1}. ${f.label} $arrow' : f.label),
          onSelected: (_) => _tapSort(f),
        ),
      ),
    );
  }

  Widget _tile(Developer d) {
    return Dismissible(
      key: ValueKey(d.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _delete(d),
      child: ListTile(
        onTap: () => _open(DeveloperDetailsScreen(id: d.id!)),
        leading: CircleAvatar(
          child: Icon(d.role == 'FlutterDeveloper'
              ? Icons.phone_android
              : Icons.dns),
        ),
        title: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${d.specialty}\n${d.salary.toStringAsFixed(0)} ₽ · ☕ ${d.cupsOfCoffee}',
          maxLines: 2,
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
