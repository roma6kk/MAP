import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_user.dart';
import '../models/favorite.dart';
import '../models/shipment.dart';
import '../theme.dart';

class HiveService {
  HiveService._();
  static final instance = HiveService._();

  static const _keyName = 'hive_encryption_key';
  static const _keyName2 = 'hive_encryption_key_wrong';
  static const usersBox = 'users';
  static const shipmentsBox = 'shipments';
  static const favoritesBox = 'favorites';

  final _secure = const FlutterSecureStorage();

  late Box<AppUser> users;
  late Box<Shipment> shipments;
  late Box<Favorite> favorites;

  Future<List<int>> _loadKey(String name) async {
    final stored = await _secure.read(key: name);
    if (stored != null) return base64Url.decode(stored);
    final key = Hive.generateSecureKey();
    await _secure.write(key: name, value: base64UrlEncode(key));
    return key;
  }

  Future<void> init() async {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(AppUserAdapter())
      ..registerAdapter(ShipmentAdapter())
      ..registerAdapter(FavoriteAdapter());

    final cipher = HiveAesCipher(await _loadKey(_keyName));
    users = await Hive.openBox<AppUser>(usersBox, encryptionCipher: cipher);
    shipments = await Hive.openBox<Shipment>(shipmentsBox, encryptionCipher: cipher);
    favorites = await Hive.openBox<Favorite>(favoritesBox, encryptionCipher: cipher);
    await _seed();
  }

  Future<void> _seed() async {
    if (users.isEmpty) {
      await users.putAll({
        'u1': AppUser(id: 'u1', name: 'Anna (Admin)', role: UserRole.admin),
        'u2': AppUser(id: 'u2', name: 'Mike (Manager)', role: UserRole.manager),
        'u3': AppUser(id: 'u3', name: 'John (User)', role: UserRole.user),
      });
    }
    if (shipments.isEmpty) {
      Shipment s(String id, String img, String name, String st, String to) => Shipment(
            id: id,
            image: img,
            name: name,
            status: st,
            fromPlace: 'Diriyah, Riyadh',
            toPlace: to,
            sentDate: '18 Oct 2025',
            estimatedDate: '19 Oct 2025',
            description: 'Parcel "$name" shipped from Riyadh. Handle with care.',
          );
      await shipments.putAll({
        'H314315796': s('H314315796', AppImages.macMini, 'Mac Mini M4 Pro', 'On Process', 'Jawhra, Jeddah'),
        'K37856307': s('K37856307', AppImages.speaker, 'Sony Speaker', 'Delivered', 'Al Olaya, Riyadh'),
        'K37956307': s('K37956307', AppImages.drone, 'DJI Drone', 'Pending', 'Corniche, Dammam'),
      });
    }
  }

  Future<String> demoWrongKey() async {
    final good = await _loadKey(_keyName);
    final wrong = await _loadKey(_keyName2);
    const name = 'demo_wrong_key';
    final buf = StringBuffer();
    try {
      await Hive.deleteBoxFromDisk(name);
      final b = await Hive.openBox<String>(name, encryptionCipher: HiveAesCipher(good));
      await b.put('secret', 'parcel H314315796 -> Jeddah');
      await b.close();
      buf.writeln('Ключ 1 (верный): записано secret.');

      final ok = await Hive.openBox<String>(name, encryptionCipher: HiveAesCipher(good));
      buf.writeln('Чтение верным ключом: "${ok.get('secret')}"');
      await ok.close();

      try {
        final bad = await Hive.openBox<String>(name, encryptionCipher: HiveAesCipher(wrong));
        buf.writeln('Чтение НЕверным ключом: ${bad.get('secret')} (записей: ${bad.length})');
        await bad.close();
      } catch (e) {
        buf.writeln('Чтение НЕверным ключом -> ошибка:\n$e');
      }
    } finally {
      await Hive.deleteBoxFromDisk(name);
    }
    return buf.toString();
  }

  Future<String> compactAll() async {
    final out = StringBuffer();
    for (final b in <Box>[users, shipments, favorites]) {
      final before = await _size(b.path);
      await b.compact();
      final after = await _size(b.path);
      out.writeln('${b.name}: $before B -> $after B');
    }
    return out.toString();
  }

  Future<int> _size(String? path) async {
    if (path == null || kIsWeb) return 0;
    return File(path).length();
  }
}
