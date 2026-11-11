import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/security_provider.dart';
import 'providers/session_provider.dart';
import 'providers/shipments_provider.dart';
import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.init();
  runApp(DeliveryApp(hive: HiveService.instance));
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key, required this.hive});

  final HiveService hive;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HiveService>.value(value: hive),
        ChangeNotifierProvider(create: (_) => SessionProvider(hive.users)),
        ChangeNotifierProvider(create: (_) => ShipmentsProvider(hive.shipments)),
        ChangeNotifierProxyProvider<SessionProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(hive.favorites),
          update: (_, session, favorites) => favorites!..updateUser(session.user),
        ),
        ChangeNotifierProvider(create: (ctx) => SecurityProvider(ctx.read<HiveService>())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Delivery App (Provider)',
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
