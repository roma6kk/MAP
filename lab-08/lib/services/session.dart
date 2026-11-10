import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/favorite.dart';
import 'hive_service.dart';

class Session {
  Session._();
  static final instance = Session._();

  final ValueNotifier<AppUser> current = ValueNotifier(HiveService.instance.users.values.first);

  AppUser get user => current.value;

  bool isFavorite(String shipmentId) =>
      HiveService.instance.favorites.containsKey(Favorite.keyOf(user.id, shipmentId));

  Future<void> toggleFavorite(String shipmentId) async {
    final box = HiveService.instance.favorites;
    final key = Favorite.keyOf(user.id, shipmentId);
    if (box.containsKey(key)) {
      await box.delete(key);
    } else {
      await box.put(key, Favorite(userId: user.id, shipmentId: shipmentId, addedAt: DateTime.now()));
    }
  }

  List<Favorite> myFavorites() {
    final list = HiveService.instance.favorites.values.where((f) => f.userId == user.id).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list;
  }
}
