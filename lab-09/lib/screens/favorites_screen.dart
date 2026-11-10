import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/hive_service.dart';
import '../services/session.dart';
import '../widgets/shipment_card.dart';
import 'shipment_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hive = HiveService.instance;
    return Scaffold(
      appBar: AppBar(title: Text('Favorites — ${Session.instance.user.name}')),
      body: ListenableBuilder(
        listenable: Listenable.merge([hive.favorites.listenable(), hive.shipments.listenable()]),
        builder: (context, _) {
          final items = [
            for (final f in Session.instance.myFavorites())
              ?hive.shipments.get(f.shipmentId),
          ];
          if (items.isEmpty) return const Center(child: Text('Избранное пусто'));
          return ListView(children: [
            for (final s in items)
              ShipmentCard(
                shipment: s,
                onFavorite: () => Session.instance.toggleFavorite(s.id),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ShipmentDetailScreen(shipmentId: s.id))),
              ),
          ]);
        },
      ),
    );
  }
}
