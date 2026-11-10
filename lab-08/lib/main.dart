import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.init();
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery App (Hive)',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
