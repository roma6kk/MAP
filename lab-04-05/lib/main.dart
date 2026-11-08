import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/tracking_screen.dart';
import 'theme.dart';

void main() {
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery App',
      theme: AppTheme.light,
      home: const DeliveryAppShell(),
    );
  }
}

class DeliveryAppShell extends StatefulWidget {
  const DeliveryAppShell({super.key});

  @override
  State<DeliveryAppShell> createState() => _DeliveryAppShellState();
}

class _DeliveryAppShellState extends State<DeliveryAppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        HomeScreen(onTab: (i) => setState(() => _index = i)),
        TrackingScreen(onBack: () => setState(() => _index = 0)),
      ],
    );
  }
}
