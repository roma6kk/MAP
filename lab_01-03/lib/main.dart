import 'package:flutter/material.dart';

void main() => runApp(const DeveloperLabApp());

// ! 1
abstract interface class Developer {
  String writeCode(String task);
  void reviewCode({required String file, bool approve = true});
}

class Mentor {
  final String name;

  Mentor(this.name);

  String advise(String topic) => '$name: изучите $topic';
}

// ! 4
abstract class DeveloperBase {
  final String name;
  double _salary;

  DeveloperBase(this.name, this._salary);

  double get salary => _salary;
  set salary(double value) {
    if (value > 0) _salary = value;
  }

  String get specialty;
  String work({int hours = 8});

  String runTask(String task, String Function(String) formatter, [int? priority]) =>
      formatter('$task, приоритет ${priority ?? 3}');
}

// ! 4
class FlutterDeveloper extends DeveloperBase implements Developer {
  static int totalDevelopers = 0;

  FlutterDeveloper(super.name, super.salary) {
    totalDevelopers++;
  }

  FlutterDeveloper.intern(String name) : super(name, 50000);

  @override
  String get specialty => 'Flutter / Dart';

  @override
  String work({int hours = 8}) => '$name пишет приложение $hours ч.';

  @override
  String writeCode(String task) => '$name реализует: $task';

  @override
  void reviewCode({required String file, bool approve = true}) {}

  static String stack() => 'Dart, Flutter, Git';
}

// ! 5
class BackendDeveloper extends DeveloperBase implements Mentor {
  BackendDeveloper(super.name, super.salary);

  @override
  String get specialty => 'Backend / API';

  @override
  String work({int hours = 8}) => '$name проектирует API $hours ч.';

  @override
  String advise(String topic) => '$name объясняет тему: $topic';
}

class Project {
  final String title;
  final List<String> technologies;

  Project(this.title, this.technologies);
}

class DeveloperLab {
  // ! 6
  static final List<DeveloperBase> team = [
    FlutterDeveloper('Анна', 120000),
    FlutterDeveloper.intern('Илья'),
    BackendDeveloper('Мария', 145000),
  ];

  static String buildReport() {
    // ! 6
    final skills = <String>{'Dart', 'Flutter', 'API'};
    skills.add('Dart');
    final hoursByDeveloper = <String, int>{};
    final lines = <String>[];
    team.first.salary = 125000;

    // ! 7
    for (final developer in team) {
      if (developer.name == 'Илья') continue;
      hoursByDeveloper[developer.name] = 8;
      lines.add(developer.work());
      if (lines.length == 2) break;
    }

    // ! 8
    try {
      final project = Project('Мобильное приложение', ['Flutter', 'Dart']);
      if (project.technologies.isEmpty) throw StateError('Нет технологий');
      lines.add('${project.title}: ${project.technologies.join(', ')}');
      lines.add('Явный интерфейс: ${(team.first as Developer).writeCode('экран профиля')}');
      lines.add('Неявный интерфейс: ${BackendDeveloper('Олег', 100000).advise('REST')}');
      lines.add('Set навыков: ${skills.join(', ')}');
      lines.add('Map часы: ${hoursByDeveloper.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')}');
      // ! 5
      lines.add('callback: ${team.first.runTask('экран профиля', (task) => task.toUpperCase(), 1)}');
      (team.first as Developer).reviewCode(file: 'main.dart', approve: false);
      lines.add('named: reviewCode вызван для main.dart (approve: false)');
    } catch (error) {
      lines.add('Ошибка проекта: $error');
    } finally {
      lines.add('finally: отчет завершен');
    }
    try {
      int.parse('не число');
    } catch (error) {
      lines.add('catch: обработано FormatException');
    } finally {
      lines.add('finally: проверка исключения завершена');
    }
    return lines.join('\n');
  }
}

class DeveloperLabApp extends StatelessWidget {
  const DeveloperLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Разработчик',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DeveloperHomePage(),
    );
  }
}

class DeveloperHomePage extends StatelessWidget {
  const DeveloperHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная 2 · Разработчик')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Иерархия команды', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('abstract DeveloperBase → FlutterDeveloper, BackendDeveloper'),
          const SizedBox(height: 16),
          ...DeveloperLab.team.map((developer) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(developer.name[0])),
                  title: Text(developer.name),
                  subtitle: Text('${developer.specialty} · зарплата: ${developer.salary.toStringAsFixed(0)} ₽'),
                  trailing: const Icon(Icons.code),
                ),
              )),
          const SizedBox(height: 16),
          Text('Демонстрация Dart', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(DeveloperLab.buildReport()),
            ),
          ),
          const SizedBox(height: 12),
          Text('Разработчиков создано: ${FlutterDeveloper.totalDevelopers} · static stack(): ${FlutterDeveloper.stack()}'),
        ],
      ),
    );
  }
}
