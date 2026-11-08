class Developer {
  const Developer({
    this.id,
    required this.name,
    required this.specialty,
    required this.role,
    required this.salary,
    this.cupsOfCoffee = 0,
  });

  final int? id;
  final String name;
  final String specialty;
  final String role;
  final double salary;
  final int cupsOfCoffee;

  static const roles = ['FlutterDeveloper', 'BackendDeveloper'];

  Developer copyWith({
    int? id,
    String? name,
    String? specialty,
    String? role,
    double? salary,
    int? cupsOfCoffee,
  }) {
    return Developer(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      role: role ?? this.role,
      salary: salary ?? this.salary,
      cupsOfCoffee: cupsOfCoffee ?? this.cupsOfCoffee,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'role': role,
        'salary': salary,
        'cups_of_coffee': cupsOfCoffee,
      };

  factory Developer.fromMap(Map<String, Object?> map) => Developer(
        id: map['id'] as int?,
        name: map['name'] as String,
        specialty: map['specialty'] as String,
        role: map['role'] as String,
        salary: (map['salary'] as num).toDouble(),
        cupsOfCoffee: (map['cups_of_coffee'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => toMap();

  factory Developer.fromJson(Map<String, dynamic> json) =>
      Developer.fromMap(json);

  @override
  String toString() => '$name ($role) — $specialty';
}
