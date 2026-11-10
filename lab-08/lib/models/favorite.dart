import 'package:hive/hive.dart';

class Favorite {
  Favorite({required this.userId, required this.shipmentId, required this.addedAt});

  final String userId;
  final String shipmentId;
  final DateTime addedAt;

  static String keyOf(String userId, String shipmentId) => '$userId:$shipmentId';
}

class FavoriteAdapter extends TypeAdapter<Favorite> {
  @override
  final int typeId = 3;

  @override
  Favorite read(BinaryReader r) => Favorite(
        userId: r.readString(),
        shipmentId: r.readString(),
        addedAt: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
      );

  @override
  void write(BinaryWriter w, Favorite f) {
    w
      ..writeString(f.userId)
      ..writeString(f.shipmentId)
      ..writeInt(f.addedAt.millisecondsSinceEpoch);
  }
}
