import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/favorites_provider.dart';
import '../providers/session_provider.dart';
import '../providers/shipments_provider.dart';
import '../theme.dart';
import '../widgets/shipment_card.dart';
import 'favorites_screen.dart';
import 'security_screen.dart';
import 'shipment_detail_screen.dart';
import 'shipment_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canEdit = context.select<SessionProvider, bool>((s) => s.user.canEdit);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: canEdit
          ? FloatingActionButton(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ShipmentFormScreen())),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: const SafeArea(
        child: Column(
          children: [
            _Header(),
            SizedBox(height: 8),
            Expanded(child: _ShipmentList()),
          ],
        ),
      ),
    );
  }
}

class _ShipmentList extends StatelessWidget {
  const _ShipmentList();

  @override
  Widget build(BuildContext context) {
    return Consumer<ShipmentsProvider>(
      builder: (context, shipments, _) {
        final items = shipments.items;
        if (items.isEmpty) return const Center(child: Text('Нет посылок'));
        return ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            for (final s in items)
              ShipmentCard(
                shipment: s,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ShipmentDetailScreen(shipmentId: s.id))),
              ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionProvider, AppUser>((s) => s.user);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 12, 0),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => _pickUser(context, user),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current user (tap to switch)',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  const SizedBox(height: 2),
                  Text('${user.name} · ${user.role.name}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const FavoritesBadgeButton(),
          IconButton(
            tooltip: 'Security / storage',
            icon: const Icon(Icons.lock_outline_rounded),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
          ),
        ],
      ),
    );
  }

  void _pickUser(BuildContext context, AppUser currentUser) {
    final session = context.read<SessionProvider>();
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final u in session.users)
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(u.name),
                subtitle: Text(u.role.name),
                selected: u.id == currentUser.id,
                onTap: () {
                  session.switchUser(u);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class FavoritesBadgeButton extends StatelessWidget {
  const FavoritesBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<FavoritesProvider, int>((f) => f.count);
    return IconButton(
      tooltip: 'Favorites',
      icon: Badge(
        key: const Key('favorites-badge'),
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.orange,
        child: const Icon(Icons.favorite_border_rounded),
      ),
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
    );
  }
}
