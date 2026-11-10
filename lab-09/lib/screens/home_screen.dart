import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_user.dart';
import '../services/hive_service.dart';
import '../services/session.dart';
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
    final hive = HiveService.instance;
    final session = Session.instance;
    return ValueListenableBuilder<AppUser>(
      valueListenable: session.current,
      builder: (context, user, _) => Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: user.canEdit
            ? FloatingActionButton(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ShipmentFormScreen())),
                child: const Icon(Icons.add_rounded),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              _Header(user: user),
              const SizedBox(height: 8),
              Expanded(
                child: ListenableBuilder(
                  listenable: Listenable.merge([hive.shipments.listenable(), hive.favorites.listenable()]),
                  builder: (context, _) {
                    final items = hive.shipments.values.toList();
                    if (items.isEmpty) return const Center(child: Text('Нет посылок'));
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 90),
                      children: [
                        for (final s in items)
                          ShipmentCard(
                            shipment: s,
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => ShipmentDetailScreen(shipmentId: s.id))),
                            onFavorite: () => session.toggleFavorite(s.id),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
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
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final u in HiveService.instance.users.values)
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(u.name),
                subtitle: Text(u.role.name),
                selected: u.id == currentUser.id,
                onTap: () {
                  Session.instance.current.value = u;
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
