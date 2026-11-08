abstract interface class Developer {
  String writeCode(String task);
  String reviewCode({required String file, bool approve = true});
}

class Mentor {
  final String name;

  Mentor(this.name);

  String advise(String topic) => '$name: изучите $topic';
}

// ! 1
mixin CoffeeLover {
  int cupsOfCoffee = 0;

  String drinkCoffee() {
    cupsOfCoffee++;
    return '$cupsOfCoffee-я чашка кофе выпита';
  }
}

mixin Presenter {
  String present(String topic) => 'Выступление «$topic» с примерами кода';
}

mixin Reportable on DeveloperBase {
  String buildReport() => '$name ($specialty) — ${salary.toStringAsFixed(0)} ₽';
}

mixin CodeReviewer on DeveloperBase {
  String reviewCode({required String file, bool approve = true}) =>
      '$name ${approve ? 'одобрил' : 'отклонил'} ревью файла $file';
}

// ! 2 Comparable
abstract class DeveloperBase implements Comparable<DeveloperBase> {
  final String name;
  double _salary;

  DeveloperBase(this.name, this._salary);

  double get salary => _salary;
  set salary(double value) {
    if (value > 0) _salary = value;
  }

  String get specialty;
  String work({int hours = 8});

  @override
  int compareTo(DeveloperBase other) => salary.compareTo(other.salary);

  // ! 3
  Map<String, dynamic> toJson() => {
        'role': runtimeType.toString(),
        'name': name,
        'salary': salary,
      };

  // ! 3
  static DeveloperBase fromJson(Map<String, dynamic> json) {
    return switch (json['role']) {
      'FlutterDeveloper' => FlutterDeveloper.fromJson(json),
      'BackendDeveloper' => BackendDeveloper.fromJson(json),
      _ => throw FormatException('Неизвестный тип разработчика: ${json['role']}'),
    };
  }

  @override
  String toString() => '$name ($runtimeType) — $specialty';
}

// ! 1
class FlutterDeveloper extends DeveloperBase
    with CoffeeLover, CodeReviewer, Reportable
    implements Developer {
  static int totalDevelopers = 0;

  FlutterDeveloper(super.name, super.salary) {
    totalDevelopers++;
  }

  factory FlutterDeveloper.intern(String name) =>
      FlutterDeveloper(name, 50000);

  @override
  String get specialty => 'Flutter / Dart';

  @override
  String work({int hours = 8}) => '$name пишет приложение $hours ч.';

  @override
  String writeCode(String task) => '$name реализует: $task';

  static String stack() => 'Dart, Flutter, Git';

  // ! 3
  @override
  Map<String, dynamic> toJson() =>
      {...super.toJson(), 'cupsOfCoffee': cupsOfCoffee};

  factory FlutterDeveloper.fromJson(Map<String, dynamic> json) {
    final developer = FlutterDeveloper(
      json['name'] as String,
      (json['salary'] as num).toDouble(),
    );
    developer.cupsOfCoffee = json['cupsOfCoffee'] as int? ?? 0;
    return developer;
  }
}

// ! 1
class BackendDeveloper extends DeveloperBase
    with Presenter, CodeReviewer, Reportable
    implements Mentor {
  BackendDeveloper(super.name, super.salary);

  @override
  String get specialty => 'Backend / API';

  @override
  String work({int hours = 8}) => '$name проектирует API $hours ч.';

  @override
  String advise(String topic) => '$name объясняет тему: $topic';

  factory BackendDeveloper.fromJson(Map<String, dynamic> json) =>
      BackendDeveloper(
        json['name'] as String,
        (json['salary'] as num).toDouble(),
      );
}

class Project {
  final String title;
  final List<String> technologies;

  Project(this.title, this.technologies);

  // ! 3
  Map<String, dynamic> toJson() => {
        'title': title,
        'technologies': technologies,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        json['title'] as String,
        (json['technologies'] as List<dynamic>).cast<String>(),
      );
}

// ! 2 Iterator 
class TeamIterator implements Iterator<DeveloperBase> {
  final List<DeveloperBase> _developers;
  int _position = -1;

  TeamIterator(this._developers);

  @override
  DeveloperBase get current => _developers[_position];

  @override
  bool moveNext() {
    if (_position + 1 < _developers.length) {
      _position++;
      return true;
    }
    return false;
  }
}

// ! 2 Iterable
class Team implements Iterable<DeveloperBase> {
  final List<DeveloperBase> _developers = [];

  void add(DeveloperBase developer) => _developers.add(developer);

  void sortBySalary() => _developers.sort();

  @override
  Iterator<DeveloperBase> get iterator => TeamIterator(_developers);

  @override
  int get length => _developers.length;

  @override
  bool get isEmpty => _developers.isEmpty;

  @override
  bool get isNotEmpty => _developers.isNotEmpty;

  @override
  DeveloperBase get first => _developers.first;

  @override
  Iterable<T> map<T>(T Function(DeveloperBase) toElement) =>
      _developers.map(toElement);

  @override
  Iterable<DeveloperBase> where(bool Function(DeveloperBase) test) =>
      _developers.where(test);

  @override
  T fold<T>(T initialValue, T Function(T, DeveloperBase) combine) =>
      _developers.fold(initialValue, combine);

  @override
  bool any(bool Function(DeveloperBase) test) => _developers.any(test);

  @override
  void forEach(void Function(DeveloperBase) action) =>
      _developers.forEach(action);

  @override
  List<DeveloperBase> toList({bool growable = true}) =>
      _developers.toList(growable: growable);

  @override
  bool contains(Object? element) => _developers.contains(element);

  @override
  String join([String separator = '']) => _developers.join(separator);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}