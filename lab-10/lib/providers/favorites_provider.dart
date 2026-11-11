import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/app_user.dart';
import '../models/favorite.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._box);

  final Box<Favorite> _box;
  String? _userId;

  void updateUser(AppUser user) {
    if (user.id == _userId) return;
    _userId = user.id;
    notifyListeners();
  }

  bool isFavorite(String shipmentId) =>
      _userId != null && _box.containsKey(Favorite.keyOf(_userId!, shipmentId));

  List<String> get shipmentIds {
    final list = _box.values.where((f) => f.userId == _userId).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return [for (final f in list) f.shipmentId];
  }

  int get count => _box.values.where((f) => f.userId == _userId).length;

  Future<void> toggle(String shipmentId) async {
    final uid = _userId;
    if (uid == null) return;
    final key = Favorite.keyOf(uid, shipmentId);
    if (_box.containsKey(key)) {
      await _box.delete(key);
    } else {
      await _box.put(key, Favorite(userId: uid, shipmentId: shipmentId, addedAt: DateTime.now()));
    }
    notifyListeners();
  }

  Future<void> removeShipment(String shipmentId) async {
    await _box.deleteAll(_box.values
        .where((f) => f.shipmentId == shipmentId)
        .map((f) => Favorite.keyOf(f.userId, f.shipmentId))
        .toList());
    notifyListeners();
  }
}
