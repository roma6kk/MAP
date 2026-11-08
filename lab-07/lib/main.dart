import 'package:flutter/material.dart';

import 'screens/developer_list_screen.dart';

void main() {
  runApp(const DeveloperApp());
}

class DeveloperApp extends StatelessWidget {
  const DeveloperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Developers (SQLite)',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
      ),
      home: const DeveloperListScreen(),
    );
  }
}
