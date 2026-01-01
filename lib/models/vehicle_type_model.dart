// models/vehicle_type_model.dart
class VehicleType {
  final String id;
  final String name;
  final String displayName;
  final int capacity;
  final String? description;
  final double baseFare;
  final double perKmRate;
  final double perMinuteRate;
  final String? iconEmoji;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  VehicleType({
    required this.id,
    required this.name,
    required this.displayName,
    required this.capacity,
    this.description,
    required this.baseFare,
    required this.perKmRate,
    required this.perMinuteRate,
    this.iconEmoji,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });

  factory VehicleType.fromMap(Map<String, dynamic> map) {
    return VehicleType(
      id: map['id'],
      name: map['name'],
      displayName: map['display_name'],
      capacity: map['capacity'],
      description: map['description'],
      baseFare: (map['base_fare'] as num).toDouble(),
      perKmRate: (map['per_km_rate'] as num).toDouble(),
      perMinuteRate: (map['per_minute_rate'] as num).toDouble(),
      iconEmoji: map['icon_emoji'],
      isActive: map['is_active'],
      sortOrder: map['sort_order'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String get imageUrl => 'https://example.com/images/${id}.png';

  String get timeInfo => 'Time: ${perMinuteRate * 60} min';

  String get extraInfo => 'Capacity: ${capacity}';

  String get price => 'Price: \$${baseFare + (perKmRate * distanceKm)}';

  num get distanceKm => 0;
}
