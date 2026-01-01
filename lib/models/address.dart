// models/address.dart
class Address {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Address({
    required this.name, 
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
}
