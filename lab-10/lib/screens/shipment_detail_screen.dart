import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/shipment.dart';
import '../providers/favorites_provider.dart';
import '../providers/session_provider.dart';
import '../providers/shipments_provider.dart';
import '../theme.dart';
import '../widgets/shipment_card.dart';
import 'shipment_form_screen.dart';

class ShipmentDetailScreen extends StatelessWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  Widget build(BuildContext context) {
    final s = context.select<ShipmentsProvider, Shipment?>((p) => p.byId(shipmentId));
    if (s == null) return const Scaffold(body: Center(child: Text('Посылка удалена')));
    final canEdit = context.select<SessionProvider, bool>((p) => p.user.canEdit);
    final fav = context.select<FavoritesProvider, bool>((f) => f.isFavorite(s.id));
    return Scaffold(
      appBar: AppBar(
        title: Text('ID: ${s.id}'),
        actions: [
          IconButton(
            icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: fav ? AppColors.orange : null),
            onPressed: () => context.read<FavoritesProvider>().toggle(s.id),
          ),
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ShipmentFormScreen(shipment: s))),
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, s)),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ShipmentImage(path: s.image, size: 220)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: Text(s.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            StatusPill(label: s.status),
          ]),
          const SizedBox(height: 16),
          _row(Icons.place_outlined, 'From', '${s.fromPlace} (${s.sentDate})'),
          _row(Icons.flag_outlined, 'To', '${s.toPlace} (est. ${s.estimatedDate})'),
          _row(Icons.notes_rounded, 'Description', s.description),
        ],
      ),
    );
  }

  Widget _row(IconData i, String t, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(i, size: 20, color: AppColors.textGrey),
          const SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
            Text(v, style: const TextStyle(fontSize: 14)),
          ])),
        ]),
      );

  Future<void> _delete(BuildContext context, Shipment s) async {
    // Берём ссылки до await — после него context может быть уже неактуален.
    final shipments = context.read<ShipmentsProvider>();
    final favorites = context.read<FavoritesProvider>();
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить посылку?'),
        content: Text(s.name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (ok != true) return;
    await favorites.removeShipment(s.id);
    await shipments.delete(s.id);
    navigator.pop();
  }
}
