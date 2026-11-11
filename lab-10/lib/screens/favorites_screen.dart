import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/session_provider.dart';
import '../providers/shipments_provider.dart';
import '../widgets/shipment_card.dart';
import 'shipment_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.select<SessionProvider, String>((s) => s.user.name);
    return Scaffold(
      appBar: AppBar(title: Text('Favorites — $userName')),
      body: Consumer2<FavoritesProvider, ShipmentsProvider>(
        builder: (context, favorites, shipments, _) {
          final items = [
            for (final id in favorites.shipmentIds) ?shipments.byId(id),
          ];
          if (items.isEmpty) return const Center(child: Text('Избранное пусто'));
          return ListView(children: [
            for (final s in items)
              ShipmentCard(
                shipment: s,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ShipmentDetailScreen(shipmentId: s.id))),
              ),
          ]);
        },
      ),
    );
  }
}
