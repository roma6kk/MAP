import 'package:flutter/material.dart';

import 'lab03/developer.dart';
import 'lab03/lab03_report.dart';

void main() => runApp(const DeveloperLabApp());

class DeveloperLabApp extends StatelessWidget {
  const DeveloperLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Лабораторная 3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Lab03HomePage(),
    );
  }
}

class Lab03HomePage extends StatelessWidget {
  const Lab03HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ! 2
    final team = Team()
      ..add(FlutterDeveloper('Анна', 120000))
      ..add(FlutterDeveloper.intern('Илья'))
      ..add(BackendDeveloper('Мария', 145000))
      ..sortBySalary();

    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная 3 · Mixins, JSON, Async')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Команда · отсортирована Comparable.compareTo',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...team.map(
            (developer) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(developer.name[0])),
                title: Text(developer.name),
                subtitle: Text(
                    '${developer.specialty} · зарплата: ${developer.salary.toStringAsFixed(0)} ₽'),
                trailing: const Icon(Icons.code),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Отчёт по заданиям 1-6',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          // Задание 4-5: отчёт собирается асинхронно, FutureBuilder
          // подписан на Future<String>.
          FutureBuilder<String>(
            future: buildLabReport(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Ошибка: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(snapshot.data!),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
              'FlutterDeveloper создано: ${FlutterDeveloper.totalDevelopers} · static stack(): ${FlutterDeveloper.stack()}'),
        ],
      ),
    );
  }
}