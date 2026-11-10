import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/shipment.dart';
import '../services/hive_service.dart';
import '../services/session.dart';
import '../theme.dart';
import '../widgets/shipment_card.dart';
import 'shipment_form_screen.dart';

class ShipmentDetailScreen extends StatelessWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  Widget build(BuildContext context) {
    final box = HiveService.instance.shipments;
    return ListenableBuilder(
      listenable: Listenable.merge([box.listenable(), HiveService.instance.favorites.listenable()]),
      builder: (context, _) {
        final s = box.get(shipmentId);
        if (s == null) return const Scaffold(body: Center(child: Text('Посылка удалена')));
        final canEdit = Session.instance.user.canEdit;
        final fav = Session.instance.isFavorite(s.id);
        return Scaffold(
          appBar: AppBar(
            title: Text('ID: ${s.id}'),
            actions: [
              IconButton(
                icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: fav ? AppColors.orange : null),
                onPressed: () => Session.instance.toggleFavorite(s.id),
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
      },
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить посылку?'),
        content: Text(s.name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (ok != true) return;
    final favs = HiveService.instance.favorites;
    await favs.deleteAll(favs.values.where((f) => f.shipmentId == s.id).map((f) => '${f.userId}:${f.shipmentId}'));
    await HiveService.instance.shipments.delete(s.id);
    if (context.mounted) Navigator.pop(context);
  }
}
