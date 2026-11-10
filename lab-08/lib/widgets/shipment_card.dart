import 'package:flutter/material.dart';

import '../models/shipment.dart';
import '../services/session.dart';
import '../theme.dart';

class ShipmentCard extends StatelessWidget {
  const ShipmentCard({super.key, required this.shipment, required this.onTap, this.onFavorite});

  final Shipment shipment;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final fav = Session.instance.isFavorite(shipment.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: Row(
            children: [
              ClipOval(child: ShipmentImage(path: shipment.image, size: 44)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${shipment.id}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 3),
                    Text(shipment.name, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(height: 3),
                    Text('${shipment.fromPlace} → ${shipment.toPlace}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMidGrey)),
                  ],
                ),
              ),
              StatusPill(label: shipment.status),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onFavorite,
                icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: fav ? AppColors.orange : AppColors.textGrey, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(color: AppColors.pillGreyBg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMidGrey)),
      );
}

class ShipmentImage extends StatelessWidget {
  const ShipmentImage({super.key, required this.path, required this.size});
  final String path;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
          width: size, height: size, color: AppColors.pillGreyBg, child: const Icon(Icons.inventory_2_outlined)));
}
