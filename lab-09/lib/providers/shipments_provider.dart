import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/shipment.dart';

class ShipmentsProvider extends ChangeNotifier {
  ShipmentsProvider(this._box);

  final Box<Shipment> _box;

  List<Shipment> get items => _box.values.toList();
  Shipment? byId(String id) => _box.get(id);
  bool contains(String id) => _box.containsKey(id);

  Future<void> save(Shipment s) async {
    await _box.put(s.id, s);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
