class Shipment {
  const Shipment({
    required this.id,
    required this.name,
    required this.status,
    required this.image,
  });

  final String id;
  final String name;
  final String status;
  final String image;

  Shipment copyWith({String? status}) {
    return Shipment(
      id: id,
      name: name,
      status: status ?? this.status,
      image: image,
    );
  }
}
