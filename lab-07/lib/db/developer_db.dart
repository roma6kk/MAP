import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/developer.dart';

enum SortField {
  name('name', 'Имя'),
  specialty('specialty', 'Специальность'),
  salary('salary', 'Зарплата'),
  cups('cups_of_coffee', 'Кофе');

  const SortField(this.column, this.label);
  final String column;
  final String label;
}

class SortRule {
  const SortRule(this.field, {this.ascending = true});
  final SortField field;
  final bool ascending;

  SortRule toggled() => SortRule(field, ascending: !ascending);
}

class DeveloperDb {
  DeveloperDb._();
  static final DeveloperDb instance = DeveloperDb._();

  Database? _db;

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'developers.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
CREATE TABLE developers(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  role TEXT NOT NULL,
  salary REAL NOT NULL,
  cups_of_coffee INTEGER NOT NULL DEFAULT 0
)''');
        final batch = db.batch();
        for (final d in _seed) {
          batch.insert('developers', d.toMap()..remove('id'));
        }
        await batch.commit(noResult: true);
      },
    );
  }

  static const _seed = [
    Developer(name: 'Анна Смирнова', specialty: 'Flutter / Dart', role: 'FlutterDeveloper', salary: 150000, cupsOfCoffee: 4),
    Developer(name: 'Иван Петров', specialty: 'Backend / API', role: 'BackendDeveloper', salary: 180000, cupsOfCoffee: 2),
    Developer(name: 'Мария Козлова', specialty: 'Flutter / Dart', role: 'FlutterDeveloper', salary: 120000, cupsOfCoffee: 6),
    Developer(name: 'Олег Новиков', specialty: 'Backend / Go', role: 'BackendDeveloper', salary: 200000, cupsOfCoffee: 3),
    Developer(name: 'Елена Орлова', specialty: 'Flutter / Dart', role: 'FlutterDeveloper', salary: 150000, cupsOfCoffee: 1),
  ];

  Future<int> insert(Developer d) async =>
      (await _database).insert('developers', d.toMap()..remove('id'));

  Future<Developer?> getById(int id) async {
    final rows = await (await _database)
        .query('developers', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Developer.fromMap(rows.first);
  }

  Future<List<Developer>> query({
    String search = '',
    List<SortRule> sort = const [],
  }) async {
    final q = search.trim();
    final orderBy = sort.isEmpty
        ? null
        : sort
            .map((r) => '${r.field.column} COLLATE NOCASE '
                '${r.ascending ? 'ASC' : 'DESC'}')
            .join(', ');
    final rows = await (await _database).query(
      'developers',
      where: q.isEmpty
          ? null
          : '(name LIKE ? OR specialty LIKE ? OR role LIKE ?)',
      whereArgs: q.isEmpty ? null : ['%$q%', '%$q%', '%$q%'],
      orderBy: orderBy,
    );
    return rows.map(Developer.fromMap).toList();
  }

  Future<int> update(Developer d) async => (await _database)
      .update('developers', d.toMap(), where: 'id = ?', whereArgs: [d.id]);

  Future<int> delete(int id) async => (await _database)
      .delete('developers', where: 'id = ?', whereArgs: [id]);
}
