import 'package:hive/hive.dart';

class Shipment {
  Shipment({
    required this.id,
    required this.image,
    required this.name,
    required this.status,
    required this.fromPlace,
    required this.toPlace,
    required this.sentDate,
    required this.estimatedDate,
    required this.description,
  });

  final String id;
  final String image;
  final String name;
  final String status;
  final String fromPlace;
  final String toPlace;
  final String sentDate;
  final String estimatedDate;
  final String description;

  Shipment copyWith({
    String? image,
    String? name,
    String? status,
    String? fromPlace,
    String? toPlace,
    String? sentDate,
    String? estimatedDate,
    String? description,
  }) =>
      Shipment(
        id: id,
        image: image ?? this.image,
        name: name ?? this.name,
        status: status ?? this.status,
        fromPlace: fromPlace ?? this.fromPlace,
        toPlace: toPlace ?? this.toPlace,
        sentDate: sentDate ?? this.sentDate,
        estimatedDate: estimatedDate ?? this.estimatedDate,
        description: description ?? this.description,
      );
}

class ShipmentAdapter extends TypeAdapter<Shipment> {
  @override
  final int typeId = 2;

  @override
  Shipment read(BinaryReader r) => Shipment(
        id: r.readString(),
        image: r.readString(),
        name: r.readString(),
        status: r.readString(),
        fromPlace: r.readString(),
        toPlace: r.readString(),
        sentDate: r.readString(),
        estimatedDate: r.readString(),
        description: r.readString(),
      );

  @override
  void write(BinaryWriter w, Shipment s) {
    w
      ..writeString(s.id)
      ..writeString(s.image)
      ..writeString(s.name)
      ..writeString(s.status)
      ..writeString(s.fromPlace)
      ..writeString(s.toPlace)
      ..writeString(s.sentDate)
      ..writeString(s.estimatedDate)
      ..writeString(s.description);
  }
}
