import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'models/shipment.dart';
import 'screens/device_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shipment_details_screen.dart';
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
      initialRoute: AppRoutes.home,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

Route<String?>? _onGenerateRoute(RouteSettings settings) {
  final Widget page;
  switch (settings.name) {
    case AppRoutes.home:
      page = const HomeScreen();
      break;
    case AppRoutes.details:
      page = ShipmentDetailsScreen(shipment: settings.arguments as Shipment);
      break;
    case AppRoutes.tracking:
      page = TrackingScreen(bookingId: settings.arguments as String);
      break;
    case AppRoutes.device:
      page = const DeviceScreen();
      break;
    default:
      return null;
  }
  return MaterialPageRoute<String?>(
    builder: (_) => page,
    settings: settings,
  );
}
