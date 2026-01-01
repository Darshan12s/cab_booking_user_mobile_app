// models/ride_option_model.dart
class VehicleType {
  final String modelName;
  final String bodyType;
  final String timeInfo;
  final String extraInfo;
  final String price;
  final String imageUrl;
  final String capacity;
  final String basefare;

  final dynamic perKmRate;

  final String displayName;

  static var standard;

  static var sedan;

  var estimatedFare;

  VehicleType({
    required this.modelName,
    required this.bodyType,
    required this.timeInfo,
    required this.extraInfo,
    required this.price,
    required this.imageUrl,
    required this.perKmRate,
    required this.capacity,
    required this.displayName,
    required this.basefare,

    required int perMinuteRate,
  });

  String get name => displayName;

  get baseFare => null;
}
